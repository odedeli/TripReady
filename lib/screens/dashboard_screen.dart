import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/trip.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/trip_route_display.dart';
import '../widgets/app_logo.dart';
import '../widgets/watermark_scaffold.dart';
import '../services/localization_ext.dart';
import 'trip_detail_screen.dart';
import 'packing/packing_list_screen.dart';
import 'tasks/tasks_screen.dart';
import 'receipts/receipts_screen.dart';
import 'addresses/addresses_screen.dart';
import 'documents/documents_screen.dart';
import '../main.dart' show tabNotifier;
import '../services/app_notifier.dart';
import '../widgets/notification_center.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Trip? _activeTrip;
  Map<String, int> _stats = {};
  double _totalExpenses = 0;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadData(); 
    AppNotifier.instance.addListener(_loadData);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final trip = await DatabaseHelper.instance.getActiveTrip();
    Map<String, int> stats = {};
    double expenses = 0;
    if (trip != null) {
      stats = await DatabaseHelper.instance.getTripStats(trip.id);
      expenses = await DatabaseHelper.instance.getTripTotalExpenses(trip.id);
    }
    setState(() { _activeTrip = trip; _stats = stats; _totalExpenses = expenses; _isLoading = false; });
  }

  @override
  void dispose() {
    AppNotifier.instance.removeListener(_loadData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: AppLogo.whiteLandscape(height: 28),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _loadData, tooltip: l.actionUpdate),
          Builder(builder: (ctx) => const NotificationBell()),
        ],
      ),
      endDrawer: const NotificationEndDrawer(),
      body: WatermarkBody(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : RefreshIndicator(
                onRefresh: _loadData,
                child: _activeTrip == null
                    ? _NoActiveTripView(onGoToTrips: () => tabNotifier.value = 1)
                    : _DashboardContent(trip: _activeTrip!, stats: _stats, totalExpenses: _totalExpenses, onOpenTrip: _openActiveTrip, onReload: _loadData),
              ),
      ),
    );
  }

  Future<void> _openActiveTrip() async {
    if (_activeTrip == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: _activeTrip!)));
    _loadData();
  }
}

class _NoActiveTripView extends StatelessWidget {
  final VoidCallback onGoToTrips;
  const _NoActiveTripView({required this.onGoToTrips});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return EmptyState(
      icon: Icons.flight_outlined,
      title: l.dashboardNoActiveTrip,
      subtitle: l.dashboardStartPlanning,
      buttonLabel: l.navMyTrips,
      onButtonPressed: onGoToTrips,
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final Trip trip;
  final Map<String, int> stats;
  final double totalExpenses;
  final VoidCallback onOpenTrip;
  final VoidCallback onReload;

  const _DashboardContent({required this.trip, required this.stats, required this.totalExpenses, required this.onOpenTrip, required this.onReload});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fmt = DateFormat('dd MMM yyyy');
    final daysUntil = trip.departureDate.difference(DateTime.now()).inDays;
    final daysLeft = trip.returnDate.difference(DateTime.now()).inDays;

    final packingTotal  = stats['packing_total']  ?? 0;
    final packingPacked = stats['packing_packed'] ?? 0;
    final packingPercent = packingTotal == 0 ? 0.0 : packingPacked / packingTotal;
    final tasksTotal = stats['tasks_total'] ?? 0;
    final tasksDone = stats['tasks_done'] ?? 0;
    final tasksPercent = tasksTotal == 0 ? 0.0 : tasksDone / tasksTotal;

    String countdownText;
    if (daysUntil > 0) {
      countdownText = '🗓  ${l.dashboardDaysUntil(daysUntil)}';
    } else if (daysLeft >= 0) {
      countdownText = '✈️  ${l.dashboardDepartingToday}';
    } else {
      countdownText = '✅  ${l.dashboardTasksDone}';
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GestureDetector(
          onTap: onOpenTrip,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [TripReadyTheme.navy, TripReadyTheme.teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: TripReadyTheme.navy.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: TripReadyTheme.amber, borderRadius: BorderRadius.circular(20)),
                  child: Text(l.dashboardActiveTrip.toUpperCase(), style: const TextStyle(color: TripReadyTheme.navy, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
                const Spacer(),
                const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
              ]),
              const SizedBox(height: 12),
              Text(trip.name, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, height: 1.1)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.place_outlined, size: 14, color: Colors.white60),
                const SizedBox(width: 4),
                TripRouteDisplay(trip: trip,
                    style: const TextStyle(fontSize: 14),
                    color: Colors.white70),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white60),
                const SizedBox(width: 4),
                Text('${fmt.format(trip.departureDate)} → ${fmt.format(trip.returnDate)} · ${trip.durationDays}d', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                child: Text(countdownText, style: const TextStyle(color: TripReadyTheme.amberLight, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        // ── Combined overview section ──────────────────────────
        SectionHeader(title: l.tripDetailOverview),
        // Row 1 — packing progress + task progress (tappable, double-tap or single tap)
        Row(children: [
          Expanded(child: _TappableProgressCard(
            title: l.dashboardPacked, icon: Icons.backpack_outlined,
            done: packingPacked, total: packingTotal, percent: packingPercent, color: TripReadyTheme.teal,
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => PackingListScreen(trip: trip))); onReload(); },
          )),
          const SizedBox(width: 12),
          Expanded(child: _TappableProgressCard(
            title: l.dashboardTasksDone, icon: Icons.task_alt_outlined,
            done: tasksDone, total: tasksTotal, percent: tasksPercent, color: TripReadyTheme.success,
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => TasksScreen(trip: trip))); onReload(); },
          )),
        ]),
        const SizedBox(height: 12),
        // Row 2 — expenses (receipts + total) + addresses + documents
        Row(children: [
          Expanded(child: _TappableStatCard(
            icon: Icons.payments_outlined, label: l.dashboardExpenses,
            line1: '${stats['receipt_count'] ?? 0} / \$${totalExpenses == 0 ? '0' : totalExpenses.toStringAsFixed(0)}',
            accentColor: TripReadyTheme.textMid,
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptsScreen(trip: trip))); onReload(); },
          )),
          const SizedBox(width: 12),
          Expanded(child: _TappableStatCard(
            icon: Icons.place_outlined, label: l.addressesTitle,
            line1: '${stats['address_count'] ?? 0}',
            accentColor: TripReadyTheme.textMid,
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AddressesScreen(trip: trip))); onReload(); },
          )),
          const SizedBox(width: 12),
          Expanded(child: _TappableStatCard(
            icon: Icons.attach_file_outlined, label: l.documentsTitle,
            line1: '${stats['document_count'] ?? 0}',
            accentColor: TripReadyTheme.textMid,
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentsScreen(trip: trip))); onReload(); },
          )),
        ]),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: onOpenTrip, icon: const Icon(Icons.open_in_new), label: Text(l.tripDetailSections)),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _TappableProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int done, total;
  final double percent;
  final Color color;
  final VoidCallback onTap;

  const _TappableProgressCard({required this.title, required this.icon, required this.done,
      required this.total, required this.percent, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    onDoubleTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TripReadyTheme.cardBg, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: TripReadyTheme.navy.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 18, color: TripReadyTheme.textMid), const SizedBox(width: 6),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
          Icon(Icons.chevron_right, size: 14, color: TripReadyTheme.textLight),
        ]),
        const SizedBox(height: 12),
        Center(child: CircularPercentIndicator(
          radius: 44, lineWidth: 7,
          percent: percent.clamp(0.0, 1.0),
          center: Text(total == 0 ? '—' : '${(percent * 100).round()}%',
              style: Theme.of(context).textTheme.titleMedium),
          progressColor: color, backgroundColor: color.withOpacity(0.12),
          circularStrokeCap: CircularStrokeCap.round,
        )),
        const SizedBox(height: 10),
        Center(child: Text(total == 0 ? '—' : '$done / $total',
            style: Theme.of(context).textTheme.bodySmall)),
      ]),
    ),
  );
}

class _TappableStatCard extends StatelessWidget {
  final IconData icon;
  final String label, line1;
  final Color accentColor;
  final VoidCallback onTap;

  const _TappableStatCard({required this.icon, required this.label, required this.line1,
      required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    onDoubleTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TripReadyTheme.cardBg, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: TripReadyTheme.navy.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: TripReadyTheme.textMid),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
          Icon(Icons.chevron_right, size: 14, color: TripReadyTheme.textLight),
        ]),
        const SizedBox(height: 12),
        Center(child: Text(
          line1,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: TripReadyTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        )),
        const SizedBox(height: 2),
      ]),
    ),
  );
}
