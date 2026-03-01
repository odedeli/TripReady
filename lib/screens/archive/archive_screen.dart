import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final trips = await DatabaseHelper.instance.getAllTrips();
    setState(() {
      _archived = trips.where((t) => t.isArchived).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : _archived.isEmpty
              ? const EmptyState(
                  icon: Icons.archive_outlined,
                  title: 'No archived trips',
                  subtitle: 'Trips you archive will appear here for reference.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: _archived.length,
                  itemBuilder: (ctx, i) => _ArchivedTripCard(
                    trip: _archived[i],
                    onOpen: () => _openTrip(_archived[i]),
                    onClone: () => _cloneTrip(_archived[i]),
                    onDelete: () => _deleteTrip(_archived[i]),
                  ),
                ),
    );
  }

  Future<void> _openTrip(Trip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
    );
    _load();
  }

  Future<void> _cloneTrip(Trip trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _CloneTripDialog(trip: trip),
    );
    if (confirm == true) _load();
  }

  Future<void> _deleteTrip(Trip trip) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Trip',
      message: 'Permanently delete "${trip.name}" and all its data? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteTrip(trip.id);
      _load();
    }
  }
}

class _ArchivedTripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onOpen;
  final VoidCallback onClone;
  final VoidCallback onDelete;

  const _ArchivedTripCard({
    required this.trip,
    required this.onOpen,
    required this.onClone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(trip.name,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const StatusBadge(
                  label: 'ARCHIVED',
                  color: TripReadyTheme.warmGrey,
                  textColor: TripReadyTheme.textMid,
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: TripReadyTheme.textMid),
                  onSelected: (val) {
                    if (val == 'clone') onClone();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'clone',
                      child: ListTile(
                        leading: Icon(Icons.copy_outlined),
                        title: Text('Clone to New Trip'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: TripReadyTheme.danger),
                        title: Text('Delete', style: TextStyle(color: TripReadyTheme.danger)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.place_outlined, size: 13, color: TripReadyTheme.teal),
                const SizedBox(width: 4),
                Text(
                  trip.country != null
                      ? '${trip.destination}, ${trip.country}'
                      : trip.destination,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TripReadyTheme.teal, fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: TripReadyTheme.textMid),
                const SizedBox(width: 4),
                Text(
                  '${fmt.format(trip.departureDate)} → ${fmt.format(trip.returnDate)} · ${trip.durationDays}d',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ]),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onClone,
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('Clone to New Trip'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Clone Trip Dialog ─────────────────────────────────────────
class _CloneTripDialog extends StatefulWidget {
  final Trip trip;
  const _CloneTripDialog({required this.trip});

  @override
  State<_CloneTripDialog> createState() => _CloneTripDialogState();
}

class _CloneTripDialogState extends State<_CloneTripDialog> {
  final _nameController = TextEditingController();
  bool _clonePacking = true;
  bool _cloneTasks = true;
  bool _cloneAddresses = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.trip.name} (copy)';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _clone() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final db = DatabaseHelper.instance;
      final rawDb = await db.database;
      final now = DateTime.now();
      final newTripId = const Uuid().v4();

      // Create new trip (planned, same destination)
      final newTrip = widget.trip.copyWith(
        id: newTripId,
        name: _nameController.text.trim(),
        status: TripStatus.planned,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertTrip(newTrip);

      // Clone packing items
      if (_clonePacking) {
        final items = await rawDb.query('packing_items',
            where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final item in items) {
          final newItemId = const Uuid().v4();
          await rawDb.insert('packing_items', {
            ...item,
            'id': newItemId,
            'trip_id': newTripId,
            'status': 'not_packed',
            'created_at': now.toIso8601String(),
          });
        }
      }

      // Clone tasks
      if (_cloneTasks) {
        final tasks = await rawDb.query('tasks',
            where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final task in tasks) {
          await rawDb.insert('tasks', {
            ...task,
            'id': const Uuid().v4(),
            'trip_id': newTripId,
            'status': 'pending',
            'created_at': now.toIso8601String(),
          });
        }
      }

      // Clone addresses
      if (_cloneAddresses) {
        final addrs = await rawDb.query('addresses',
            where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final addr in addrs) {
          await rawDb.insert('addresses', {
            ...addr,
            'id': const Uuid().v4(),
            'trip_id': newTripId,
            'created_at': now.toIso8601String(),
          });
        }
      }

      if (mounted) Navigator.pop(context, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '"${_nameController.text.trim()}" created as a new planned trip.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cloning trip: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clone Trip'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new planned trip based on "${widget.trip.name}".',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'New Trip Name *',
                prefixIcon: Icon(Icons.luggage_outlined),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text('What to copy over:',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _CloneOption(
              label: 'Packing List',
              subtitle: 'All items (reset to unpacked)',
              value: _clonePacking,
              onChanged: (v) => setState(() => _clonePacking = v),
            ),
            _CloneOption(
              label: 'Tasks',
              subtitle: 'All tasks (reset to pending)',
              value: _cloneTasks,
              onChanged: (v) => setState(() => _cloneTasks = v),
            ),
            _CloneOption(
              label: 'Addresses',
              subtitle: 'Hotels, restaurants, landmarks',
              value: _cloneAddresses,
              onChanged: (v) => setState(() => _cloneAddresses = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _clone,
          child: _isSaving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Clone Trip'),
        ),
      ],
    );
  }
}

class _CloneOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _CloneOption({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      activeColor: TripReadyTheme.teal,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
