import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/watermark_scaffold.dart';
import '../widgets/app_logo.dart';
import '../widgets/watermark_scaffold.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_ext.dart';
import 'add_edit_trip_screen.dart';
import 'trip_detail_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});
  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrips();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    final trips = await DatabaseHelper.instance.getAllTrips();
    setState(() { _trips = trips; _isLoading = false; });
  }

  List<Trip> get _planned  => _trips.where((t) => t.status == TripStatus.planned).toList();
  List<Trip> get _active   => _trips.where((t) => t.status == TripStatus.active).toList();
  List<Trip> get _archived => _trips.where((t) => t.status == TripStatus.archived).toList();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: AppLogo.whiteLandscape(height: 28),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TripReadyTheme.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: '${l.tripsTabActive} (${_active.length})'),
            Tab(text: '${l.tripsTabPlanned} (${_planned.length})'),
            Tab(text: '${l.tripsTabArchived} (${_archived.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTrip,
        icon: const Icon(Icons.add),
        label: Text(l.tripsNewTrip),
      ),
      body: WatermarkBody(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : TabBarView(controller: _tabController, children: [
              _TripList(trips: _active, emptyIcon: Icons.flight_takeoff,
                emptyTitle: l.dashboardNoActiveTrip,
                emptySubtitle: l.dashboardStartPlanning,
                onTripTap: _openTrip, onSetActive: _setActive, onArchive: _archiveTrip, onEdit: _editTrip, onDelete: _deleteTrip),
              _TripList(trips: _planned, emptyIcon: Icons.map_outlined,
                emptyTitle: l.tripsNoTrips,
                emptySubtitle: l.tripsNoTripsSubtitle,
                buttonLabel: l.tripsAddTrip, onButtonPressed: _addTrip,
                onTripTap: _openTrip, onSetActive: _setActive, onArchive: _archiveTrip, onEdit: _editTrip, onDelete: _deleteTrip),
              _TripList(trips: _archived, emptyIcon: Icons.archive_outlined,
                emptyTitle: l.archiveNoTrips,
                emptySubtitle: l.archiveNoTripsSubtitle,
                onTripTap: _openTrip, onSetActive: _setActive, onArchive: _archiveTrip, onEdit: _editTrip, onDelete: _deleteTrip),
            ]),
      ),
    );
  }

  Future<void> _addTrip() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTripScreen()));
    if (result == true) _loadTrips();
  }

  Future<void> _editTrip(Trip trip) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTripScreen(trip: trip)));
    if (result == true) _loadTrips();
  }

  Future<void> _openTrip(Trip trip) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)));
    _loadTrips();
  }

  Future<void> _setActive(Trip trip) async {
    await DatabaseHelper.instance.setTripActive(trip.id);
    _loadTrips();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${trip.name}" ${context.l.tripsStatusActive}.')));
  }

  Future<void> _archiveTrip(Trip trip) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.tripsArchiveTrip, message: '"${trip.name}"?', confirmLabel: l.tripsArchiveTrip, confirmColor: TripReadyTheme.navy);
    if (confirm == true) { await DatabaseHelper.instance.archiveTrip(trip.id); _loadTrips(); }
  }

  Future<void> _deleteTrip(Trip trip) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.tripsDeleteTrip, message: '"${trip.name}"?', confirmLabel: l.actionDelete);
    if (confirm == true) { await DatabaseHelper.instance.deleteTrip(trip.id); _loadTrips(); }
  }
}

class _TripList extends StatelessWidget {
  final List<Trip> trips;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Function(Trip) onTripTap;
  final Function(Trip) onSetActive;
  final Function(Trip) onArchive;
  final Function(Trip) onEdit;
  final Function(Trip) onDelete;

  const _TripList({required this.trips, required this.emptyIcon, required this.emptyTitle, required this.emptySubtitle,
    this.buttonLabel, this.onButtonPressed, required this.onTripTap, required this.onSetActive,
    required this.onArchive, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) return EmptyState(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle, buttonLabel: buttonLabel, onButtonPressed: onButtonPressed);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: trips.length,
      itemBuilder: (ctx, i) => _TripCard(trip: trips[i],
        onTap: () => onTripTap(trips[i]), onSetActive: () => onSetActive(trips[i]),
        onArchive: () => onArchive(trips[i]), onEdit: () => onEdit(trips[i]), onDelete: () => onDelete(trips[i])),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap, onSetActive, onArchive, onEdit, onDelete;

  const _TripCard({required this.trip, required this.onTap, required this.onSetActive, required this.onArchive, required this.onEdit, required this.onDelete});

  Color get _statusColor {
    switch (trip.status) {
      case TripStatus.active:   return TripReadyTheme.success;
      case TripStatus.planned:  return TripReadyTheme.teal;
      case TripStatus.archived: return TripReadyTheme.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fmt = DateFormat('dd MMM yyyy');
    // Localised status label
    String statusLabel;
    switch (trip.status) {
      case TripStatus.active:   statusLabel = l.tripsStatusActive; break;
      case TripStatus.planned:  statusLabel = l.tripsStatusPlanned; break;
      case TripStatus.archived: statusLabel = l.tripsStatusArchived; break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(trip.name, style: Theme.of(context).textTheme.titleLarge)),
              StatusBadge(label: statusLabel.toUpperCase(), color: _statusColor),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: TripReadyTheme.textMid),
                onSelected: (val) {
                  if (val == 'activate') onSetActive();
                  if (val == 'edit') onEdit();
                  if (val == 'archive') onArchive();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (!trip.isActive && !trip.isArchived)
                    PopupMenuItem(value: 'activate', child: Text(l.tripsSetActive)),
                  if (!trip.isArchived)
                    PopupMenuItem(value: 'edit', child: Text(l.tripsEditTrip)),
                  if (!trip.isArchived)
                    PopupMenuItem(value: 'archive', child: Text(l.tripsArchiveTrip)),
                  PopupMenuItem(value: 'delete', child: Text(l.tripsDeleteTrip, style: const TextStyle(color: TripReadyTheme.danger))),
                ],
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.place_outlined, size: 14, color: TripReadyTheme.teal),
              const SizedBox(width: 4),
              Text(trip.country != null ? '${trip.destination}, ${trip.country}' : trip.destination,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TripReadyTheme.teal, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: TripReadyTheme.textMid),
              const SizedBox(width: 4),
              Text('${fmt.format(trip.departureDate)} → ${fmt.format(trip.returnDate)}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: TripReadyTheme.warmGrey, borderRadius: BorderRadius.circular(10)),
                child: Text('${trip.durationDays}d', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
