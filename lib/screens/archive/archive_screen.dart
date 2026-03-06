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
import '../../services/app_notifier.dart';

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
    AppNotifier.instance.addListener(_load);
  }

  @override
  void dispose() {
    AppNotifier.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final trips = await DatabaseHelper.instance.getAllTrips();
    setState(() { _archived = trips.where((t) => t.isArchived).toList(); _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: AppLogo.whiteLandscape(height: 28), centerTitle: true, leading: HomeButton(), actions: [IconButton(icon: const Icon(Icons.refresh_outlined), tooltip: context.l.actionUpdate, onPressed: _load)]),
      body: WatermarkBody(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : _archived.isEmpty
                ? EmptyState(icon: Icons.archive_outlined, title: l.archiveNoTrips, subtitle: l.archiveNoTripsSubtitle)
                : RefreshIndicator(
                    color: TripReadyTheme.teal,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      itemCount: _archived.length,
                      itemBuilder: (ctx, i) => _ArchivedTripCard(trip: _archived[i],
                        onOpen: () => _openTrip(_archived[i]), onClone: () => _cloneTrip(_archived[i]), onDelete: () => _deleteTrip(_archived[i]))),
                  ),
      ),
    );
  }

  Future<void> _openTrip(Trip trip) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)));
    _load();
  }

  Future<void> _cloneTrip(Trip trip) async {
    final newTrip = await showDialog<Trip>(
        context: context, builder: (_) => _CloneTripDialog(trip: trip));
    if (newTrip == null) return;
    _load();
    if (!mounted) return;
    final l = context.l;
    showAppSnackBar(
      context,
      '"${newTrip.name}" ${l.tripsStatusPlanned.toLowerCase()}.',
      action: SnackBarAction(
        label: l.archiveCloneOpenTrip,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => TripDetailScreen(trip: newTrip)));
          _load();
        },
      ),
      duration: const Duration(seconds: 6),
    );
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
            Text(trip.routeDisplay,
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
  late DateTime _departureDate;
  late DateTime _returnDate;
  bool _clonePacking = true, _cloneTasks = true, _cloneAddresses = true, _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.trip.name} (copy)';
    // Default new dates: keep same duration, starting from today
    final duration = widget.trip.returnDate.difference(widget.trip.departureDate);
    _departureDate = DateTime.now().add(const Duration(days: 1));
    _returnDate    = _departureDate.add(duration);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDeparture) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate : _returnDate,
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
    if (picked == null) return;
    setState(() {
      if (isDeparture) {
        _departureDate = picked;
        if (_returnDate.isBefore(_departureDate)) {
          _returnDate = _departureDate.add(
              widget.trip.returnDate.difference(widget.trip.departureDate));
        }
      } else {
        if (!picked.isBefore(_departureDate)) _returnDate = picked;
      }
    });
  }

  Future<void> _clone() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    Trip? newTrip;
    try {
      final db    = DatabaseHelper.instance;
      final rawDb = await db.database;
      final now   = DateTime.now();
      final newId = const Uuid().v4();

      newTrip = widget.trip.copyWith(
        id: newId,
        name: _nameController.text.trim(),
        status: TripStatus.planned,
        departureDate: _departureDate,
        returnDate: _returnDate,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertTrip(newTrip);

      if (_clonePacking) {
        final items = await rawDb.query('packing_items',
            where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final item in items) {
          await rawDb.insert('packing_items', {
            ...item,
            'id': const Uuid().v4(),
            'trip_id': newId,
            'status': 'not_packed',
            'created_at': now.toIso8601String(),
          });
        }
      }
      if (_cloneTasks) {
        final tasks = await rawDb.query('tasks',
            where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final task in tasks) {
          // Copy only non-date fields — due_date, reminder_date, completed_at excluded
          final stripped = Map<String, Object?>.from(task)
            ..remove('due_date')
            ..remove('reminder_date')
            ..remove('completed_at')
            ..remove('updated_at');
          await rawDb.insert('tasks', {
            ...stripped,
            'id': const Uuid().v4(),
            'trip_id': newId,
            'status': 'pending',
            'created_at': now.toIso8601String(),
          });
        }
      }
      if (_cloneAddresses) {
        final addrs = await rawDb.query('addresses',
            where: 'trip_id = ?', whereArgs: [widget.trip.id]);
        for (final addr in addrs) {
          await rawDb.insert('addresses', {
            ...addr,
            'id': const Uuid().v4(),
            'trip_id': newId,
            'created_at': now.toIso8601String(),
          });
        }
      }
      if (mounted) Navigator.pop(context, newTrip);
    } catch (e) {
      if (mounted) showAppSnackBar(context, '$e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l   = context.l;
    final fmt = DateFormat('dd MMM yyyy');
    final dur = _returnDate.difference(_departureDate).inDays + 1;

    return AlertDialog(
      title: Text(l.archiveCloneTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('"${widget.trip.name}"',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          // ── New trip name ──────────────────────────────────────
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
                labelText: '${l.archiveCloneNewName} *',
                prefixIcon: const Icon(Icons.luggage_outlined)),
          ),
          const SizedBox(height: 20),

          // ── Dates section ──────────────────────────────────────
          Text(l.archiveCloneDates,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _DateTile(
              label: l.archiveCloneDeparture,
              date: _departureDate,
              fmt: fmt,
              onTap: () => _pickDate(true),
            )),
            const SizedBox(width: 8),
            // Duration badge
            Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_forward,
                  size: 14, color: TripReadyTheme.textLight),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TripReadyTheme.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${dur}d',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TripReadyTheme.teal)),
              ),
            ]),
            const SizedBox(width: 8),
            Expanded(child: _DateTile(
              label: l.archiveCloneReturn,
              date: _returnDate,
              fmt: fmt,
              onTap: () => _pickDate(false),
            )),
          ]),
          const SizedBox(height: 20),

          // ── What to copy ───────────────────────────────────────
          Text(l.archiveClonePacking,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _clonePacking,
            onChanged: (v) => setState(() => _clonePacking = v ?? false),
            title: Text(l.archiveClonePacking),
            subtitle: Text(l.archiveClonePackingSubtitle),
            activeColor: TripReadyTheme.teal,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _cloneTasks,
            onChanged: (v) => setState(() => _cloneTasks = v ?? false),
            title: Text(l.archiveCloneTasks),
            subtitle: Text(l.archiveCloneTasksSubtitle),
            activeColor: TripReadyTheme.teal,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _cloneAddresses,
            onChanged: (v) => setState(() => _cloneAddresses = v ?? false),
            title: Text(l.archiveCloneAddresses),
            subtitle: Text(l.archiveCloneAddressesSubtitle),
            activeColor: TripReadyTheme.teal,
            controlAffinity: ListTileControlAffinity.leading,
          ),

        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(l.actionCancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _clone,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l.archiveCloneTrip),
        ),
      ],
    );
  }
}

// ── Compact date tile for clone dialog ───────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateFormat fmt;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date,
      required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: TripReadyTheme.teal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TripReadyTheme.teal.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: TripReadyTheme.textMid)),
        const SizedBox(height: 2),
        Row(children: [
          Expanded(child: Text(fmt.format(date),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600))),
          Icon(Icons.calendar_month_outlined,
              size: 14, color: TripReadyTheme.teal),
        ]),
      ]),
    ),
  );
}
