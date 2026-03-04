import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../services/localization_ext.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/country_picker_field.dart';
import '../services/lookup_service.dart';
import '../services/language_service.dart';
import '../models/lookup_value.dart';
import '../data/countries.dart';

class AddEditTripScreen extends StatefulWidget {
  final Trip? trip;
  const AddEditTripScreen({super.key, this.trip});
  @override
  State<AddEditTripScreen> createState() => _AddEditTripScreenState();
}

class _AddEditTripScreenState extends State<AddEditTripScreen> {
  final _formKey                = GlobalKey<FormState>();
  final _nameController         = TextEditingController();
  final _destinationController  = TextEditingController();
  final _notesController        = TextEditingController();
  // FocusNodes for correct Tab order: Name → Destination → Departure → Return → Notes
  final _nameFocus        = FocusNode();
  final _destinationFocus = FocusNode();
  final _countryFocus     = FocusNode();
  final _departureFocus   = FocusNode();
  final _returnFocus      = FocusNode();
  final _notesFocus       = FocusNode();
  // Date text controllers for direct keyboard editing
  final _departureTxtCtrl = TextEditingController();
  final _returnTxtCtrl    = TextEditingController();

  // Country stored as ISO alpha-2 code (e.g. 'IL'); displayed via picker
  String? _countryCode;

  DateTime? _departureDate;
  DateTime? _returnDate;
  // Stored as LookupValue.id; resolved from LookupService
  String? _typeId;
  String? _purposeId;
  TripStatus  _status  = TripStatus.planned;
  bool _isSaving = false;
  bool get _isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.trip!;
      _nameController.text         = t.name;
      _destinationController.text  = t.destination;
      _notesController.text        = t.notes ?? '';
      _departureDate = t.departureDate;
      _returnDate    = t.returnDate;
      _departureTxtCtrl.text = DateFormat('dd/MM/yyyy').format(t.departureDate);
      _returnTxtCtrl.text    = DateFormat('dd/MM/yyyy').format(t.returnDate);
      // Resolve stored enum name to lookup id (e.g. 'leisure' → id)
      _typeId    = LookupService.instance.resolve(LookupCategory.tripType, t.type.name)?.id
                ?? LookupService.instance.enabled(LookupCategory.tripType).firstOrNull?.id;
      _purposeId = LookupService.instance.resolve(LookupCategory.tripPurpose, t.purpose.name)?.id
                ?? LookupService.instance.enabled(LookupCategory.tripPurpose).firstOrNull?.id;
      _status  = t.status;

      // Resolve stored value: may be a code ('IL') or legacy plain name ('Israel')
      final stored = t.country;
      if (stored != null && stored.isNotEmpty) {
        // Try as code first, then fall back to name match
        final byCode = countryByCode(stored);
        if (byCode != null) {
          _countryCode = byCode.code;
        } else {
          final byName = _countryByName(stored);
          _countryCode = byName?.code;
        }
      }
    }
  }

  Country? _countryByName(String name) {
    try {
      return kCountries.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    _nameFocus.dispose();
    _destinationFocus.dispose();
    _countryFocus.dispose();
    _departureFocus.dispose();
    _returnFocus.dispose();
    _notesFocus.dispose();
    _departureTxtCtrl.dispose();
    _returnTxtCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDeparture) async {
    final now = DateTime.now();
    final initial = isDeparture
        ? (_departureDate ?? now)
        : (_returnDate ?? (_departureDate ?? now).add(const Duration(days: 7)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      initialDatePickerMode: DatePickerMode.day,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: TripReadyTheme.teal,
            onPrimary: Colors.white,
            surface: TripReadyTheme.cream,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          _departureTxtCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
          if (_returnDate == null) {
            // First pick — auto-fill return to +7 days
            _returnDate = picked.add(const Duration(days: 7));
            _returnTxtCtrl.text = DateFormat('dd/MM/yyyy').format(_returnDate!);
          } else if (_returnDate!.isBefore(picked)) {
            // Return is now before departure — silently shift to +7
            _returnDate = picked.add(const Duration(days: 7));
            _returnTxtCtrl.text = DateFormat('dd/MM/yyyy').format(_returnDate!);
          } else {
            // Return already set and still valid — leave it as the user had it
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final l = context.l;
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.tripsDeparture} & ${l.tripsReturn}')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final db  = DatabaseHelper.instance;
      final now = DateTime.now();
      // Store ISO code so it round-trips correctly; fall back to null if none chosen
      final countryValue = _countryCode;

      if (_isEditing) {
        await db.updateTrip(widget.trip!.copyWith(
          name:          _nameController.text.trim(),
          destination:   _destinationController.text.trim(),
          country:       countryValue,
          departureDate: _departureDate,
          returnDate:    _returnDate,
          type:          _resolvedTripType(),
          purpose:       _resolvedTripPurpose(),
          status:        _status,
          notes:         _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          updatedAt:     now,
        ));
      } else {
        await db.insertTrip(Trip(
          id:            const Uuid().v4(),
          name:          _nameController.text.trim(),
          destination:   _destinationController.text.trim(),
          country:       countryValue,
          departureDate: _departureDate!,
          returnDate:    _returnDate!,
          type:          _resolvedTripType(),
          purpose:       _resolvedTripPurpose(),
          status:        _status,
          notes:         _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt:     now,
          updatedAt:     now,
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.restart_alt, color: TripReadyTheme.danger, size: 22),
          SizedBox(width: 10),
          Text('Reset Form'),
        ]),
        content: const Text(
          'This will clear all fields and reset the form to empty values. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: TripReadyTheme.danger),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) _resetForm();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _destinationController.clear();
      _notesController.clear();
      _countryCode    = null;
      _departureDate  = null;
      _returnDate     = null;
      _typeId    = LookupService.instance.enabled(LookupCategory.tripType).firstOrNull?.id;
      _purposeId = LookupService.instance.enabled(LookupCategory.tripPurpose).firstOrNull?.id;
      _status  = TripStatus.planned;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Resolve _typeId back to TripType enum for Trip model storage.
  TripType _resolvedTripType() {
    final v = _typeId == null ? null
        : LookupService.instance.byId(LookupCategory.tripType, _typeId!);
    if (v == null) return TripType.leisure;
    switch (v.valueKey) {
      case 'business':  return TripType.business;
      case 'family':    return TripType.family;
      case 'adventure': return TripType.adventure;
      case 'medical':   return TripType.medical;
      case 'other':     return TripType.other;
      default:          return TripType.leisure;
    }
  }

  TripPurpose _resolvedTripPurpose() {
    final v = _purposeId == null ? null
        : LookupService.instance.byId(LookupCategory.tripPurpose, _purposeId!);
    if (v == null) return TripPurpose.holiday;
    switch (v.valueKey) {
      case 'work_trip':    return TripPurpose.workTrip;
      case 'family_visit': return TripPurpose.familyVisit;
      case 'conference':   return TripPurpose.conference;
      case 'medical':      return TripPurpose.medical;
      case 'other':        return TripPurpose.other;
      default:             return TripPurpose.holiday;
    }
  }

  String _typeLabel(TripType t, AppLocalizations l) {
    switch (t) {
      case TripType.leisure:   return l.tripTypeLeisure;
      case TripType.business:  return l.tripTypeBusiness;
      case TripType.family:    return l.tripTypeFamily;
      case TripType.adventure: return l.tripTypeAdventure;
      case TripType.medical:   return l.tripTypeMedical;
      case TripType.other:     return l.tripTypeOther;
    }
  }

  String _purposeLabel(TripPurpose p, AppLocalizations l) {
    switch (p) {
      case TripPurpose.holiday:     return l.tripPurposeHoliday;
      case TripPurpose.workTrip:    return l.tripPurposeWorkTrip;
      case TripPurpose.familyVisit: return l.tripPurposeFamilyVisit;
      case TripPurpose.conference:  return l.tripPurposeConference;
      case TripPurpose.medical:     return l.tripPurposeMedical;
      case TripPurpose.other:       return l.tripPurposeOther;
    }
  }

  String _statusLabel(TripStatus s, AppLocalizations l) {
    switch (s) {
      case TripStatus.active:   return l.tripsStatusActive;
      case TripStatus.planned:  return l.tripsStatusPlanned;
      case TripStatus.archived: return l.tripsStatusArchived;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l   = context.l;
    final fmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.tripsEditTrip : l.tripsNewTrip),
        leading: HomeButton(),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.restart_alt, color: Colors.white70),
              tooltip: 'Reset form',
              onPressed: _confirmReset,
            ),
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(l.actionSave,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ── Trip name ────────────────────────────────────────
            _buildLabel('${l.tripsTripName} *'),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_destinationFocus),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.luggage_outlined)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '${l.tripsTripName} required' : null,
            ),
            const SizedBox(height: 16),

            // ── Destination + Country ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination (city / place) — flex 3
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('${l.tripsDestination} *'),
                      TextFormField(
                        controller: _destinationController,
                        focusNode: _destinationFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_countryFocus),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.place_outlined)),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l.validatorRequired
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Country picker — flex 2
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l.tripsCountry),
                      Focus(
                        focusNode: _countryFocus,
                        onFocusChange: (hasFocus) {
                          // When tabbed into country field, open picker then advance
                          if (hasFocus) {
                            Future.delayed(const Duration(milliseconds: 80), () {
                              if (mounted) FocusScope.of(context).requestFocus(_departureFocus);
                            });
                          }
                        },
                        child: CountryPickerField(
                          initialCode: _countryCode,
                          label: l.tripsCountry,
                          onChanged: (c) => setState(() => _countryCode = c?.code),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Dates ────────────────────────────────────────────
            _buildLabel('${l.tripsDeparture} & ${l.tripsReturn} *'),
            Row(
              children: [
                Expanded(
                  child: _DateInputField(
                    label: l.tripsDeparture,
                    controller: _departureTxtCtrl,
                    focusNode: _departureFocus,
                    date: _departureDate,
                    onPickerTap: () => _pickDate(true),
                    onDateTyped: (d) => setState(() {
                      _departureDate = d;
                      if (_returnDate == null) {
                        _returnDate = d.add(const Duration(days: 7));
                        _returnTxtCtrl.text = DateFormat('dd/MM/yyyy').format(_returnDate!);
                      } else if (_returnDate!.isBefore(d)) {
                        _returnDate = d.add(const Duration(days: 7));
                        _returnTxtCtrl.text = DateFormat('dd/MM/yyyy').format(_returnDate!);
                      }
                    }),
                    nextFocus: _returnFocus,
                  ),
                ),
                const SizedBox(width: 8),
                // Inline duration badge — shows days between departure and return
                SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward,
                          size: 16, color: TripReadyTheme.textLight),
                      if (_departureDate != null && _returnDate != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: TripReadyTheme.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_returnDate!.difference(_departureDate!).inDays + 1}d',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: TripReadyTheme.teal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateInputField(
                    label: l.tripsReturn,
                    controller: _returnTxtCtrl,
                    focusNode: _returnFocus,
                    date: _returnDate,
                    onPickerTap: () => _pickDate(false),
                    onDateTyped: (d) => setState(() => _returnDate = d),
                    nextFocus: _notesFocus,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Type + Purpose ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l.tripsTripType),
                      _LookupDropdown(
                        cat: LookupCategory.tripType,
                        selectedId: _typeId,
                        icon: Icons.category_outlined,
                        onChanged: (id) => setState(() => _typeId = id),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l.tripsTripPurpose),
                      _LookupDropdown(
                        cat: LookupCategory.tripPurpose,
                        selectedId: _purposeId,
                        icon: Icons.flag_outlined,
                        onChanged: (id) => setState(() => _purposeId = id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Status (edit mode only) ──────────────────────────
            if (_isEditing) ...[
              _buildLabel(l.fieldStatus),
              DropdownButtonFormField<TripStatus>(
                value: _status,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.toggle_on_outlined)),
                items: TripStatus.values
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(_statusLabel(s, l))))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
            ],

            // ── Notes ────────────────────────────────────────────
            _buildLabel(l.fieldNotes),
            TextFormField(
              controller: _notesController,
              focusNode: _notesFocus,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? l.actionUpdate : l.tripsAddTrip),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

// ── Reusable lookup dropdown ─────────────────────────────────────────────────

/// Stateless dropdown that reads enabled values from [LookupService].
/// Displays localized labels. Passes the selected [LookupValue.id] back.
class _LookupDropdown extends StatelessWidget {
  const _LookupDropdown({
    required this.cat,
    required this.selectedId,
    required this.icon,
    required this.onChanged,
  });

  final LookupCategory cat;
  final String? selectedId;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final lang   = LanguageService.instance.locale.languageCode;
    final values = LookupService.instance.enabled(cat);
    // If stored id is no longer enabled, fall back to first
    final currentId = values.any((v) => v.id == selectedId)
        ? selectedId
        : values.firstOrNull?.id;

    return DropdownButtonFormField<String>(
      value: currentId,
      decoration: InputDecoration(prefixIcon: Icon(icon)),
      items: values
          .map((v) => DropdownMenuItem(value: v.id, child: Text(v.label(lang))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Date picker card (unchanged) ─────────────────────────────────────────────

/// Date field: type directly (dd/mm/yyyy) or tap calendar icon.
/// Red text for invalid input. Syncs when picker updates externally.
class _DateInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final DateTime? date;
  final VoidCallback onPickerTap;
  final ValueChanged<DateTime> onDateTyped;
  final FocusNode? nextFocus;

  const _DateInputField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.date,
    required this.onPickerTap,
    required this.onDateTyped,
    this.nextFocus,
  });

  @override
  State<_DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<_DateInputField> {
  bool _invalid = false;

  @override
  void didUpdateWidget(_DateInputField old) {
    super.didUpdateWidget(old);
    // Picker updated the date externally — sync text controller
    if (old.date != widget.date && widget.date != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(widget.date!);
      if (widget.controller.text != formatted) {
        widget.controller.text = formatted;
        setState(() => _invalid = false);
      }
    }
  }

  DateTime? _parse(String v) {
    final s = v.trim().replaceAll('-', '/').replaceAll('.', '/');
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    if (y < 2020 || y > 2040 || m < 1 || m > 12 || d < 1 || d > 31) return null;
    try { return DateTime(y, m, d); } catch (_) { return null; }
  }

  void _onSubmit(String v) {
    final parsed = _parse(v);
    if (parsed != null) {
      setState(() => _invalid = false);
      widget.onDateTyped(parsed);
    } else if (v.trim().isNotEmpty) {
      setState(() => _invalid = true);
    }
    if (widget.nextFocus != null) {
      FocusScope.of(context).requestFocus(widget.nextFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.date != null && !_invalid;
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: widget.nextFocus != null ? TextInputAction.next : TextInputAction.done,
      keyboardType: TextInputType.datetime,
      onChanged: (_) { if (_invalid) setState(() => _invalid = false); },
      onFieldSubmitted: _onSubmit,
      onEditingComplete: () => _onSubmit(widget.controller.text),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'dd/mm/yyyy',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _invalid ? TripReadyTheme.danger
                : active ? TripReadyTheme.teal : TripReadyTheme.warmGrey,
            width: active || _invalid ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _invalid ? TripReadyTheme.danger : TripReadyTheme.teal,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month_outlined, size: 18),
          color: TripReadyTheme.teal,
          tooltip: 'Open calendar',
          onPressed: widget.onPickerTap,
        ),
      ),
      style: TextStyle(
        color: _invalid ? TripReadyTheme.danger
            : active ? TripReadyTheme.textDark : TripReadyTheme.textLight,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        fontSize: 14,
      ),
    );
  }
}
