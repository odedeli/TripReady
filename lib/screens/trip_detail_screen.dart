import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_ext.dart';
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
  void initState() { super.initState(); _trip = widget.trip; _loadStats(); }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats    = await DatabaseHelper.instance.getTripStats(_trip.id);
    final expenses = await DatabaseHelper.instance.getTripTotalExpenses(_trip.id);
    final refreshed = await DatabaseHelper.instance.getTripById(_trip.id);
    setState(() { _stats = stats; _totalExpenses = expenses; if (refreshed != null) _trip = refreshed; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final packingTotal  = _stats['packing_total'] ?? 0;
    final packingPacked = _stats['packing_packed'] ?? 0;
    final tasksTotal    = _stats['tasks_total'] ?? 0;
    final tasksDone     = _stats['tasks_done'] ?? 0;
    final addressCount  = _stats['address_count'] ?? 0;
    final receiptCount  = _stats['receipt_count'] ?? 0;
    final documentCount = _stats['document_count'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        actions: [
          if (!_trip.isArchived)
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _editTrip, tooltip: l.actionEdit),
          if (!_trip.isActive && !_trip.isArchived)
            IconButton(icon: const Icon(Icons.flight_takeoff), onPressed: _setActive, tooltip: l.tripsSetActive),
          if (!_trip.isArchived)
            IconButton(icon: const Icon(Icons.archive_outlined), onPressed: _archiveTrip, tooltip: l.tripsArchiveTrip),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'Sections',
            onSelected: (val) async {
              switch (val) {
                case 'packing':   await Navigator.push(context, MaterialPageRoute(builder: (_) => PackingListScreen(trip: _trip))); break;
                case 'tasks':     await Navigator.push(context, MaterialPageRoute(builder: (_) => TasksScreen(trip: _trip))); break;
                case 'addresses': await Navigator.push(context, MaterialPageRoute(builder: (_) => AddressesScreen(trip: _trip))); break;
                case 'receipts':  await Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptsScreen(trip: _trip))); break;
                case 'documents': await Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentsScreen(trip: _trip))); break;
              }
              _loadStats();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'packing',   child: ListTile(leading: Icon(Icons.backpack_outlined,    color: TripReadyTheme.teal),    title: Text(l.packingTitle),   contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'tasks',     child: ListTile(leading: Icon(Icons.task_alt_outlined,    color: TripReadyTheme.success), title: Text(l.tasksTitle),     contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'addresses', child: ListTile(leading: Icon(Icons.place_outlined,       color: TripReadyTheme.navy),    title: Text(l.addressesTitle), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'receipts',  child: ListTile(leading: Icon(Icons.receipt_long_outlined,color: TripReadyTheme.amber),   title: Text(l.receiptsTitle),  contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'documents', child: ListTile(leading: Icon(Icons.attach_file_outlined, color: TripReadyTheme.textMid), title: Text(l.documentsTitle), contentPadding: EdgeInsets.zero)),
            ],
          ),
          HomeButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(padding: const EdgeInsets.all(20), children: [
                // 10.1 — tapping header opens edit screen
                GestureDetector(
                  onTap: _trip.isArchived ? null : _editTrip,
                  child: _TripHeaderCard(trip: _trip),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: l.tripDetailOverview),
                // Row 1 — packing + tasks
                Row(children: [
                  Expanded(child: _TappableStatCard(
                    icon: Icons.backpack_outlined, label: l.dashboardPacked,
                    value: '$packingPacked/$packingTotal', accentColor: TripReadyTheme.textMid,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => PackingListScreen(trip: _trip))); _loadStats(); },
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _TappableStatCard(
                    icon: Icons.task_alt_outlined, label: l.tasksTitle,
                    value: '$tasksDone/$tasksTotal', accentColor: TripReadyTheme.textMid,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => TasksScreen(trip: _trip))); _loadStats(); },
                  )),
                ]),
                const SizedBox(height: 10),
                // Row 2 — expenses + addresses + documents
                Row(children: [
                  Expanded(child: _TappableStatCard(
                    icon: Icons.payments_outlined, label: l.dashboardSpent,
                    value: '$receiptCount / \$${_totalExpenses.toStringAsFixed(0)}',
                    accentColor: TripReadyTheme.textMid,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptsScreen(trip: _trip))); _loadStats(); },
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _TappableStatCard(
                    icon: Icons.place_outlined, label: l.addressesTitle,
                    value: '$addressCount', accentColor: TripReadyTheme.textMid,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddressesScreen(trip: _trip))); _loadStats(); },
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _TappableStatCard(
                    icon: Icons.attach_file_outlined, label: l.documentsTitle,
                    value: '$documentCount', accentColor: TripReadyTheme.textMid,
                    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentsScreen(trip: _trip))); _loadStats(); },
                  )),
                ]),
                if (_trip.notes != null && _trip.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SectionHeader(title: l.fieldNotes),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: TripReadyTheme.warmGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                    child: Text(_trip.notes!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
                const SizedBox(height: 40),
              ]),
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${_trip.name}" ${context.l.tripsStatusActive}.')));
  }

  Future<void> _archiveTrip() async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.tripsArchiveTrip, message: '"${_trip.name}"?', confirmLabel: l.tripsArchiveTrip, confirmColor: TripReadyTheme.navy);
    if (confirm == true && mounted) { await DatabaseHelper.instance.archiveTrip(_trip.id); Navigator.pop(context, true); }
  }
}

// ── Tappable stat card ────────────────────────────────────────────────────────
class _TappableStatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color accentColor;
  final VoidCallback onTap;

  const _TappableStatCard({required this.icon, required this.label, required this.value,
      required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTap: onTap,
    onTap: onTap,
    child: StatCard(icon: icon, label: label, value: value, accentColor: accentColor),
  );
}


class _TripHeaderCard extends StatelessWidget {
  final Trip trip;
  const _TripHeaderCard({required this.trip});

  String _localizedTypeLabel(TripType t, AppLocalizations l) {
    switch (t) {
      case TripType.leisure:   return l.tripTypeLeisure;
      case TripType.business:  return l.tripTypeBusiness;
      case TripType.family:    return l.tripTypeFamily;
      case TripType.adventure: return l.tripTypeAdventure;
      case TripType.medical:   return l.tripTypeMedical;
      case TripType.other:     return l.tripTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fmt = DateFormat('dd MMM yyyy');
    final daysUntil = trip.departureDate.difference(DateTime.now()).inDays;

    String statusLabel;
    switch (trip.status) {
      case TripStatus.active:   statusLabel = l.tripsStatusActive; break;
      case TripStatus.planned:  statusLabel = l.tripsStatusPlanned; break;
      case TripStatus.archived: statusLabel = l.tripsStatusArchived; break;
    }

    String? countdown;
    if (!trip.isArchived && daysUntil >= 0) {
      if (daysUntil == 0)      countdown = l.tripDetailDepartingToday;
      else if (daysUntil == 1) countdown = l.tripDetailDepartingTomorrow;
      else                     countdown = l.tripDetailDaysUntil(daysUntil);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [TripReadyTheme.navy, TripReadyTheme.teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: TripReadyTheme.navy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          StatusBadge(label: statusLabel.toUpperCase(), color: trip.isActive ? TripReadyTheme.amber : Colors.white24, textColor: trip.isActive ? TripReadyTheme.navy : Colors.white),
          const Spacer(),
          StatusBadge(label: _localizedTypeLabel(trip.type, l), color: Colors.white12, textColor: Colors.white70),
        ]),
        const SizedBox(height: 12),
        Text(trip.name, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.place_outlined, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(trip.countryDisplay != null ? '${trip.destination}, ${trip.countryDisplay}' : trip.destination, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
        if (countdown != null) ...[
          const SizedBox(height: 12),
          Text(countdown, style: const TextStyle(color: TripReadyTheme.amberLight, fontWeight: FontWeight.w600, fontSize: 13)),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: Colors.white70), const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ]),
  );
}

