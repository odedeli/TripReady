import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../widgets/map_search_bar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/trip_stop.dart';
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

class _AddEditTripScreenState extends State<AddEditTripScreen>
    with SingleTickerProviderStateMixin {
  final _formKey                = GlobalKey<FormState>();
  final _nameController         = TextEditingController();
  final _destinationController  = TextEditingController(); // primary (index 0)
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

  // ── Route state ────────────────────────────────────────────────────────────
  String? _returnDestination;
  String? _returnCountryCode;
  List<TripStop> _stops = [];

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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_isEditing) {
      final t = widget.trip!;
      _nameController.text         = t.name;
      _destinationController.text  = t.destination;
      _returnDestination  = t.returnDestination;
      _returnCountryCode  = t.returnCountry;
      _stops              = List.of(t.stops);
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
    _tabController.dispose();
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
      showAppSnackBar(context, '${l.tripsDeparture} & ${l.tripsReturn}');
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
          returnDestination: _returnDestination?.trim(),
          returnCountry: _returnCountryCode,
          clearReturnDestination: _returnDestination == null,
          clearReturnCountry: _returnCountryCode == null,
          stops:         _stops,
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
          returnDestination: _returnDestination?.trim().isEmpty == true ? null : _returnDestination?.trim(),
          returnCountry: _returnCountryCode,
          stops:         _stops,
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
      if (mounted) showAppSnackBar(context, '$e');
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
      _returnDestination = null;
      _returnCountryCode = null;
      _stops = [];
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
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TripReadyTheme.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Form', icon: Icon(Icons.edit_note_outlined, size: 18)),
            Tab(text: 'Map',  icon: Icon(Icons.map_outlined,       size: 18)),
          ],
        ),
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
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // prevent swipe — save is tab 1
        children: [
          // ── Tab 1: Form ────────────────────────────────────────
          Form(
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

            // ── Route: departure, stops, return ─────────────
            _RouteSection(
              depController: _destinationController,
              depFocus: _destinationFocus,
              depCountryCode: _countryCode,
              depCountryFocus: _countryFocus,
              onDepCountryChanged: (code) => setState(() => _countryCode = code),
              onDepSubmitted: () => FocusScope.of(context).requestFocus(_countryFocus),
              onCountrySubmitted: () => FocusScope.of(context).requestFocus(_departureFocus),
              stops: _stops,
              onStopsChanged: (s) => setState(() => _stops = s),
              returnDestination: _returnDestination,
              returnCountryCode: _returnCountryCode,
              onReturnChanged: (dest, country) => setState(() {
                _returnDestination = dest;
                _returnCountryCode = country;
              }),
              countryLabel: l.tripsCountry,
              validatorMsg: l.validatorRequired,
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
          ),  // end Form (Tab 1)

          // ── Tab 2: Map ─────────────────────────────────────────
          _EditTripMapTab(
            destinationController: _destinationController,
            countryCode: _countryCode,
            stops: _stops,
            onStopsChanged: (s) => setState(() => _stops = s),
          ),
        ],  // end TabBarView children
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

// ── Route Section ─────────────────────────────────────────────────────────────
/// Renders: [Departure city + country] → [Stops reorderable list] → [Return city + country]
class _RouteSection extends StatefulWidget {
  final TextEditingController depController;
  final FocusNode depFocus;
  final String? depCountryCode;
  final FocusNode depCountryFocus;
  final ValueChanged<String?> onDepCountryChanged;
  final VoidCallback onDepSubmitted;
  final VoidCallback onCountrySubmitted;
  final List<TripStop> stops;
  final ValueChanged<List<TripStop>> onStopsChanged;
  final String? returnDestination;
  final String? returnCountryCode;
  final void Function(String? dest, String? country) onReturnChanged;
  final String countryLabel;
  final String validatorMsg;

  const _RouteSection({
    required this.depController,
    required this.depFocus,
    this.depCountryCode,
    required this.depCountryFocus,
    required this.onDepCountryChanged,
    required this.onDepSubmitted,
    required this.onCountrySubmitted,
    required this.stops,
    required this.onStopsChanged,
    this.returnDestination,
    this.returnCountryCode,
    required this.onReturnChanged,
    required this.countryLabel,
    required this.validatorMsg,
  });

  @override
  State<_RouteSection> createState() => _RouteSectionState();
}

class _RouteSectionState extends State<_RouteSection> {
  bool _showReturnFields = false;
  bool _showAddStop      = false;
  int?  _editStopIndex;          // index of stop currently being edited

  final _addCityCtrl    = TextEditingController();
  final _editCityCtrl   = TextEditingController();
  final _retCtrl        = TextEditingController();
  String? _addCountry;
  String? _editCountry;
  String? _retCountry;

  @override
  void initState() {
    super.initState();
    if (widget.returnDestination != null && widget.returnDestination!.isNotEmpty) {
      _showReturnFields = true;
      _retCtrl.text = widget.returnDestination!;
      _retCountry   = widget.returnCountryCode;
    }
    _retCtrl.addListener(_pushReturnChange);
  }

  @override
  void dispose() {
    _addCityCtrl.dispose();
    _editCityCtrl.dispose();
    _retCtrl.removeListener(_pushReturnChange);
    _retCtrl.dispose();
    super.dispose();
  }

  void _commitStop() {
    final city = _addCityCtrl.text.trim();
    if (city.isNotEmpty) {
      widget.onStopsChanged([...widget.stops, TripStop(city: city, countryCode: _addCountry)]);
    }
    _addCityCtrl.clear();
    setState(() { _addCountry = null; _showAddStop = false; });
  }

  void _removeStop(int i) {
    final updated = [...widget.stops]..removeAt(i);
    widget.onStopsChanged(updated);
    if (_editStopIndex == i) setState(() => _editStopIndex = null);
  }

  void _startEditStop(int i) {
    _editCityCtrl.text = widget.stops[i].city;
    setState(() { _editStopIndex = i; _editCountry = widget.stops[i].countryCode; });
  }

  void _commitEditStop() {
    if (_editStopIndex == null) return;
    final city = _editCityCtrl.text.trim();
    if (city.isNotEmpty) {
      final updated = [...widget.stops];
      updated[_editStopIndex!] = TripStop(city: city, countryCode: _editCountry);
      widget.onStopsChanged(updated);
    }
    setState(() => _editStopIndex = null);
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final updated = [...widget.stops];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    widget.onStopsChanged(updated);
  }

  void _pushReturnChange() {
    widget.onReturnChanged(
      _retCtrl.text.trim().isEmpty ? null : _retCtrl.text.trim(),
      _retCountry,
    );
  }

  Widget _cityCountryRow({
    required TextEditingController cityCtrl,
    required String? countryCode,
    required ValueChanged<String?> onCountryChanged,
    required String hint,
    String? validatorMsg,
    VoidCallback? onSubmitted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: validatorMsg != null
            ? TextFormField(
                controller: cityCtrl,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => onSubmitted?.call(),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.place_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? validatorMsg : null,
              )
            : TextField(
                controller: cityCtrl,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => onSubmitted?.call(),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.place_outlined),
                ),
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: CountryPickerField(
            initialCode: countryCode,
            label: widget.countryLabel,
            onChanged: (c) => onCountryChanged(c?.code),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Departure row ──────────────────────────────────────
        Row(children: [
          const Icon(Icons.flight_takeoff, size: 16, color: TripReadyTheme.teal),
          const SizedBox(width: 6),
          Text(l.tripsDestination, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: TripReadyTheme.textMid)),
          Text(' *', style: const TextStyle(color: TripReadyTheme.danger, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: widget.depController,
                focusNode: widget.depFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => widget.onDepSubmitted(),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.place_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? widget.validatorMsg : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Focus(
                focusNode: widget.depCountryFocus,
                onFocusChange: (hasFocus) {
                  if (hasFocus) Future.delayed(const Duration(milliseconds: 80),
                      () { if (mounted) widget.onCountrySubmitted(); });
                },
                child: CountryPickerField(
                  initialCode: widget.depCountryCode,
                  label: widget.countryLabel,
                  onChanged: (c) => widget.onDepCountryChanged(c?.code),
                ),
              ),
            ),
          ],
        ),

        // ── Stops ──────────────────────────────────────────────
        if (widget.stops.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.route, size: 15, color: TripReadyTheme.teal),
            const SizedBox(width: 6),
            Text('Stops', style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: TripReadyTheme.textMid)),
          ]),
          const SizedBox(height: 4),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: _reorder,
            itemCount: widget.stops.length,
            itemBuilder: (ctx, i) {
              final stop = widget.stops[i];
              if (_editStopIndex == i) {
                // ── Inline edit form ─────────────────────────────
                return Padding(
                  key: ValueKey('stop_edit_$i'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cityCountryRow(
                        cityCtrl: _editCityCtrl,
                        countryCode: _editCountry,
                        onCountryChanged: (c) => setState(() => _editCountry = c),
                        hint: stop.city,
                        onSubmitted: _commitEditStop,
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        FilledButton.tonal(onPressed: _commitEditStop, child: const Text('Save')),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => setState(() => _editStopIndex = null),
                          child: const Text('Cancel'),
                        ),
                      ]),
                    ],
                  ),
                );
              }
              // ── Normal stop row ───────────────────────────────
              return Padding(
                key: ValueKey('stop_$i'),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  ReorderableDragStartListener(
                    index: i,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.drag_handle, color: TripReadyTheme.textLight, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(stop.label, style: const TextStyle(fontSize: 13)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: TripReadyTheme.teal),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Edit stop',
                    onPressed: () => _startEditStop(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: TripReadyTheme.textLight),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => _removeStop(i),
                  ),
                ]),
              );
            },
          ),
        ],

        // ── Add stop inline form ────────────────────────────────
        const SizedBox(height: 8),
        if (_showAddStop) ...[
          Row(children: [
            const Icon(Icons.add_location_outlined, size: 15, color: TripReadyTheme.teal),
            const SizedBox(width: 6),
            Text('Add Stop', style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: TripReadyTheme.textMid)),
          ]),
          const SizedBox(height: 6),
          _cityCountryRow(
            cityCtrl: _addCityCtrl,
            countryCode: _addCountry,
            onCountryChanged: (c) => setState(() => _addCountry = c),
            hint: 'e.g. Amsterdam',
            onSubmitted: _commitStop,
          ),
          const SizedBox(height: 6),
          Row(children: [
            FilledButton.tonal(onPressed: _commitStop, child: const Text('Add')),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () { _addCityCtrl.clear(); setState(() { _addCountry = null; _showAddStop = false; }); },
              child: const Text('Cancel'),
            ),
          ]),
        ] else
          TextButton.icon(
            onPressed: () => setState(() => _showAddStop = true),
            icon: const Icon(Icons.add_location_alt_outlined, size: 16),
            label: const Text('Add Stop'),
            style: TextButton.styleFrom(
              foregroundColor: TripReadyTheme.teal,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),

        // ── Return-from row ────────────────────────────────────
        const SizedBox(height: 4),
        if (_showReturnFields) ...[
          Row(children: [
            const Icon(Icons.flight_land, size: 16, color: TripReadyTheme.navy),
            const SizedBox(width: 6),
            Text('Return from', style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: TripReadyTheme.textMid)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove return destination',
              onPressed: () {
                _retCtrl.clear();
                setState(() { _retCountry = null; _showReturnFields = false; });
                widget.onReturnChanged(null, null);
              },
            ),
          ]),
          const SizedBox(height: 6),
          _cityCountryRow(
            cityCtrl: _retCtrl,
            countryCode: _retCountry,
            onCountryChanged: (c) { setState(() => _retCountry = c); _pushReturnChange(); },
            hint: 'e.g. Paris',
            onSubmitted: _pushReturnChange,
          ),

        ] else
          TextButton.icon(
            onPressed: () => setState(() => _showReturnFields = true),
            icon: const Icon(Icons.flight_land, size: 16),
            label: const Text('Different return destination'),
            style: TextButton.styleFrom(
              foregroundColor: TripReadyTheme.navy,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Edit Trip Map Tab ─────────────────────────────────────────────────────────
// Embedded map tab inside AddEditTripScreen.
// Shows current route, lets user tap to add stops (nearest insertion),
// and has a search bar to pan to a location.

class _EditTripMapTab extends StatefulWidget {
  final TextEditingController destinationController;
  final String? countryCode;
  final List<TripStop> stops;
  final void Function(List<TripStop>) onStopsChanged;

  const _EditTripMapTab({
    required this.destinationController,
    required this.countryCode,
    required this.stops,
    required this.onStopsChanged,
  });

  @override
  State<_EditTripMapTab> createState() => _EditTripMapTabState();
}

class _EditTripMapTabState extends State<_EditTripMapTab>
    with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;

  final _mapController = MapController();
  List<LatLng?> _resolved = [];
  bool _loading = true;
  LatLng? _pendingPin;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(_EditTripMapTab old) {
    super.didUpdateWidget(old);
    if (old.stops.length != widget.stops.length ||
        old.destinationController.text != widget.destinationController.text ||
        old.countryCode != widget.countryCode) {
      _reload();
    }
  }

  @override
  void dispose() { _mapController.dispose(); super.dispose(); }

  Future<LatLng?> _geocode(String query) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search'
          '?format=json&q=${Uri.encodeComponent(query)}&limit=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final list = jsonDecode(res.body) as List;
      if (list.isEmpty) return null;
      final item = list.first as Map<String, dynamic>;
      return LatLng(double.parse(item['lat'] as String),
                    double.parse(item['lon'] as String));
    } catch (_) { return null; }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final dep = widget.destinationController.text.trim();
    if (dep.isEmpty) {
      if (mounted) setState(() { _resolved = []; _loading = false; });
      return;
    }
    final cc = widget.countryCode;
    final futures = <Future<LatLng?>>[];
    futures.add(_geocode(cc != null ? '$dep, $cc' : dep));
    for (final s in widget.stops) futures.add(_geocode(s.label));
    final pts = await Future.wait(futures);
    if (mounted) setState(() { _resolved = pts; _loading = false; });
  }

  List<LatLng> get _pts => _resolved.whereType<LatLng>().toList();

  LatLngBounds _boundsFor(List<LatLng> pts) {
    double minLat = pts.first.latitude,  maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(LatLng(minLat - 0.5, minLng - 0.5),
                        LatLng(maxLat + 0.5, maxLng + 0.5));
  }

  double _dist(LatLng a, LatLng b) {
    final d1 = a.latitude - b.latitude, d2 = a.longitude - b.longitude;
    return d1 * d1 + d2 * d2;
  }

  int _nearestInsertIndex(LatLng pin) {
    final pts = _pts;
    if (pts.length < 2) return widget.stops.length;
    double best = double.infinity; int bestSeg = 0;
    for (var i = 0; i < pts.length - 1; i++) {
      final mid = LatLng((pts[i].latitude + pts[i+1].latitude) / 2,
                         (pts[i].longitude + pts[i+1].longitude) / 2);
      final d = _dist(pin, mid);
      if (d < best) { best = d; bestSeg = i; }
    }
    return bestSeg.clamp(0, widget.stops.length);
  }

  Future<void> _onTap(TapPosition _, LatLng point) async {
    setState(() { _pendingPin = point; _isResolving = true; });
    String? city; String? countryCode;
    try {
      final lat = point.latitude; final lng = point.longitude;
      final url = 'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        city = addr['city'] as String? ?? addr['town'] as String?
            ?? addr['village'] as String? ?? addr['county'] as String?
            ?? (data['name'] as String?);
        countryCode = (addr['country_code'] as String?)?.toUpperCase();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isResolving = false);
    if (city == null) { setState(() => _pendingPin = null); return; }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.add_location_alt, color: TripReadyTheme.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Add stop', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(countryCode != null ? '$city, $countryCode' : city!,
                  style: const TextStyle(fontSize: 14, color: TripReadyTheme.textMid)),
            ])),
          ]),
          const SizedBox(height: 8),
          const Text('Will be inserted at the nearest position in your route.',
              style: TextStyle(fontSize: 12, color: TripReadyTheme.textLight)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: TripReadyTheme.teal),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add stop'),
            )),
          ]),
        ]),
      ),
    );

    if (confirmed != true || !mounted) { setState(() => _pendingPin = null); return; }
    final newStop  = TripStop(city: city!, countryCode: countryCode);
    final idx      = _nearestInsertIndex(point);
    final newStops = [...widget.stops]..insert(idx, newStop);
    widget.onStopsChanged(newStops);
    setState(() => _pendingPin = null);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pts = _pts;

    if (_loading) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: TripReadyTheme.teal),
        SizedBox(height: 12),
        Text('Locating destinations…', style: TextStyle(color: TripReadyTheme.textMid)),
      ]));
    }

    if (pts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Enter a destination in the Form tab to see it on the map.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TripReadyTheme.textMid)),
      ));
    }

    final singlePoint = pts.length == 1;
    final labels = <String>[
      widget.destinationController.text.trim(),
      ...widget.stops.map((s) => s.label),
    ];
    final pinPairs = <(String, LatLng)>[];
    for (var i = 0; i < _resolved.length && i < labels.length; i++) {
      if (_resolved[i] != null) pinPairs.add((labels[i], _resolved[i]!));
    }

    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCameraFit: singlePoint ? null
              : CameraFit.bounds(bounds: _boundsFor(pts), padding: const EdgeInsets.all(56)),
          initialCenter: singlePoint ? pts.first : const LatLng(0, 0),
          initialZoom: singlePoint ? 12.0 : 5.0,
          onTap: _onTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tripready.app',
            maxNativeZoom: 19,
          ),
          if (pts.length >= 2)
            PolylineLayer(polylines: <Polyline>[
              Polyline(points: pts,
                  color: TripReadyTheme.teal.withOpacity(0.8), strokeWidth: 3),
            ]),
          MarkerLayer(markers: pinPairs.asMap().entries.map((e) {
            final idx = e.key; final label = e.value.$1; final pt = e.value.$2;
            final color = idx == 0 ? TripReadyTheme.teal : TripReadyTheme.amber;
            return Marker(
              point: pt, width: 140, height: 64,
              alignment: Alignment.bottomCenter,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                  child: Text(label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ),
                Icon(Icons.location_pin, color: color, size: 28),
              ]),
            );
          }).toList()),
          if (_pendingPin != null)
            MarkerLayer(markers: [
              Marker(
                point: _pendingPin!, width: 44, height: 44,
                alignment: Alignment.bottomCenter,
                child: _isResolving
                    ? Container(width: 32, height: 32,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Padding(padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2, color: TripReadyTheme.teal)))
                    : const Icon(Icons.add_location_alt, color: TripReadyTheme.teal, size: 44),
              ),
            ]),
        ],
      ),

      // Search bar
      Positioned(top: 12, left: 12, right: 12,
        child: MapSearchBar(
          mapController: _mapController,
          zoomOnSelect: 12.0,
          onResultSelected: (r) =>
              _onTap(const TapPosition(Offset.zero, Offset.zero), r.point),
        ),
      ),

      // Tap hint
      if (_pendingPin == null)
        Positioned(bottom: 16, left: 0, right: 0,
          child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: Colors.black54,
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Tap map to add a stop',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          )),
        ),
    ]);
  }
}
