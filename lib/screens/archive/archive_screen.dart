import 'package:flutter/material.dart';
import '../../widgets/watermark_scaffold.dart';
import '../../widgets/app_logo.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/localization_ext.dart';
import '../trip_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Trip> _archived = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final trips = await DatabaseHelper.instance.getAllTrips();
    setState(() { _archived = trips.where((t) => t.isArchived).toList(); _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: AppLogo.whiteLandscape(height: 28), centerTitle: true, leading: HomeButton()),
      body: WatermarkBody(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : _archived.isEmpty
                ? EmptyState(icon: Icons.archive_outlined, title: l.archiveNoTrips, subtitle: l.archiveNoTripsSubtitle)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    itemCount: _archived.length,
                    itemBuilder: (ctx, i) => _ArchivedTripCard(trip: _archived[i],
                      onOpen: () => _openTrip(_archived[i]), onClone: () => _cloneTrip(_archived[i]), onDelete: () => _deleteTrip(_archived[i]))),
      ),
    );
  }

  Future<void> _openTrip(Trip trip) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)));
    _load();
  }

  Future<void> _cloneTrip(Trip trip) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => _CloneTripDialog(trip: trip));
    if (confirm == true) _load();
  }

  Future<void> _deleteTrip(Trip trip) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.tripsDeleteTrip, message: '"${trip.name}"?', confirmLabel: l.actionDelete);
    if (confirm == true) { await DatabaseHelper.instance.deleteTrip(trip.id); _load(); }
  }
}

class _ArchivedTripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onOpen, onClone, onDelete;

  const _ArchivedTripCard({required this.trip, required this.onOpen, required this.onClone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fmt = DateFormat('dd MMM yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(trip.name, style: Theme.of(context).textTheme.titleLarge)),
            StatusBadge(label: l.tripsStatusArchived.toUpperCase(), color: TripReadyTheme.warmGrey, textColor: TripReadyTheme.textMid),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: TripReadyTheme.textMid),
              onSelected: (val) { if (val == 'clone') onClone(); if (val == 'delete') onDelete(); },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'clone', child: ListTile(leading: const Icon(Icons.copy_outlined), title: Text(l.archiveCloneTrip), contentPadding: EdgeInsets.zero)),
                PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline, color: TripReadyTheme.danger), title: Text(l.actionDelete, style: const TextStyle(color: TripReadyTheme.danger)), contentPadding: EdgeInsets.zero)),
              ],
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.place_outlined, size: 13, color: TripReadyTheme.teal), const SizedBox(width: 4),
            Text(trip.countryDisplay != null ? '${trip.destination}, ${trip.countryDisplay}' : trip.destination,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TripReadyTheme.teal, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 12, color: TripReadyTheme.textMid), const SizedBox(width: 4),
            Text('${fmt.format(trip.departureDate)} → ${fmt.format(trip.returnDate)} · ${trip.durationDays}d', style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: onClone, icon: const Icon(Icons.copy_outlined, size: 16), label: Text(l.archiveCloneTrip),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontSize: 13))),
        ])),
      ),
    );
  }
}

class _CloneTripDialog extends StatefulWidget {
  final Trip trip;
  const _CloneTripDialog({required this.trip});
  @override
  State<_CloneTripDialog> createState() => _CloneTripDialogState();
}

class _CloneTripDialogState extends State<_CloneTripDialog> {
  final _nameController = TextEditingController();
  bool _clonePacking = true, _cloneTasks = true, _cloneAddresses = true, _isSaving = false;

  @override
  void initState() { super.initState(); _nameController.text = '${widget.trip.name} (copy)'; }
  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  Future<void> _clone() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final db = DatabaseHelper.instance;
      final rawDb = await db.database;
      final now = DateTime.now();
      final newTripId = const Uuid().v4();

      final newTrip = widget.trip.copyWith(id: newTripId, name: _nameController.text.trim(), status: TripStatus.planned, createdAt: now, updatedAt: now);
      await db.insertTrip(newTrip);

      if (_clonePacking) {
        final items = await rawDb.query('packing_items', where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final item in items) await rawDb.insert('packing_items', {...item, 'id': const Uuid().v4(), 'trip_id': newTripId, 'status': 'not_packed', 'created_at': now.toIso8601String()});
      }
      if (_cloneTasks) {
        final tasks = await rawDb.query('tasks', where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final task in tasks) await rawDb.insert('tasks', {...task, 'id': const Uuid().v4(), 'trip_id': newTripId, 'status': 'pending', 'created_at': now.toIso8601String()});
      }
      if (_cloneAddresses) {
        final addrs = await rawDb.query('addresses', where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final addr in addrs) await rawDb.insert('addresses', {...addr, 'id': const Uuid().v4(), 'trip_id': newTripId, 'created_at': now.toIso8601String()});
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { if (mounted) setState(() => _isSaving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AlertDialog(
      title: Text(l.archiveCloneTitle),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('"${widget.trip.name}"', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        TextField(controller: _nameController, autofocus: true,
          decoration: InputDecoration(labelText: '${l.archiveCloneNewName} *', prefixIcon: const Icon(Icons.luggage_outlined))),
        const SizedBox(height: 16),
        Text(l.archiveClonePacking, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        CheckboxListTile(contentPadding: EdgeInsets.zero, value: _clonePacking, onChanged: (v) => setState(() => _clonePacking = v ?? false),
          title: Text(l.archiveClonePacking), subtitle: Text(l.archiveClonePackingSubtitle), activeColor: TripReadyTheme.teal, controlAffinity: ListTileControlAffinity.leading),
        CheckboxListTile(contentPadding: EdgeInsets.zero, value: _cloneTasks, onChanged: (v) => setState(() => _cloneTasks = v ?? false),
          title: Text(l.archiveCloneTasks), subtitle: Text(l.archiveCloneTasksSubtitle), activeColor: TripReadyTheme.teal, controlAffinity: ListTileControlAffinity.leading),
        CheckboxListTile(contentPadding: EdgeInsets.zero, value: _cloneAddresses, onChanged: (v) => setState(() => _cloneAddresses = v ?? false),
          title: Text(l.archiveCloneAddresses), subtitle: Text(l.archiveCloneAddressesSubtitle), activeColor: TripReadyTheme.teal, controlAffinity: ListTileControlAffinity.leading),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _clone,
          child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l.archiveCloneTrip),
        ),
      ],
    );
  }
}
