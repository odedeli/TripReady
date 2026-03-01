import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'add_edit_trip_screen.dart';
import 'packing/packing_list_screen.dart';
import 'tasks/tasks_screen.dart';
import 'addresses/addresses_screen.dart';
import 'documents/documents_screen.dart';
import 'receipts/receipts_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip _trip;
  Map<String, int> _stats = {};
  double _totalExpenses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await DatabaseHelper.instance.getTripStats(_trip.id);
    final expenses = await DatabaseHelper.instance.getTripTotalExpenses(_trip.id);
    final refreshed = await DatabaseHelper.instance.getTripById(_trip.id);
    setState(() {
      _stats = stats;
      _totalExpenses = expenses;
      if (refreshed != null) _trip = refreshed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final packingTotal = _stats['packing_total'] ?? 0;
    final packingPacked = _stats['packing_packed'] ?? 0;
    final tasksTotal = _stats['tasks_total'] ?? 0;
    final tasksDone = _stats['tasks_done'] ?? 0;
    final addressCount = _stats['address_count'] ?? 0;
    final receiptCount = _stats['receipt_count'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        actions: [
          if (!_trip.isArchived)
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _editTrip, tooltip: 'Edit'),
          if (!_trip.isActive && !_trip.isArchived)
            IconButton(icon: const Icon(Icons.flight_takeoff), onPressed: _setActive, tooltip: 'Set Active'),
          if (!_trip.isArchived)
            IconButton(icon: const Icon(Icons.archive_outlined), onPressed: _archiveTrip, tooltip: 'Archive'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _TripHeaderCard(trip: _trip),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Overview'),
                  Row(children: [
                    Expanded(child: StatCard(icon: Icons.backpack_outlined, label: 'Packed', value: '$packingPacked/$packingTotal', accentColor: TripReadyTheme.teal)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(icon: Icons.task_alt_outlined, label: 'Tasks', value: '$tasksDone/$tasksTotal', accentColor: TripReadyTheme.success)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(icon: Icons.payments_outlined, label: 'Spent', value: '${_totalExpenses.toStringAsFixed(0)}', accentColor: TripReadyTheme.amber)),
                  ]),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Trip Sections'),
                  _NavTile(icon: Icons.backpack_outlined, title: 'Packing List',
                    subtitle: packingTotal == 0 ? 'No items yet' : '$packingPacked of $packingTotal packed',
                    color: TripReadyTheme.teal,
                    badge: packingTotal > 0 && packingPacked < packingTotal ? '${packingTotal - packingPacked} left' : null,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => PackingListScreen(trip: _trip))); _loadStats(); }),
                  _NavTile(icon: Icons.task_alt_outlined, title: 'Tasks',
                    subtitle: tasksTotal == 0 ? 'No tasks yet' : '$tasksDone of $tasksTotal done',
                    color: TripReadyTheme.success,
                    badge: tasksTotal > 0 && tasksDone < tasksTotal ? '${tasksTotal - tasksDone} pending' : null,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => TasksScreen(trip: _trip))); _loadStats(); }),
                  _NavTile(icon: Icons.place_outlined, title: 'Addresses',
                    subtitle: addressCount == 0 ? 'No addresses saved' : '$addressCount locations',
                    color: TripReadyTheme.navy,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddressesScreen(trip: _trip))); _loadStats(); }),
                  _NavTile(icon: Icons.receipt_long_outlined, title: 'Receipts & Expenses',
                    subtitle: receiptCount == 0 ? 'No receipts yet' : '$receiptCount receipts · ${_totalExpenses.toStringAsFixed(2)}',
                    color: TripReadyTheme.amber,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptsScreen(trip: _trip))); _loadStats(); }),
                  _NavTile(icon: Icons.attach_file_outlined, title: 'Documents',
                    subtitle: 'Tickets, vouchers, letters',
                    color: TripReadyTheme.textMid,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentsScreen(trip: _trip))); _loadStats(); }),
                  if (_trip.notes != null && _trip.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Notes'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: TripReadyTheme.warmGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: Text(_trip.notes!, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Future<void> _editTrip() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTripScreen(trip: _trip)));
    if (result == true) _loadStats();
  }

  Future<void> _setActive() async {
    await DatabaseHelper.instance.setTripActive(_trip.id);
    _loadStats();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${_trip.name}" is now active.')));
  }

  Future<void> _archiveTrip() async {
    final confirm = await showConfirmDialog(context, title: 'Archive Trip', message: 'Archive "${_trip.name}"?', confirmLabel: 'Archive', confirmColor: TripReadyTheme.navy);
    if (confirm == true && mounted) {
      await DatabaseHelper.instance.archiveTrip(_trip.id);
      Navigator.pop(context, true);
    }
  }
}

class _TripHeaderCard extends StatelessWidget {
  final Trip trip;
  const _TripHeaderCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final daysUntil = trip.departureDate.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [TripReadyTheme.navy, TripReadyTheme.teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: TripReadyTheme.navy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          StatusBadge(label: trip.statusLabel.toUpperCase(), color: trip.isActive ? TripReadyTheme.amber : Colors.white24, textColor: trip.isActive ? TripReadyTheme.navy : Colors.white),
          const Spacer(),
          StatusBadge(label: trip.typeLabel, color: Colors.white12, textColor: Colors.white70),
        ]),
        const SizedBox(height: 12),
        Text(trip.name, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.place_outlined, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(trip.country != null ? '${trip.destination}, ${trip.country}' : trip.destination,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _InfoPill(icon: Icons.calendar_today_outlined, text: fmt.format(trip.departureDate)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 14, color: Colors.white54),
          const SizedBox(width: 8),
          _InfoPill(icon: Icons.calendar_today_outlined, text: fmt.format(trip.returnDate)),
          const Spacer(),
          _InfoPill(icon: Icons.schedule_outlined, text: '${trip.durationDays}d'),
        ]),
        if (!trip.isArchived && daysUntil >= 0) ...[
          const SizedBox(height: 12),
          Text(
            daysUntil == 0 ? '🛫 Departing today!' : daysUntil == 1 ? '🗓 Departing tomorrow!' : '🗓 $daysUntil days until departure',
            style: const TextStyle(color: TripReadyTheme.amberLight, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ]),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _NavTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(badge!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: TripReadyTheme.textLight),
        ]),
      ),
    );
  }
}
