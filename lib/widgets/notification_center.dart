import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_notification.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

// ── AppBar bell with unread badge ─────────────────────────────────────────────

/// Place inside AppBar actions wrapped in a [Builder] for correct context.
/// Tapping opens the [NotificationEndDrawer] via Scaffold.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override
  State<NotificationBell> createState() => NotificationBellState();
}

class NotificationBellState extends State<NotificationBell> {
  int _unread = 0;

  @override
  void initState() { super.initState(); reload(); }

  Future<void> reload() async {
    final count = await NotificationService.instance.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => Scaffold.of(context).openEndDrawer(),
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text(_unread > 99 ? '99+' : '$_unread',
            style: const TextStyle(fontSize: 10)),
        backgroundColor: TripReadyTheme.danger,
        textColor: Colors.white,
        child: Icon(
          _unread > 0
              ? Icons.notifications_active
              : Icons.notifications_none_outlined,
          color: _unread > 0 ? TripReadyTheme.amber : Colors.white,
        ),
      ),
    );
  }
}

// ── End drawer ────────────────────────────────────────────────────────────────

/// Add as Scaffold.endDrawer.
class NotificationEndDrawer extends StatefulWidget {
  const NotificationEndDrawer({super.key});
  @override
  State<NotificationEndDrawer> createState() => _NotificationEndDrawerState();
}

class _NotificationEndDrawerState extends State<NotificationEndDrawer> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final items = await NotificationService.instance.getAll();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  void _refreshBell() {
    context.findAncestorStateOfType<NotificationBellState>()?.reload();
  }

  Future<void> _markAllRead() async {
    await NotificationService.instance.markAllRead();
    await _load(); _refreshBell();
  }

  Future<void> _clearAll() async {
    await NotificationService.instance.clearAll();
    await _load(); _refreshBell();
  }

  Future<void> _dismiss(String id) async {
    await NotificationService.instance.dismiss(id);
    await _load(); _refreshBell();
  }

  Future<void> _markRead(String id) async {
    await NotificationService.instance.markRead(id);
    await _load(); _refreshBell();
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !n.isRead).length;
    return Drawer(
      width: 320,
      child: SafeArea(child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
          decoration: BoxDecoration(
            color: TripReadyTheme.navy,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Notifications${unread > 0 ? ' ($unread)' : ''}',
              style: const TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.w700),
            )),
            if (unread > 0)
              TextButton(
                onPressed: _markAllRead,
                child: const Text('Mark all read',
                    style: TextStyle(color: TripReadyTheme.amber, fontSize: 12)),
              ),
            if (_items.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined,
                    color: Colors.white70, size: 20),
                tooltip: 'Clear all',
                onPressed: _clearAll,
              ),
          ]),
        ),
        // List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(
                  color: TripReadyTheme.teal))
              : _items.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 56),
                      itemBuilder: (_, i) => _NotificationTile(
                        notification: _items[i],
                        onDismiss: () => _dismiss(_items[i].id),
                        onTap:     () => _markRead(_items[i].id),
                      ),
                    ),
        ),
      ])),
    );
  }
}

// ── Tile with swipe-to-dismiss ────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss, onTap;
  const _NotificationTile({
    required this.notification, required this.onDismiss, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: TripReadyTheme.danger.withOpacity(0.85),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isUnread
                ? TripReadyTheme.teal.withOpacity(0.04) : Colors.transparent,
            border: isUnread
                ? const Border(left: BorderSide(color: TripReadyTheme.teal, width: 3))
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: _iconBg(notification.refType), shape: BoxShape.circle),
              child: Icon(_iconFor(notification.refType),
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(notification.title,
                    style: TextStyle(fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                        color: TripReadyTheme.textDark))),
                Text(_relTime(notification.createdAt),
                    style: const TextStyle(fontSize: 11, color: TripReadyTheme.textLight)),
              ]),
              const SizedBox(height: 2),
              Text(notification.body,
                  style: const TextStyle(fontSize: 12, color: TripReadyTheme.textMid)),
            ])),
          ]),
        ),
      ),
    );
  }

  IconData _iconFor(ReminderRefType t) {
    switch (t) {
      case ReminderRefType.trip:     return Icons.flight_takeoff;
      case ReminderRefType.tripStop: return Icons.place_outlined;
      case ReminderRefType.task:     return Icons.task_alt_outlined;
      case ReminderRefType.document: return Icons.description_outlined;
      case ReminderRefType.packing:  return Icons.luggage_outlined;
    }
  }

  Color _iconBg(ReminderRefType t) {
    switch (t) {
      case ReminderRefType.trip:     return TripReadyTheme.teal;
      case ReminderRefType.tripStop: return TripReadyTheme.navy;
      case ReminderRefType.task:     return TripReadyTheme.amber;
      case ReminderRefType.document: return Colors.deepPurple.shade300;
      case ReminderRefType.packing:  return Colors.teal.shade600;
    }
  }

  String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.notifications_none_outlined,
          size: 48, color: TripReadyTheme.textLight.withOpacity(0.4)),
      const SizedBox(height: 12),
      const Text('No notifications',
          style: TextStyle(fontSize: 15, color: TripReadyTheme.textLight)),
      const SizedBox(height: 4),
      const Text('Reminders will appear here when triggered.',
          style: TextStyle(fontSize: 12, color: TripReadyTheme.textLight),
          textAlign: TextAlign.center),
    ]),
  );
}
