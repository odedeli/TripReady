import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/map_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../models/trip_stop.dart';
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
import '../services/app_notifier.dart';

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
  void initState() { super.initState(); _trip = widget.trip; _loadStats(); 
    AppNotifier.instance.addListener(_loadStats);
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats    = await DatabaseHelper.instance.getTripStats(_trip.id);
    final expenses = await DatabaseHelper.instance.getTripTotalExpenses(_trip.id);
    final refreshed = await DatabaseHelper.instance.getTripById(_trip.id);
    setState(() { _stats = stats; _totalExpenses = expenses; if (refreshed != null) _trip = refreshed; _isLoading = false; });
  }

  @override
  void dispose() {
    AppNotifier.instance.removeListener(_loadStats);
    super.dispose();
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
          IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Trip route map',
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => _TripRouteMapScreen(trip: _trip))),
            ),
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
    if (mounted) showAppSnackBar(context, '"${_trip.name}" ${context.l.tripsStatusActive}.');
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
          // Route display — simple or full with stops/return
          if (trip.hasStops || trip.hasReturnDestination)
            Flexible(child: _RouteChips(trip: trip))
          else
            Flexible(child: Text(
              trip.countryDisplay != null
                  ? '${trip.destination}, ${trip.countryDisplay}'
                  : trip.destination,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            )),
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

// ── Route chips widget for trip detail header ─────────────────────────────────
class _RouteChips extends StatelessWidget {
  final Trip trip;
  const _RouteChips({required this.trip});

  /// Returns a space + flag emoji for an ISO country code, or empty string.
  String _flag(String? code) {
    if (code == null || code.length != 2) return '';
    final base = 0x1F1E6 - 0x41;
    final chars = code.toUpperCase().codeUnits;
    return ' ' + String.fromCharCode(base + chars[0]) + String.fromCharCode(base + chars[1]);
  }

  Widget _chip(String label, {bool isEndpoint = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isEndpoint
          ? Colors.white.withOpacity(0.20)
          : Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.white.withOpacity(isEndpoint ? 0.4 : 0.2),
      ),
    ),
    child: Text(label, style: TextStyle(
      color: isEndpoint ? Colors.white : Colors.white70,
      fontSize: isEndpoint ? 13 : 12,
      fontWeight: isEndpoint ? FontWeight.w600 : FontWeight.w400,
    )),
  );

  Widget _arrow() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Icon(Icons.arrow_forward, size: 14, color: Colors.white38),
  );

  @override
  Widget build(BuildContext context) {
    // Compact: "London 🇬🇧" — flag emoji only, no full country name
    final depLabel = '${trip.destination}${_flag(trip.country)}';
    final retLabel = trip.hasReturnDestination
        ? '${trip.returnDestination}${_flag(trip.returnCountry)}'
        : null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 6,
      children: [
        _chip(depLabel, isEndpoint: true),
        ...trip.stops.expand((s) => [_arrow(), _chip('${s.city}${_flag(s.countryCode)}')]),
        if (retLabel != null) ...[_arrow(), _chip(retLabel, isEndpoint: true)],
      ],
    );
  }
}


// ── Trip Route Map ────────────────────────────────────────────────────────────

class _TripRouteMapScreen extends StatefulWidget {
  final Trip trip;
  const _TripRouteMapScreen({required this.trip});
  @override
  State<_TripRouteMapScreen> createState() => _TripRouteMapScreenState();
}

class _TripRouteMapScreenState extends State<_TripRouteMapScreen> {
  final _mapController = MapController();
  late Trip _trip;
  List<LatLng?> _resolved = [];
  bool _loading    = true;
  LatLng? _pendingPin;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _reload();
  }

  @override
  void dispose() { _mapController.dispose(); super.dispose(); }

  // ── Geocoding ──────────────────────────────────────────────────────────────

  Future<LatLng?> _geocode(String query) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search'
          '?format=json&q=${Uri.encodeComponent(query)}&limit=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final list = jsonDecode(res.body) as List;
      if (list.isEmpty) return null;
      final item = list.first as Map<String, dynamic>;
      return LatLng(double.parse(item['lat'] as String),
                    double.parse(item['lon'] as String));
    } catch (_) { return null; }
  }

  Future<List<LatLng?>> _loadPoints() async {
    final trip = _trip;
    final futures = <Future<LatLng?>>[];
    final depQuery = trip.countryDisplay != null
        ? '${trip.destination}, ${trip.countryDisplay}' : trip.destination;
    futures.add(_geocode(depQuery));
    for (final stop in trip.stops) futures.add(_geocode(stop.label));
    if (trip.hasReturnDestination) {
      final retQuery = trip.returnCountryDisplay != null
          ? '${trip.returnDestination}, ${trip.returnCountryDisplay}'
          : trip.returnDestination!;
      futures.add(_geocode(retQuery));
    }
    return Future.wait(futures);
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final pts = await _loadPoints();
    if (mounted) setState(() { _resolved = pts; _loading = false; });
  }

  // ── Nearest insertion ─────────────────────────────────────────────────────
  // Returns the index in trip.stops where the new stop should be inserted,
  // based on which consecutive pair of route points the new pin is closest to.
  int _nearestInsertIndex(LatLng pin, List<LatLng?> routePts) {
    final pts = routePts.whereType<LatLng>().toList();
    if (pts.length < 2) return _trip.stops.length; // append
    double best = double.infinity;
    int bestSeg = 0; // segment index between pts[i] and pts[i+1]
    for (var i = 0; i < pts.length - 1; i++) {
      final mid = LatLng(
        (pts[i].latitude  + pts[i + 1].latitude)  / 2,
        (pts[i].longitude + pts[i + 1].longitude) / 2,
      );
      final d = _dist(pin, mid);
      if (d < best) { best = d; bestSeg = i; }
    }
    // bestSeg 0 = between dep and first stop → insert at index 0
    // bestSeg n = between last stop and return → insert at end
    // Clamp to stops range (segment 0 is dep→stop[0], etc.)
    final stopsOffset = bestSeg; // dep is index 0, so stop index = seg - 0
    return stopsOffset.clamp(0, _trip.stops.length);
  }

  double _dist(LatLng a, LatLng b) {
    final dlat = a.latitude  - b.latitude;
    final dlng = a.longitude - b.longitude;
    return dlat * dlat + dlng * dlng; // squared distance — fine for comparison
  }

  // ── Tap to add stop ───────────────────────────────────────────────────────
  Future<void> _onTap(TapPosition _, LatLng point) async {
    setState(() { _pendingPin = point; _isResolving = true; });

    String? city;
    String? countryCode;

    try {
      final lat = point.latitude; final lng = point.longitude;
      final url = 'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        // At zoom=10 Nominatim returns city-level info
        city = addr['city'] as String?
            ?? addr['town'] as String?
            ?? addr['village'] as String?
            ?? addr['county'] as String?
            ?? (data['name'] as String?);
        // ISO country code from address block
        countryCode = (addr['country_code'] as String?)?.toUpperCase();
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isResolving = false);

    if (city == null) {
      setState(() => _pendingPin = null);
      return;
    }

    // Show confirm bottom sheet
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.add_location_alt, color: TripReadyTheme.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Add stop', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(countryCode != null ? '$city, $countryCode' : city!,
                  style: const TextStyle(fontSize: 14, color: TripReadyTheme.textMid)),
            ])),
          ]),
          const SizedBox(height: 8),
          Text('Will be inserted at the nearest position in your route.',
              style: TextStyle(fontSize: 12, color: TripReadyTheme.textLight)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            )),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: TripReadyTheme.teal),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add stop'),
            )),
          ]),
        ]),
      ),
    );

    if (confirmed != true || !mounted) {
      setState(() => _pendingPin = null);
      return;
    }

    // Insert stop at nearest position and save to DB
    final newStop   = TripStop(city: city!, countryCode: countryCode);
    final insertIdx = _nearestInsertIndex(point, _resolved);
    final newStops  = [..._trip.stops]..insert(insertIdx, newStop);
    final updated   = _trip.copyWith(stops: newStops);
    await DatabaseHelper.instance.updateTrip(updated);
    AppNotifier.instance.notify();

    setState(() { _trip = updated; _pendingPin = null; });
    _reload(); // re-geocode with new stop in route
  }

  // ── Bounds ────────────────────────────────────────────────────────────────
  LatLngBounds _boundsFor(List<LatLng> pts) {
    double minLat = pts.first.latitude,  maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      LatLng(minLat - 0.5, minLng - 0.5),
      LatLng(maxLat + 0.5, maxLng + 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(trip.name)),
        body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: TripReadyTheme.teal),
          SizedBox(height: 14),
          Text('Locating destinations…', style: TextStyle(color: TripReadyTheme.textMid)),
        ])),
      );
    }

    final pts = _resolved.whereType<LatLng>().toList();

    if (pts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(trip.name)),
        body: const Center(child: Text('Could not locate any destinations.',
            style: TextStyle(color: TripReadyTheme.textMid))),
      );
    }

    // Build labelled pin pairs
    final labels = <String>[
      trip.countryDisplay != null ? '${trip.destination} ${trip.countryDisplay}' : trip.destination,
      ...trip.stops.map((s) => s.label),
      if (trip.hasReturnDestination)
        trip.returnCountryDisplay != null
            ? '${trip.returnDestination} ${trip.returnCountryDisplay}'
            : trip.returnDestination!,
    ];
    final pinPairs = <(String, LatLng)>[];
    for (var i = 0; i < _resolved.length && i < labels.length; i++) {
      if (_resolved[i] != null) pinPairs.add((labels[i], _resolved[i]!));
    }

    final singlePoint = pts.length == 1;

    return Scaffold(
      appBar: AppBar(title: Text(trip.name)),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCameraFit: singlePoint ? null
                : CameraFit.bounds(bounds: _boundsFor(pts), padding: const EdgeInsets.all(56)),
            initialCenter: singlePoint ? pts.first : const LatLng(0, 0),
            initialZoom:   singlePoint ? 12.0 : 5.0,
            onTap: _onTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tripready.app',
              maxNativeZoom: 19,
            ),
            if (pts.length >= 2)
              PolylineLayer(polylines: <Polyline>[
                Polyline(points: pts,
                    color: TripReadyTheme.teal.withOpacity(0.8), strokeWidth: 3),
              ]),
            // Existing route markers
            MarkerLayer(markers: pinPairs.asMap().entries.map((e) {
              final idx = e.key; final label = e.value.$1; final pt = e.value.$2;
              final isFirst = idx == 0;
              final isLast  = idx == pinPairs.length - 1 && trip.hasReturnDestination;
              final color = isFirst ? TripReadyTheme.teal
                  : isLast ? TripReadyTheme.navy : TripReadyTheme.amber;
              return Marker(
                point: pt, width: 140, height: 64,
                alignment: Alignment.bottomCenter,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                    child: Text(label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ),
                  Icon(Icons.location_pin, color: color, size: 28),
                ]),
              );
            }).toList()),
            // Pending new pin
            if (_pendingPin != null)
              MarkerLayer(markers: [
                Marker(
                  point: _pendingPin!, width: 44, height: 44,
                  alignment: Alignment.bottomCenter,
                  child: _isResolving
                      ? Container(
                          width: 32, height: 32,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Padding(padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(strokeWidth: 2,
                                  color: TripReadyTheme.teal)))
                      : const Icon(Icons.add_location_alt,
                            color: TripReadyTheme.teal, size: 44),
                ),
              ]),
          ],
        ),

        // Search bar
        Positioned(
          top: 12, right: 12, left: 12,
          child: MapSearchBar(
            mapController: _mapController,
            zoomOnSelect: 12.0,
            onResultSelected: (r) {
              // Simulate a tap at the result point — triggers resolve + confirm sheet
              _onTap(const TapPosition(Offset.zero, Offset.zero), r.point);
            },
          ),
        ),

        // Legend + tap hint
        Positioned(
          top: 80, left: 12,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _LegendItem(color: TripReadyTheme.teal,  label: 'Departure'),
                if (trip.stops.isNotEmpty)
                  _LegendItem(color: TripReadyTheme.amber,
                      label: 'Stop${trip.stops.length > 1 ? "s" : ""}'),
                if (trip.hasReturnDestination)
                  _LegendItem(color: TripReadyTheme.navy, label: 'Return from'),
              ]),
            ),
          ),
        ),

        // Tap hint at bottom
        if (_pendingPin == null)
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text('Tap map to add a stop',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
      ]),
    );
  }
}
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.location_pin, color: color, size: 16),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]),
  );
}
