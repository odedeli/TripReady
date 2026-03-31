import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';

// ── Public row widget ─────────────────────────────────────────────────────────

/// Bell + label row used inside edit dialogs (tasks, documents, etc.).
/// Works for both saved items (refId != null) and new unsaved items.
/// For new items call [ItemReminderRowState.commitForRef] after parent saves.
class ItemReminderRow extends StatefulWidget {
  final ReminderRefType refType;
  final String? refId;
  final String label;
  final DateTime? contextDate;

  const ItemReminderRow({
    super.key,
    required this.refType,
    required this.refId,
    this.label = 'Reminder',
    this.contextDate,
  });

  @override
  State<ItemReminderRow> createState() => ItemReminderRowState();
}

class ItemReminderRowState extends State<ItemReminderRow> {
  bool _active  = false;
  bool _loading = true;

  // Pending config for new (unsaved) items
  bool?   _pendingEnabled;
  int?    _pendingLeadDays;
  String? _pendingTimeOfDay;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void didUpdateWidget(ItemReminderRow old) {
    super.didUpdateWidget(old);
    if (old.refId != widget.refId || old.refType != widget.refType) _load();
  }

  Future<void> _load() async {
    if (widget.refId == null) {
      if (mounted) setState(() { _active = _pendingEnabled == true; _loading = false; });
      return;
    }
    final active = await ReminderService.instance
        .hasActiveReminder(widget.refType, widget.refId!);
    if (mounted) setState(() { _active = active; _loading = false; });
  }

  /// Called by parent after saving a new item to write the pending reminder.
  Future<void> commitForRef(String newRefId) async {
    if (_pendingEnabled == true &&
        _pendingLeadDays != null && _pendingTimeOfDay != null) {
      await ReminderService.instance.create(
        refType:   widget.refType,
        refId:     newRefId,
        leadDays:  _pendingLeadDays!,
        timeOfDay: _pendingTimeOfDay!,
        isEnabled: true,
      );
    }
    _pendingEnabled = _pendingLeadDays = _pendingTimeOfDay = null;
  }

  Future<void> _open() async {
    if (widget.refId == null) {
      // New item — sheet returns a result instead of writing to DB
      final result = await showModalBottomSheet<_SheetResult?>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ItemReminderSheet(
          refType:         widget.refType,
          refId:           null,
          label:           widget.label,
          contextDate:     widget.contextDate,
          initialEnabled:  _pendingEnabled,
          initialLeadDays: _pendingLeadDays,
          initialTimeOfDay: _pendingTimeOfDay,
        ),
      );
      if (result != null && mounted) {
        setState(() {
          _pendingEnabled   = result.isEnabled;
          _pendingLeadDays  = result.leadDays;
          _pendingTimeOfDay = result.timeOfDay;
          _active           = result.isEnabled;
        });
      }
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ItemReminderSheet(
        refType:     widget.refType,
        refId:       widget.refId,
        label:       widget.label,
        contextDate: widget.contextDate,
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _loading ? null : _open,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          if (_loading)
            const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 1.5))
          else
            Icon(
              _active ? Icons.notifications_active : Icons.notifications_none_outlined,
              size: 20,
              color: _active ? TripReadyTheme.amber : TripReadyTheme.textLight,
            ),
          const SizedBox(width: 10),
          Expanded(child: Text(
            _active ? 'Reminder set — tap to edit' : 'Set a reminder',
            style: TextStyle(
              fontSize: 14,
              color: _active ? TripReadyTheme.amber : TripReadyTheme.textLight,
              fontWeight: _active ? FontWeight.w600 : FontWeight.w400,
            ),
          )),
          const Icon(Icons.chevron_right, size: 18, color: TripReadyTheme.textLight),
        ]),
      ),
    );
  }
}

// ── Sheet result for new-item pending mode ────────────────────────────────────

class _SheetResult {
  final bool isEnabled;
  final int leadDays;
  final String timeOfDay;
  _SheetResult({required this.isEnabled, required this.leadDays, required this.timeOfDay});
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class ItemReminderSheet extends StatefulWidget {
  final ReminderRefType refType;
  final String? refId;
  final String label;
  final DateTime? contextDate;
  final bool?   initialEnabled;
  final int?    initialLeadDays;
  final String? initialTimeOfDay;

  const ItemReminderSheet({
    super.key,
    required this.refType,
    required this.refId,
    required this.label,
    this.contextDate,
    this.initialEnabled,
    this.initialLeadDays,
    this.initialTimeOfDay,
  });

  @override
  State<ItemReminderSheet> createState() => _ItemReminderSheetState();
}

class _ItemReminderSheetState extends State<ItemReminderSheet> {
  bool _loading  = true;
  bool _saving   = false;
  bool _hasReminder = false;
  String? _reminderId;
  int     _leadDays  = 1;
  String  _timeOfDay = '08:00';
  bool    _isEnabled = false;
  DateTime? _reminderDate;

  final _leadCtrl    = TextEditingController();
  final _dateTxtCtrl = TextEditingController();

  static final _fmt        = DateFormat('dd/MM/yyyy');
  static final _fmtDisplay = DateFormat('dd MMM yyyy');

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _leadCtrl.dispose(); _dateTxtCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (widget.refId == null) {
      final ld  = widget.initialLeadDays  ?? 1;
      final tod = widget.initialTimeOfDay ?? '08:00';
      final en  = widget.initialEnabled   ?? false;
      if (mounted) setState(() {
        _leadDays = ld; _timeOfDay = tod; _isEnabled = en;
        _leadCtrl.text = ld.toString();
        _reminderDate = _calcDate(ld);
        _dateTxtCtrl.text = _reminderDate != null ? _fmt.format(_reminderDate!) : '';
        _loading = false;
      });
      return;
    }
    final reminders = await ReminderService.instance
        .getForRef(widget.refType, widget.refId!);
    final r = reminders.isNotEmpty ? reminders.first : null;
    if (mounted) setState(() {
      _hasReminder = r != null;
      _reminderId  = r?.id;
      _leadDays    = r?.leadDays  ?? 1;
      _timeOfDay   = r?.timeOfDay ?? '08:00';
      _isEnabled   = r != null && r.isEnabled;
      _leadCtrl.text = _leadDays.toString();
      _reminderDate = _calcDate(_leadDays);
      _dateTxtCtrl.text = _reminderDate != null ? _fmt.format(_reminderDate!) : '';
      _loading = false;
    });
  }

  // ── Bidirectional date ↔ days ─────────────────────────────────────────────

  DateTime? _calcDate(int days) =>
      widget.contextDate?.subtract(Duration(days: days));

  int _calcDays(DateTime d) {
    if (widget.contextDate == null) return 0;
    final diff = widget.contextDate!.difference(d).inDays;
    return diff < 0 ? 0 : diff;
  }

  void _onLeadDaysChanged(String v) {
    final d = int.tryParse(v);
    if (d != null && d >= 0) setState(() {
      _leadDays = d;
      _reminderDate = _calcDate(d);
      if (_reminderDate != null) _dateTxtCtrl.text = _fmt.format(_reminderDate!);
    });
  }

  void _onDatePicked(DateTime picked) => setState(() {
    _reminderDate = picked;
    _dateTxtCtrl.text = _fmt.format(picked);
    _leadDays = _calcDays(picked);
    _leadCtrl.text = _leadDays.toString();
  });

  DateTime? _parseDate(String v) {
    final parts = v.trim().replaceAll('-', '/').replaceAll('.', '/').split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    if (y < 2020 || y > 2040 || m < 1 || m > 12 || d < 1 || d > 31) return null;
    try { return DateTime(y, m, d); } catch (_) { return null; }
  }

  Future<void> _pickTime() async {
    final p = _timeOfDay.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: int.tryParse(p[0]) ?? 8, minute: int.tryParse(p[1]) ?? 0),
    );
    if (picked != null && mounted) setState(() {
      _timeOfDay =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _pickDate() async {
    final initial = _reminderDate ?? widget.contextDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020), lastDate: DateTime(2040),
      helpText: 'Select reminder date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: TripReadyTheme.teal, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (picked != null) _onDatePicked(picked);
  }

  Future<void> _ok() async {
    // New-item mode — return result to parent
    if (widget.refId == null) {
      Navigator.pop(context, _SheetResult(
          isEnabled: _isEnabled, leadDays: _leadDays, timeOfDay: _timeOfDay));
      return;
    }
    setState(() => _saving = true);
    try {
      final svc = ReminderService.instance;
      if (!_isEnabled) {
        if (_reminderId != null) await svc.delete(_reminderId!);
      } else if (_hasReminder && _reminderId != null) {
        final existing = await svc.getById(_reminderId!);
        if (existing != null) {
          await svc.update(existing.copyWith(
              leadDays: _leadDays, timeOfDay: _timeOfDay, isEnabled: true));
        }
      } else {
        await svc.create(
          refType:   widget.refType,
          refId:     widget.refId!,
          leadDays:  _leadDays,
          timeOfDay: _timeOfDay,
          isEnabled: true,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasDate = widget.contextDate != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24,
          24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        // Header row
        Row(children: [
          Icon(_isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
              color: _isEnabled ? TripReadyTheme.amber : TripReadyTheme.textLight, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (widget.contextDate != null)
              Text(_fmtDisplay.format(widget.contextDate!),
                  style: const TextStyle(fontSize: 12, color: TripReadyTheme.textLight)),
          ])),
          Switch(
            value: _isEnabled,
            activeColor: TripReadyTheme.amber,
            onChanged: _loading ? null : (v) => setState(() => _isEnabled = v),
          ),
        ]),
        const SizedBox(height: 20),
        if (_loading)
          const CircularProgressIndicator()
        else ...[
          _ReminderTimingRow(
            leadCtrl:          _leadCtrl,
            dateTxtCtrl:       _dateTxtCtrl,
            timeOfDay:         _timeOfDay,
            hasContextDate:    hasDate,
            onLeadDaysChanged: _onLeadDaysChanged,
            onDateTyped: (v) { final p = _parseDate(v); if (p != null) _onDatePicked(p); },
            onPickDate:        _pickDate,
            onPickTime:        _pickTime,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _ok,
              style: FilledButton.styleFrom(backgroundColor: TripReadyTheme.teal),
              child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('OK'),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Shared timing row ─────────────────────────────────────────────────────────

class _ReminderTimingRow extends StatefulWidget {
  final TextEditingController leadCtrl;
  final TextEditingController dateTxtCtrl;
  final String timeOfDay;
  final bool hasContextDate;
  final ValueChanged<String> onLeadDaysChanged;
  final ValueChanged<String> onDateTyped;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const _ReminderTimingRow({
    required this.leadCtrl, required this.dateTxtCtrl,
    required this.timeOfDay, required this.hasContextDate,
    required this.onLeadDaysChanged, required this.onDateTyped,
    required this.onPickDate, required this.onPickTime,
  });
  @override
  State<_ReminderTimingRow> createState() => _ReminderTimingRowState();
}

class _ReminderTimingRowState extends State<_ReminderTimingRow> {
  bool _dateInvalid = false;
  static const _h = 42.0;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: TripReadyTheme.teal, width: 1.5),
  );
  static const _focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: TripReadyTheme.teal, width: 2),
  );
  static const _fill = InputDecoration(
    isDense: true, filled: true, fillColor: Color(0xFFF2FAFE),
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    enabledBorder: _border, focusedBorder: _focusBorder,
  );

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      // Days box
      SizedBox(width: 52, height: _h, child: TextField(
        controller: widget.leadCtrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
            color: TripReadyTheme.textDark),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: widget.onLeadDaysChanged,
        decoration: _fill.copyWith(
          hintText: '0',
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        ),
      )),
      const SizedBox(width: 8),
      Text(
        widget.hasContextDate ? 'days before, on' : 'days before, at',
        style: const TextStyle(fontSize: 13, color: TripReadyTheme.textMid),
      ),
      const SizedBox(width: 8),
      // Date field (only when contextDate is provided)
      if (widget.hasContextDate) ...[
        SizedBox(width: 120, height: _h, child: TextField(
          controller: widget.dateTxtCtrl,
          keyboardType: TextInputType.datetime,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: _dateInvalid ? TripReadyTheme.danger : TripReadyTheme.teal),
          onChanged: (v) {
            if (_dateInvalid) setState(() => _dateInvalid = false);
            widget.onDateTyped(v);
          },
          onSubmitted: (v) {
            final parts = v.trim().replaceAll('-','/').replaceAll('.','/').split('/');
            if (parts.length == 3) { widget.onDateTyped(v); setState(() => _dateInvalid = false); }
            else if (v.trim().isNotEmpty) setState(() => _dateInvalid = true);
          },
          decoration: _fill.copyWith(
            hintText: 'dd/mm/yyyy',
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: _dateInvalid ? TripReadyTheme.danger : TripReadyTheme.teal,
                  width: _dateInvalid ? 2 : 1.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: _dateInvalid ? TripReadyTheme.danger : TripReadyTheme.teal, width: 2)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month_outlined, size: 15, color: TripReadyTheme.teal),
              padding: EdgeInsets.zero, visualDensity: VisualDensity.compact,
              onPressed: widget.onPickDate,
            ),
          ),
        )),
        const SizedBox(width: 6),
        const Text('at', style: TextStyle(fontSize: 13, color: TripReadyTheme.textMid)),
        const SizedBox(width: 6),
      ],
      // Time pill
      GestureDetector(
        onTap: widget.onPickTime,
        child: Container(
          width: 120, height: _h,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2FAFE),
            border: Border.all(color: TripReadyTheme.teal, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time, size: 15, color: TripReadyTheme.teal),
            const SizedBox(width: 5),
            Text(widget.timeOfDay,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: TripReadyTheme.teal)),
          ]),
        ),
      ),
    ]);
  }
}
