import 'dart:convert';
import '../../widgets/map_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import '../../database/database_helper.dart';
import '../../database/trip_details_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/localization_ext.dart';
import '../../services/app_notifier.dart';
import 'map_picker_screen.dart';

class AddressesScreen extends StatefulWidget {
  final Trip trip;
  const AddressesScreen({super.key, required this.trip});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<TripAddress> _addresses = [];
  bool _isLoading = true;
  AddressCategory? _filterCategory;
  bool _showRoute = false;
  LatLng? _mapInitCenter;
  TripAddress? _focusAddress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
    AppNotifier.instance.addListener(_load);
  }

  @override
  void dispose() {
    AppNotifier.instance.removeListener(_load);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final addresses = await DatabaseHelper.instance.getAddresses(widget.trip.id);
    setState(() { _addresses = addresses; _isLoading = false; });
  }

  List<TripAddress> get _withCoords =>
      _addresses.where((a) => a.hasCoords).toList();

  Map<AddressCategory, List<TripAddress>> get _grouped {
    final filtered = _filterCategory != null
        ? _addresses.where((a) => a.category == _filterCategory).toList()
        : _addresses;
    final Map<AddressCategory, List<TripAddress>> grouped = {};
    for (final addr in filtered) grouped.putIfAbsent(addr.category, () => []).add(addr);
    return Map.fromEntries(grouped.entries.toList()
      ..sort((a, b) => a.key.name.compareTo(b.key.name)));
  }

  String _catLabel(AddressCategory c, AppLocalizations l) {
    switch (c) {
      case AddressCategory.hotel:      return l.addressesCatHotel;
      case AddressCategory.airport:    return l.addressesCatAirport;
      case AddressCategory.restaurant: return l.addressesCatRestaurant;
      case AddressCategory.landmark:   return l.addressesCatLandmark;
      case AddressCategory.office:     return l.addressesCatOffice;
      case AddressCategory.hospital:   return l.addressesCatHospital;
      case AddressCategory.transport:  return l.addressesCatTransport;
      case AddressCategory.shopping:   return l.addressesCatShopping;
      case AddressCategory.other:      return l.addressesCatOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isArchived = widget.trip.isArchived;
    final usedCategories = _addresses.map((a) => a.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.addressesTitle),
        actions: [
          if (_tabController.index == 1 && _withCoords.length >= 2)
            IconButton(
              icon: Icon(_showRoute ? Icons.route : Icons.route_outlined),
              tooltip: _showRoute ? 'Hide route' : 'Show route',
              onPressed: () => setState(() => _showRoute = !_showRoute),
            ),
          HomeButton(),
          if (usedCategories.length > 1 && _tabController.index == 0)
            PopupMenuButton<AddressCategory?>(
              icon: const Icon(Icons.filter_list_outlined),
              onSelected: (cat) => setState(() => _filterCategory = cat),
              itemBuilder: (_) => [
                PopupMenuItem(value: null, child: Text(l.actionClear)),
                const PopupMenuDivider(),
                ...usedCategories.map((c) => PopupMenuItem(value: c, child: Text(_catLabel(c, l)))),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TripReadyTheme.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: 'List (${_addresses.length})'),
            Tab(text: 'Map (${_withCoords.length})'),
          ],
        ),
      ),
      floatingActionButton: isArchived ? null : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab_map',
            onPressed: _addFromMap,
            tooltip: 'Pick location on map',
            mini: true,
            child: const Icon(Icons.map_outlined),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'fab_add',
            onPressed: _addAddress,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(l.addressesAddAddress),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : TabBarView(
              controller: _tabController,
              children: [
                // ── List tab ─────────────────────────────────────
                RefreshIndicator(
                  color: TripReadyTheme.teal,
                  onRefresh: _load,
                  child: _addresses.isEmpty
                      ? EmptyState(
                          icon: Icons.place_outlined,
                          title: l.addressesNoAddresses,
                          subtitle: isArchived ? l.archiveNoTripsSubtitle : l.addressesNoAddressesSubtitle,
                          buttonLabel: isArchived ? null : l.addressesAddAddress,
                          onButtonPressed: isArchived ? null : _addAddress,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: _grouped.length,
                          itemBuilder: (ctx, i) {
                            final entry = _grouped.entries.elementAt(i);
                            return _AddressCategoryGroup(
                              category: entry.key,
                              addresses: entry.value,
                              isArchived: isArchived,
                              catLabel: _catLabel(entry.key, l),
                              onEdit: _editAddress,
                              onDelete: _deleteAddress,
                              onOpenMap: _openMap,
                              onOpenWebsite: _openWebsite,
                              onViewOnMap: _viewOnMap,
                            );
                          },
                        ),
                ),

                // ── Map tab ──────────────────────────────────────
                _withCoords.isEmpty
                    ? EmptyState(
                        icon: Icons.map_outlined,
                        title: 'No locations on map',
                        subtitle: 'Add addresses and pick their location on the map to see them here.',
                        buttonLabel: isArchived ? null : l.addressesAddAddress,
                        onButtonPressed: isArchived ? null : _addAddress,
                      )
                    : _AddressesMapView(
                        addresses: _withCoords,
                        showRoute: _showRoute,
                        onOpenMap: _openMap,
                        tripId: widget.trip.id,
                        isArchived: widget.trip.isArchived,
                        focusAddress: _focusAddress,
                      ),
              ],
            ),
    );
  }

  Future<void> _addFromMap() async {
    // Center on trip destination if geocodable
    final trip = widget.trip;
    final query = trip.countryDisplay != null
        ? '${trip.destination}, ${trip.countryDisplay}'
        : trip.destination;
    // Geocode destination for initial map center
    double? initLat, initLng;
    try {
      final url = 'https://nominatim.openstreetmap.org/search'
          '?format=json&q=${Uri.encodeComponent(query)}&limit=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          initLat = double.parse(item['lat'] as String);
          initLng = double.parse(item['lon'] as String);
        }
      }
    } catch (_) {}
    if (!mounted) return;
    if (initLat != null && initLng != null) {
      setState(() => _mapInitCenter = LatLng(initLat!, initLng!));
    }
    // Switch to map tab
    _tabController.animateTo(1);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    // Show hint snackbar
    showAppSnackBar(context, 'Long-press the map to add a new place');
  }

  Future<void> _addAddress() async {
    await showDialog<bool>(
        context: context,
        builder: (_) => _AddEditAddressDialog(tripId: widget.trip.id));
  }

  Future<void> _editAddress(TripAddress address) async {
    await showDialog<bool>(
        context: context,
        builder: (_) => _AddEditAddressDialog(tripId: widget.trip.id, address: address));
  }

  Future<void> _deleteAddress(TripAddress address) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context,
        title: l.actionDelete, message: '"${address.name}"?', confirmLabel: l.actionDelete);
    if (confirm == true) await DatabaseHelper.instance.deleteAddress(address.id);
  }

  Future<void> _openMap(TripAddress address) async {
    Uri uri;
    if (address.hasCoords) {
      // Prefer geo URI — lets the OS choose Maps/Waze/etc.
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${address.latitude},${address.longitude}');
    } else if (address.mapLink != null && address.mapLink!.isNotEmpty) {
      uri = Uri.parse(address.mapLink!);
    } else {
      final query = Uri.encodeComponent('${address.name} ${address.address ?? ''}');
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _viewOnMap(TripAddress address) {
    setState(() => _focusAddress = address);
    _tabController.animateTo(1);
  }

  Future<void> _openWebsite(TripAddress address) async {
    if (address.website == null || address.website!.isEmpty) return;
    final uri = Uri.parse(address.website!);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Map view ─────────────────────────────────────────────────────────────────

class _AddressesMapView extends StatefulWidget {
  final List<TripAddress> addresses;
  final bool showRoute;
  final Function(TripAddress) onOpenMap;
  final String tripId;
  final bool isArchived;
  final TripAddress? focusAddress; // if set, zoom to this pin on build
  final LatLng? initCenter;

  const _AddressesMapView({
    required this.addresses,
    required this.showRoute,
    required this.onOpenMap,
    required this.tripId,
    required this.isArchived,
    this.focusAddress,
    this.initCenter,
  });

  @override
  State<_AddressesMapView> createState() => _AddressesMapViewState();
}

class _AddressesMapViewState extends State<_AddressesMapView> {
  final _mapController = MapController();
  TripAddress? _selectedAddress;
  LatLng? _newPin;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    // Pre-select focused address on first build
    if (widget.focusAddress != null) {
      _selectedAddress = widget.focusAddress;
    }
  }

  @override
  void didUpdateWidget(_AddressesMapView old) {
    super.didUpdateWidget(old);
    if (widget.focusAddress != null &&
        widget.focusAddress?.id != old.focusAddress?.id) {
      setState(() => _selectedAddress = widget.focusAddress);
      _zoomToAddress(widget.focusAddress!);
    }
  }

  void _zoomToAddress(TripAddress a) {
    if (!a.hasCoords) return;
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        _mapController.move(LatLng(a.latitude!, a.longitude!), 16.0);
      }
    });
  }

  @override
  void dispose() { _mapController.dispose(); super.dispose(); }

  Future<void> _onLongPress(TapPosition _, LatLng point) async {
    if (widget.isArchived) return;
    setState(() { _newPin = point; _isResolving = true; _selectedAddress = null; });

    String? resolvedName;
    String? resolvedAddress;
    String? resolvedPhone;
    String? resolvedWebsite;
    AddressCategory resolvedCategory = AddressCategory.other;

    try {
      final lat = point.latitude;
      final lng = point.longitude;
      final url = 'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lng&zoom=17&addressdetails=1&extratags=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data  = jsonDecode(res.body) as Map<String, dynamic>;
        final addr  = data['address']   as Map<String, dynamic>? ?? {};
        final tags  = data['extratags'] as Map<String, dynamic>? ?? {};

        // Name strategy:
        // 1. data['name'] is the OSM element name — good when pin lands ON a POI,
        //    but returns street name when pin is near a road.
        // 2. If data['name'] looks like a road (class == 'highway' or type is
        //    a road type), do a nearby POI search instead.
        final rawName  = data['name'] as String?;
        final osmClass = data['class'] as String? ?? '';
        final osmType  = data['type']  as String? ?? '';
        const roadTypes = ['motorway','trunk','primary','secondary','tertiary',
                           'residential','service','unclassified','road',
                           'footway','path','cycleway','track'];
        final isRoad = osmClass == 'highway' || roadTypes.contains(osmType);

        if (!isRoad && rawName != null && rawName.isNotEmpty) {
          resolvedName = rawName;
        } else {
          // Pin landed on a road — search for closest named POI within 50m
          final lat = point.latitude; final lng = point.longitude;
          final nearbyUrl = 'https://nominatim.openstreetmap.org/search'
              '?format=json&q=&lat=$lat&lon=$lng&radius=0.05&limit=5'
              '&addressdetails=0&bounded=1'
              '&viewbox=${lng-0.001},${lat-0.001},${lng+0.001},${lat+0.001}';
          try {
            final nr = await http.get(Uri.parse(nearbyUrl),
                headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
                .timeout(const Duration(seconds: 5));
            if (nr.statusCode == 200) {
              final nearby = (jsonDecode(nr.body) as List)
                  .cast<Map<String, dynamic>>()
                  .where((e) => (e['name'] as String?)?.isNotEmpty == true
                      && (e['class'] as String?) != 'highway')
                  .toList();
              if (nearby.isNotEmpty) {
                resolvedName = nearby.first['name'] as String;
              }
            }
          } catch (_) {}
          // Final fallback — first segment of display_name
          resolvedName ??= (data['display_name'] as String).split(',').first.trim();
        }

        // Address
        final parts = <String>[];
        for (final k in ['road', 'house_number', 'city', 'town', 'village', 'country']) {
          final v = addr[k] as String?;
          if (v != null && v.isNotEmpty) parts.add(v);
        }
        resolvedAddress = parts.isNotEmpty ? parts.take(4).join(', ') : null;

        // Phone & website from extratags
        resolvedPhone   = tags['phone']   as String? ?? tags['contact:phone']   as String?;
        resolvedWebsite = tags['website'] as String? ?? tags['contact:website'] as String?;

        // Category from OSM type/class
        final type = data['type'] as String? ?? '';
        final cls  = data['class'] as String? ?? '';
        if (['hotel','hostel','motel','guest_house','apartment'].contains(type))       resolvedCategory = AddressCategory.hotel;
        else if (['restaurant','cafe','bar','fast_food'].contains(type))               resolvedCategory = AddressCategory.restaurant;
        else if (['aerodrome','airport'].contains(type) || cls == 'aeroway')           resolvedCategory = AddressCategory.airport;
        else if (['hospital','clinic','pharmacy','doctors'].contains(type))            resolvedCategory = AddressCategory.hospital;
        else if (['bus_station','train_station','subway_entrance'].contains(type))     resolvedCategory = AddressCategory.transport;
        else if (['mall','supermarket','convenience','marketplace'].contains(type))    resolvedCategory = AddressCategory.shopping;
        else if (cls == 'tourism' || ['museum','attraction','monument'].contains(type)) resolvedCategory = AddressCategory.landmark;
        else if (cls == 'office' || type == 'office')                                  resolvedCategory = AddressCategory.office;
      }
    } catch (_) {}

    if (mounted) setState(() => _isResolving = false);
    if (!mounted) return;

    await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditAddressDialog(
        tripId:          widget.tripId,
        prefillLat:      point.latitude,
        prefillLng:      point.longitude,
        prefillName:     resolvedName,
        prefillAddress:  resolvedAddress,
        prefillPhone:    resolvedPhone,
        prefillWebsite:  resolvedWebsite,
        prefillCategory: resolvedCategory,
      ),
    );
    if (mounted) setState(() => _newPin = null);
  }

  LatLngBounds _bounds() {
    final points = widget.addresses
        .map((a) => LatLng(a.latitude!, a.longitude!))
        .toList();
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(LatLng(minLat - 0.05, minLng - 0.05),
                        LatLng(maxLat + 0.05, maxLng + 0.05));
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.addresses.map((a) => LatLng(a.latitude!, a.longitude!)).toList();

    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCameraFit: widget.initCenter != null ? null
              : widget.focusAddress != null && widget.focusAddress!.hasCoords
                  ? CameraFit.bounds(
                      bounds: LatLngBounds(
                        LatLng(widget.focusAddress!.latitude! - 0.008, widget.focusAddress!.longitude! - 0.008),
                        LatLng(widget.focusAddress!.latitude! + 0.008, widget.focusAddress!.longitude! + 0.008),
                      ),
                      padding: const EdgeInsets.all(24),
                    )
                  : CameraFit.bounds(bounds: _bounds(), padding: const EdgeInsets.all(48)),
          initialCenter: widget.initCenter ?? const LatLng(30, 15),
          initialZoom: widget.initCenter != null ? 12.0 : 5.0,
          onTap: (_, __) => setState(() { _selectedAddress = null; _newPin = null; }),
          onLongPress: _onLongPress,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tripready.app',
            maxNativeZoom: 19,
          ),
          if (widget.showRoute && points.length >= 2)
            PolylineLayer(polylines: <Polyline>[
              Polyline(
                points: points,
                color: TripReadyTheme.teal.withOpacity(0.7),
                strokeWidth: 3,
              ),
            ]),
          if (_newPin != null)
            MarkerLayer(markers: [
              Marker(
                point: _newPin!,
                width: 44, height: 44,
                child: _isResolving
                    ? Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2, color: TripReadyTheme.teal),
                        ),
                      )
                    : const Icon(Icons.add_location_alt, color: TripReadyTheme.teal, size: 44),
              ),
            ]),
          MarkerLayer(
            markers: widget.addresses.map((a) {
              final isSelected = _selectedAddress?.id == a.id;
              return Marker(
                point: LatLng(a.latitude!, a.longitude!),
                width: isSelected ? 48 : 36,
                height: isSelected ? 48 : 36,
                child: GestureDetector(
                  onTap: () => setState(() =>
                      _selectedAddress = _selectedAddress?.id == a.id ? null : a),
                  child: Icon(
                    Icons.location_pin,
                    color: isSelected ? TripReadyTheme.amber : TripReadyTheme.danger,
                    size: isSelected ? 48 : 36,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),

      // Search bar
      Positioned(
        top: 8, left: 12, right: 12,
        child: MapSearchBar(
          mapController: _mapController,
          zoomOnSelect: 14.0,
          onResultSelected: (r) => _onLongPress(
            const TapPosition(Offset.zero, Offset.zero), r.point),
        ),
      ),

      // Long-press hint (non-archived, no popup showing)
      if (!widget.isArchived && _selectedAddress == null && _newPin == null)
        Positioned(
          bottom: 16, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Long-press to add a new place',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),

      // Popup card for selected pin
      if (_selectedAddress != null)
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedAddress!.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  if (_selectedAddress!.address != null)
                    Text(_selectedAddress!.address!,
                        style: const TextStyle(fontSize: 12, color: TripReadyTheme.textMid)),
                ])),
                TextButton.icon(
                  onPressed: () => widget.onOpenMap(_selectedAddress!),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Navigate'),
                  style: TextButton.styleFrom(foregroundColor: TripReadyTheme.teal),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedAddress = null),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }
}

// ── Category group + cards ────────────────────────────────────────────────────

class _AddressCategoryGroup extends StatelessWidget {
  final AddressCategory category;
  final List<TripAddress> addresses;
  final bool isArchived;
  final String catLabel;
  final Function(TripAddress) onEdit, onDelete, onOpenMap, onOpenWebsite;
  final Function(TripAddress)? onViewOnMap;

  const _AddressCategoryGroup({
    required this.category, required this.addresses, required this.isArchived,
    required this.catLabel, required this.onEdit, required this.onDelete,
    required this.onOpenMap, required this.onOpenWebsite,
    this.onViewOnMap,
  });

  IconData get _categoryIcon {
    switch (category) {
      case AddressCategory.hotel:      return Icons.hotel_outlined;
      case AddressCategory.airport:    return Icons.flight_outlined;
      case AddressCategory.restaurant: return Icons.restaurant_outlined;
      case AddressCategory.landmark:   return Icons.account_balance_outlined;
      case AddressCategory.office:     return Icons.business_outlined;
      case AddressCategory.hospital:   return Icons.local_hospital_outlined;
      case AddressCategory.transport:  return Icons.directions_bus_outlined;
      case AddressCategory.shopping:   return Icons.shopping_bag_outlined;
      case AddressCategory.other:      return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Row(children: [
          Icon(_categoryIcon, size: 14, color: TripReadyTheme.teal),
          const SizedBox(width: 6),
          Text(catLabel.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: TripReadyTheme.teal, letterSpacing: 0.8, fontSize: 11)),
          const SizedBox(width: 8),
          Text('${addresses.length}', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
      ...addresses.map((a) => _AddressCard(
        address: a, isArchived: isArchived,
        onEdit: () => onEdit(a), onDelete: () => onDelete(a),
        onOpenMap: () => onOpenMap(a), onOpenWebsite: () => onOpenWebsite(a),
        onViewOnMap: onViewOnMap != null ? () => onViewOnMap!(a) : null,
      )),
    ]);
  }
}

class _AddressCard extends StatelessWidget {
  final TripAddress address;
  final bool isArchived;
  final VoidCallback onEdit, onDelete, onOpenMap, onOpenWebsite;
  final VoidCallback? onViewOnMap;

  const _AddressCard({
    required this.address, required this.isArchived,
    required this.onEdit, required this.onDelete,
    required this.onOpenMap, required this.onOpenWebsite,
    this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return GestureDetector(
      onTap: isArchived ? null : onEdit,
      child: Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: TripReadyTheme.navy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.place, color: TripReadyTheme.navy, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(address.name, style: Theme.of(context).textTheme.titleMedium)),
                if (address.hasCoords)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.location_on, size: 14, color: TripReadyTheme.teal),
                  ),
              ]),
              if (address.address != null) ...[
                const SizedBox(height: 2),
                Text(address.address!, style: Theme.of(context).textTheme.bodySmall),
              ],
              if (address.phone != null) ...[
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.phone_outlined, size: 12, color: TripReadyTheme.textMid),
                  const SizedBox(width: 4),
                  Text(address.phone!, style: Theme.of(context).textTheme.bodySmall),
                ]),
              ],
            ])),
            if (!isArchived)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: TripReadyTheme.textLight),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l.actionEdit)),
                  PopupMenuItem(value: 'delete', child: Text(l.actionDelete,
                      style: const TextStyle(color: TripReadyTheme.danger))),
                ],
              ),
          ]),
          if (address.notes != null) ...[
            const SizedBox(height: 8),
            Text(address.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, color: TripReadyTheme.textMid)),
          ],
          const SizedBox(height: 10),
          Row(children: [
            _ActionButton(
                icon: Icons.navigation_outlined, label: 'Navigation',
                color: TripReadyTheme.teal, onTap: onOpenMap),
            if (address.hasCoords && onViewOnMap != null) ...[
              const SizedBox(width: 8),
              _ActionButton(
                  icon: Icons.map_outlined, label: 'View on Map',
                  color: TripReadyTheme.navy, onTap: onViewOnMap!),
            ],
            if (address.website != null) ...[
              const SizedBox(width: 8),
              _ActionButton(
                  icon: Icons.language_outlined, label: l.fieldWebsite,
                  color: TripReadyTheme.navy, onTap: onOpenWebsite),
            ],
          ]),
        ]),
      ),
    ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}

// ── Add/Edit dialog ──────────────────────────────────────────────────────────

// ── Add/Edit dialog with inline search ───────────────────────────────────────

/// OSM place result from Nominatim search.
class _PlaceResult {
  final String name;
  final String displayAddress;
  final double lat;
  final double lng;
  final String? phone;
  final String? website;
  final AddressCategory category;

  const _PlaceResult({
    required this.name,
    required this.displayAddress,
    required this.lat,
    required this.lng,
    this.phone,
    this.website,
    this.category = AddressCategory.other,
  });
}

class _AddEditAddressDialog extends StatefulWidget {
  final String tripId;
  final TripAddress? address;
  final double? prefillLat;
  final double? prefillLng;
  final String? prefillName;
  final String? prefillAddress;
  final String? prefillPhone;
  final String? prefillWebsite;
  final AddressCategory? prefillCategory;
  const _AddEditAddressDialog({
    required this.tripId,
    this.address,
    this.prefillLat,
    this.prefillLng,
    this.prefillName,
    this.prefillAddress,
    this.prefillPhone,
    this.prefillWebsite,
    this.prefillCategory,
  });
  @override
  State<_AddEditAddressDialog> createState() => _AddEditAddressDialogState();
}

class _AddEditAddressDialogState extends State<_AddEditAddressDialog> {
  // ── Search state ───────────────────────────────────────────
  final _searchController = TextEditingController();
  List<_PlaceResult> _searchResults = [];
  bool _isSearching   = false;
  bool _searchDone    = false; // true once a result was selected → collapse search

  // ── Form state ─────────────────────────────────────────────
  final _nameController    = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController   = TextEditingController();
  final _notesController   = TextEditingController();
  AddressCategory _category = AddressCategory.other;
  double? _latitude;
  double? _longitude;
  bool _isSaving = false;
  bool get _isEditing => widget.address != null;

  // Debounce timer
  DateTime _lastSearch = DateTime(0);

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.address!;
      _nameController.text    = a.name;
      _addressController.text = a.address ?? '';
      _websiteController.text = a.website ?? '';
      _phoneController.text   = a.phone ?? '';
      _notesController.text   = a.notes ?? '';
      _category  = a.category;
      _latitude  = a.latitude;
      _longitude = a.longitude;
      _searchDone = true; // editing: skip search bar
    } else if (widget.prefillLat != null) {
      // Pre-filled from map long-press
      _latitude  = widget.prefillLat;
      _longitude = widget.prefillLng;
      if (widget.prefillName    != null) _nameController.text    = widget.prefillName!;
      if (widget.prefillAddress != null) _addressController.text = widget.prefillAddress!;
      if (widget.prefillPhone   != null) _phoneController.text   = widget.prefillPhone!;
      if (widget.prefillWebsite != null) _websiteController.text = widget.prefillWebsite!;
      if (widget.prefillCategory != null) _category = widget.prefillCategory!;
      _searchDone = true; // skip search — coords already known
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose(); _addressController.dispose();
    _websiteController.dispose();
    _phoneController.dispose(); _notesController.dispose();
    super.dispose();
  }

  // ── Search ─────────────────────────────────────────────────

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    _lastSearch = DateTime.now();
    final stamp = _lastSearch;
    await Future.delayed(const Duration(milliseconds: 400));
    if (stamp != _lastSearch || !mounted) return; // superseded

    setState(() => _isSearching = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1&extratags=1',
      );
      final res = await http.get(uri,
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (res.statusCode != 200) { setState(() => _isSearching = false); return; }

      final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      final results = list.map((item) {
        final tags = item['extratags'] as Map<String, dynamic>? ?? {};
        final addr = item['address']  as Map<String, dynamic>? ?? {};
        return _PlaceResult(
          name: _extractName(item, addr),
          displayAddress: _extractAddress(addr, item['display_name'] as String),
          lat: double.parse(item['lat'] as String),
          lng: double.parse(item['lon'] as String),
          phone:   tags['phone']   as String? ?? tags['contact:phone']   as String?,
          website: tags['website'] as String? ?? tags['contact:website'] as String?,
          category: _osmCategory(item['type'] as String?, item['class'] as String?),
        );
      }).toList();

      setState(() { _searchResults = results; _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() { _searchResults = []; _isSearching = false; });
    }
  }

  String _extractName(Map<String, dynamic> item, Map<String, dynamic> addr) {
    if ((item['name'] as String?)?.isNotEmpty == true) return item['name'] as String;
    final display = item['display_name'] as String;
    return display.split(',').first.trim();
  }

  String _extractAddress(Map<String, dynamic> addr, String fallback) {
    final parts = <String>[];
    for (final key in ['road', 'house_number', 'city', 'town', 'village', 'country']) {
      final v = addr[key] as String?;
      if (v != null && v.isNotEmpty) parts.add(v);
    }
    return parts.isNotEmpty ? parts.take(4).join(', ') : fallback.split(',').take(3).join(',');
  }

  AddressCategory _osmCategory(String? type, String? cls) {
    final t = type ?? ''; final c = cls ?? '';
    if (['hotel', 'hostel', 'motel', 'guest_house', 'apartment'].contains(t)) return AddressCategory.hotel;
    if (['restaurant', 'cafe', 'bar', 'fast_food', 'food_court'].contains(t)) return AddressCategory.restaurant;
    if (['aerodrome', 'airport'].contains(t) || c == 'aeroway') return AddressCategory.airport;
    if (['hospital', 'clinic', 'pharmacy', 'doctors'].contains(t)) return AddressCategory.hospital;
    if (['bus_station', 'train_station', 'subway_entrance', 'ferry_terminal'].contains(t)) return AddressCategory.transport;
    if (['mall', 'supermarket', 'convenience', 'marketplace'].contains(t)) return AddressCategory.shopping;
    if (c == 'tourism' || ['museum', 'attraction', 'monument', 'viewpoint'].contains(t)) return AddressCategory.landmark;
    if (c == 'office' || t == 'office') return AddressCategory.office;
    return AddressCategory.other;
  }

  void _selectResult(_PlaceResult r) {
    setState(() {
      _nameController.text    = r.name;
      _addressController.text = r.displayAddress;
      _phoneController.text   = r.phone ?? '';
      _websiteController.text = r.website ?? '';
      _latitude   = r.lat;
      _longitude  = r.lng;
      _category   = r.category;
      _searchDone = true;
      _searchResults = [];
    });
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _searchDone    = false;
      _searchResults = [];
    });
  }

  // ── Save ───────────────────────────────────────────────────

  String? _clean(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  String _catLabel(AddressCategory c, AppLocalizations l) {
    switch (c) {
      case AddressCategory.hotel:      return l.addressesCatHotel;
      case AddressCategory.airport:    return l.addressesCatAirport;
      case AddressCategory.restaurant: return l.addressesCatRestaurant;
      case AddressCategory.landmark:   return l.addressesCatLandmark;
      case AddressCategory.office:     return l.addressesCatOffice;
      case AddressCategory.hospital:   return l.addressesCatHospital;
      case AddressCategory.transport:  return l.addressesCatTransport;
      case AddressCategory.shopping:   return l.addressesCatShopping;
      case AddressCategory.other:      return l.addressesCatOther;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateAddress(widget.address!.copyWith(
          name: _nameController.text.trim(),
          address: _clean(_addressController),
          category: _category,
          website: _clean(_websiteController),
          phone: _clean(_phoneController),
          notes: _clean(_notesController),
          latitude: _latitude,
          longitude: _longitude,
        ));
      } else {
        await DatabaseHelper.instance.insertAddress(TripAddress(
          id: const Uuid().v4(),
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          address: _clean(_addressController),
          category: _category,
          website: _clean(_websiteController),
          phone: _clean(_phoneController),
          notes: _clean(_notesController),
          latitude: _latitude,
          longitude: _longitude,
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final hasPin = _latitude != null && _longitude != null;

    return AlertDialog(
      title: Text(_isEditing ? l.actionEdit : l.addressesAddAddress),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [

          // ── Search bar (add mode only, collapses after selection) ──
          if (!_isEditing) ...[
            if (!_searchDone) ...[
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search for a place…',
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: TripReadyTheme.teal)))
                      : const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                          _searchController.clear();
                          setState(() { _searchResults = []; });
                        })
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TripReadyTheme.teal, width: 2),
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TripReadyTheme.warmGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: _searchResults.asMap().entries.map((e) {
                    final i = e.key; final r = e.value;
                    return InkWell(
                      borderRadius: BorderRadius.circular(i == 0
                          ? 12 : (i == _searchResults.length - 1 ? 12 : 0)),
                      onTap: () => _selectResult(r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(children: [
                          Icon(_categoryIcon(r.category), size: 18, color: TripReadyTheme.teal),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(r.displayAddress,
                                style: const TextStyle(fontSize: 11, color: TripReadyTheme.textMid),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                        ]),
                      ),
                    );
                  }).toList()),
                ),
              ],
              if (_searchResults.isEmpty && !_isSearching && _searchController.text.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 2),
                  child: Row(children: [
                    const SizedBox(width: 4),
                    Text('or fill in manually below',
                        style: TextStyle(fontSize: 11, color: TripReadyTheme.textLight)),
                  ]),
                ),
              const SizedBox(height: 12),
            ] else ...[
              // Collapsed — show selected place chip with option to re-search
              Row(children: [
                const Icon(Icons.check_circle, size: 16, color: TripReadyTheme.teal),
                const SizedBox(width: 6),
                Expanded(child: Text(_nameController.text,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: TripReadyTheme.teal),
                    overflow: TextOverflow.ellipsis)),
                TextButton(
                  onPressed: _resetSearch,
                  style: TextButton.styleFrom(
                      foregroundColor: TripReadyTheme.textLight,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero),
                  child: const Text('Search again', style: TextStyle(fontSize: 11)),
                ),
              ]),
              const Divider(height: 16),
            ],
          ],

          // ── Form fields ────────────────────────────────────
          TextField(
            controller: _nameController,
            autofocus: _isEditing,
            decoration: InputDecoration(
                labelText: '${l.fieldName} *',
                prefixIcon: const Icon(Icons.place_outlined)),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<AddressCategory>(
            value: _category,
            decoration: InputDecoration(
                labelText: l.fieldCategory,
                prefixIcon: const Icon(Icons.category_outlined)),
            items: AddressCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(_catLabel(c, l))))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
                labelText: l.fieldAddress,
                prefixIcon: const Icon(Icons.location_on_outlined),
                alignLabelWithHint: true),
          ),
          const SizedBox(height: 10),
          if (hasPin)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                const Icon(Icons.location_on, size: 14, color: TripReadyTheme.teal),
                const SizedBox(width: 6),
                Text('📍 ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: TripReadyTheme.teal)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() { _latitude = null; _longitude = null; }),
                  style: TextButton.styleFrom(
                      foregroundColor: TripReadyTheme.danger,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero),
                  child: const Text('Remove pin', style: TextStyle(fontSize: 11)),
                ),
              ]),
            ),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: l.fieldPhone,
                prefixIcon: const Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
                labelText: l.fieldWebsite,
                prefixIcon: const Icon(Icons.language_outlined)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
                labelText: l.fieldNotes,
                prefixIcon: const Icon(Icons.notes_outlined),
                alignLabelWithHint: true),
          ),
          const SizedBox(height: 8),
        ])),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEditing ? l.actionUpdate : l.addressesAddAddress),
        ),
      ],
    );
  }

  IconData _categoryIcon(AddressCategory c) {
    switch (c) {
      case AddressCategory.hotel:      return Icons.hotel_outlined;
      case AddressCategory.airport:    return Icons.flight_outlined;
      case AddressCategory.restaurant: return Icons.restaurant_outlined;
      case AddressCategory.landmark:   return Icons.account_balance_outlined;
      case AddressCategory.office:     return Icons.business_outlined;
      case AddressCategory.hospital:   return Icons.local_hospital_outlined;
      case AddressCategory.transport:  return Icons.directions_bus_outlined;
      case AddressCategory.shopping:   return Icons.shopping_bag_outlined;
      case AddressCategory.other:      return Icons.place_outlined;
    }
  }
}
