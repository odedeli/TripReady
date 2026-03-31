import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';

/// A self-contained "Reminders" section for add/edit screens.
///
/// Loads existing reminders for [refType]+[refId] on init.
/// When [refId] is null (new item not yet saved), it queues changes
/// and commits them after the caller saves via [commitForRef].
///
/// Usage in edit screen:
///   1. Add `final _reminderKey = GlobalKey<ReminderSectionState>();` to state.
///   2. Place `ReminderSection(key: _reminderKey, refType: ..., refId: trip?.id)`.
///   3. After saving the item, call:
///      `await _reminderKey.currentState?.commitForRef(newId);`
class ReminderSection extends StatefulWidget {
  final ReminderRefType refType;

  /// Null when adding a new item (id not yet known).
  final String? refId;

  /// Default lead days pre-populated when user adds a reminder
  /// (comes from Settings; hardcoded to 1 until Settings EP is built).
  final int defaultLeadDays;
  final String defaultTimeOfDay;

  /// For trip leg reminders: the stop index (-1=departure, N=stop, 999=return).
  /// Null for non-trip reminders (tasks, documents).
  final int? stopIndex;

  const ReminderSection({
    super.key,
    required this.refType,
    this.refId,
    this.stopIndex,
    this.defaultLeadDays  = 1,
    this.defaultTimeOfDay = '08:00',
  });

  @override
  State<ReminderSection> createState() => ReminderSectionState();
}

class ReminderSectionState extends State<ReminderSection> {
  List<_ReminderEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.refId == null) {
      setState(() { _entries = []; _loading = false; });
      return;
    }
    List reminders;
    if (widget.stopIndex != null) {
      // Trip leg: load only reminders for this specific leg
      final r = await ReminderService.instance.getForStop(widget.refId!, widget.stopIndex!);
      reminders = r != null ? [r] : [];
    } else {
      reminders = await ReminderService.instance.getForRef(widget.refType, widget.refId!);
    }
    if (mounted) {
      setState(() {
        _entries = reminders
            .map((r) => _ReminderEntry.fromReminder(r))
            .toList();
        _loading = false;
      });
    }
  }

  void _addEntry() {
    setState(() {
      _entries.add(_ReminderEntry(
        leadDays:   widget.defaultLeadDays,
        timeOfDay:  widget.defaultTimeOfDay,
        isEnabled:  true,
        isNew:      true,
      ));
    });
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
  }

  void _updateEntry(int index, _ReminderEntry updated) {
    setState(() => _entries[index] = updated);
  }

  /// Called by parent after saving the item to persist all reminder changes.
  Future<void> commitForRef(String refId) async {
    final svc = ReminderService.instance;

    // Delete reminders that were removed
    for (final entry in _entries.where((e) => e.toDelete && e.reminderId != null)) {
      await svc.delete(entry.reminderId!);
    }

    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e.toDelete) continue;

      if (e.isNew) {
        // Create new reminder
        await svc.create(
          refType:   widget.refType,
          refId:     refId,
          stopIndex: widget.stopIndex,
          leadDays:  e.leadDays,
          timeOfDay: e.timeOfDay,
          isEnabled: e.isEnabled,
        );
      } else if (e.reminderId != null && e.isDirty) {
        // Update existing
        final existing = await svc.getById(e.reminderId!);
        if (existing != null) {
          await svc.update(existing.copyWith(
            leadDays:  e.leadDays,
            timeOfDay: e.timeOfDay,
            isEnabled: e.isEnabled,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final activeEntries = _entries.where((e) => !e.toDelete).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────
        Row(children: [
          const Icon(Icons.notifications_outlined, size: 15, color: TripReadyTheme.teal),
          const SizedBox(width: 6),
          Text('Reminders', style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: TripReadyTheme.textMid,
          )),
          const Spacer(),
          TextButton.icon(
            onPressed: _addEntry,
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Add', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: TripReadyTheme.teal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ]),
        const SizedBox(height: 4),

        if (activeEntries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('No reminders set.',
              style: TextStyle(fontSize: 12, color: TripReadyTheme.textLight)),
          )
        else
          ...activeEntries.asMap().entries.map((e) {
            final realIndex = _entries.indexOf(e.value);
            return _ReminderRow(
              key: ValueKey(e.value.key),
              entry: e.value,
              onChanged: (updated) => _updateEntry(realIndex, updated),
              onRemove:  () => _removeEntry(realIndex),
            );
          }),
      ],
    );
  }
}

// ── Internal data class ──────────────────────────────────────────────────────

class _ReminderEntry {
  final String key; // widget key for list stability
  final String? reminderId;
  int leadDays;
  String timeOfDay;
  bool isEnabled;
  final bool isNew;
  bool isDirty;
  bool toDelete;

  _ReminderEntry({
    String? key,
    this.reminderId,
    required this.leadDays,
    required this.timeOfDay,
    required this.isEnabled,
    this.isNew    = false,
    this.isDirty  = false,
    this.toDelete = false,
  }) : key = key ?? UniqueKey().toString();

  factory _ReminderEntry.fromReminder(reminder) => _ReminderEntry(
    key:        reminder.id,
    reminderId: reminder.id,
    leadDays:   reminder.leadDays,
    timeOfDay:  reminder.timeOfDay,
    isEnabled:  reminder.isEnabled,
    isNew:      false,
    isDirty:    false,
  );

  _ReminderEntry copyWith({int? leadDays, String? timeOfDay, bool? isEnabled, bool? isDirty, bool? toDelete}) =>
      _ReminderEntry(
        key:        key,
        reminderId: reminderId,
        leadDays:   leadDays  ?? this.leadDays,
        timeOfDay:  timeOfDay ?? this.timeOfDay,
        isEnabled:  isEnabled ?? this.isEnabled,
        isNew:      isNew,
        isDirty:    isDirty   ?? this.isDirty,
        toDelete:   toDelete  ?? this.toDelete,
      );
}

// ── Single reminder row ──────────────────────────────────────────────────────

class _ReminderRow extends StatefulWidget {
  final _ReminderEntry entry;
  final ValueChanged<_ReminderEntry> onChanged;
  final VoidCallback onRemove;

  const _ReminderRow({
    super.key,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<_ReminderRow> {
  late final TextEditingController _leadCtrl;

  @override
  void initState() {
    super.initState();
    _leadCtrl = TextEditingController(text: widget.entry.leadDays.toString());
  }

  @override
  void dispose() { _leadCtrl.dispose(); super.dispose(); }

  Future<void> _pickTime() async {
    final parts = widget.entry.timeOfDay.split(':');
    final initial = TimeOfDay(
      hour:   int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      widget.onChanged(widget.entry.copyWith(timeOfDay: formatted, isDirty: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.entry.isEnabled
            ? TripReadyTheme.teal.withOpacity(0.05)
            : TripReadyTheme.warmGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.entry.isEnabled
              ? TripReadyTheme.teal.withOpacity(0.25)
              : TripReadyTheme.warmGrey,
        ),
      ),
      child: Row(children: [
        // ── Enable toggle ───────────────────────────────────────
        GestureDetector(
          onTap: () => widget.onChanged(
            widget.entry.copyWith(isEnabled: !widget.entry.isEnabled, isDirty: true)),
          child: Icon(
            widget.entry.isEnabled
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            size: 18,
            color: widget.entry.isEnabled ? TripReadyTheme.amber : TripReadyTheme.textLight,
          ),
        ),
        const SizedBox(width: 10),

        // ── Lead days ───────────────────────────────────────────
        SizedBox(
          width: 36,
          child: TextField(
            controller: _leadCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueFormatter(999),
            ],
            onChanged: (v) {
              final days = int.tryParse(v);
              if (days != null && days >= 0) {
                widget.onChanged(widget.entry.copyWith(leadDays: days, isDirty: true));
              }
            },
          ),
        ),
        const SizedBox(width: 6),
        const Text('days before', style: TextStyle(fontSize: 12, color: TripReadyTheme.textMid)),
        const SizedBox(width: 10),

        // ── Time of day ─────────────────────────────────────────
        GestureDetector(
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: TripReadyTheme.warmGrey),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.access_time, size: 13, color: TripReadyTheme.teal),
              const SizedBox(width: 4),
              Text(widget.entry.timeOfDay,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),

        const Spacer(),

        // ── Remove ──────────────────────────────────────────────
        GestureDetector(
          onTap: widget.onRemove,
          child: const Icon(Icons.close, size: 16, color: TripReadyTheme.textLight),
        ),
      ]),
    );
  }
}

// ── Input formatter: cap at max value ────────────────────────────────────────

class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue nv) {
    final val = int.tryParse(nv.text);
    if (val != null && val > max) return old;
    return nv;
  }
}
