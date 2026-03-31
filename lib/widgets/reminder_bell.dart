import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';

/// Bell icon on cards — quick-toggles the reminder.
/// Always reloads from DB on parent rebuild to stay in sync with the sheet.
class ReminderBell extends StatefulWidget {
  final ReminderRefType refType;
  final String refId;
  final int defaultLeadDays;
  final String defaultTimeOfDay;
  final double size;

  const ReminderBell({
    super.key,
    required this.refType,
    required this.refId,
    this.defaultLeadDays  = 1,
    this.defaultTimeOfDay = '08:00',
    this.size             = 18,
  });

  @override
  State<ReminderBell> createState() => _ReminderBellState();
}

class _ReminderBellState extends State<ReminderBell> {
  bool _active  = false;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void didUpdateWidget(ReminderBell old) {
    super.didUpdateWidget(old);
    // Always reload on parent rebuild so the bell stays in sync after the
    // reminder sheet saves/deletes without needing external coordination.
    if (!_loading) _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final active = await ReminderService.instance
        .hasActiveReminder(widget.refType, widget.refId);
    if (mounted) setState(() { _active = active; _loading = false; });
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    final nowOn = await ReminderService.instance.toggleBell(
      refType:         widget.refType,
      refId:           widget.refId,
      defaultLeadDays: widget.defaultLeadDays,
      defaultTimeOfDay: widget.defaultTimeOfDay,
    );
    if (mounted) setState(() { _active = nowOn; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.size + 8, height: widget.size + 8,
        child: const Center(child: SizedBox(width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5))),
      );
    }
    return IconButton(
      icon: Icon(
        _active ? Icons.notifications_active : Icons.notifications_none_outlined,
        size: widget.size,
        color: _active ? TripReadyTheme.amber : TripReadyTheme.textLight,
      ),
      visualDensity: VisualDensity.compact,
      padding:       EdgeInsets.zero,
      constraints:   const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip:       _active ? 'Reminder on — tap to remove' : 'Set reminder',
      onPressed:     _toggle,
    );
  }
}
