import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/map_search_bar.dart';
import '../../services/localization_ext.dart';

/// Full-screen map where the user taps to place a pin.
/// Returns ({lat, lng, address}) or null if cancelled.
class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.title = 'Pick Location',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  LatLng? _picked;
  String? _resolvedAddress;
  bool _isResolving = false;

  static const _defaultCenter = LatLng(48.8566, 2.3522); // Paris fallback
  static const _defaultZoom   = 5.0;
  static const _pinZoom       = 15.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLat != null && widget.initialLng != null) {
      _picked = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _onTap(TapPosition _, LatLng point) async {
    setState(() { _picked = point; _resolvedAddress = null; _isResolving = true; });
    final addr = await GeocodingService.instance.reverseGeocode(point.latitude, point.longitude);
    if (mounted) setState(() { _resolvedAddress = addr; _isResolving = false; });
  }

  void _confirm() {
    if (_picked == null) return;
    Navigator.pop(context, (
      lat: _picked!.latitude,
      lng: _picked!.longitude,
      address: _resolvedAddress,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? _defaultCenter;
    final zoom   = _picked != null ? _pinZoom : _defaultZoom;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_picked != null)
            TextButton(
              onPressed: _confirm,
              child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            onTap: _onTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tripready.app',
              maxNativeZoom: 19,
            ),
            if (_picked != null)
              MarkerLayer(markers: [
                Marker(
                  point: _picked!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_pin, color: TripReadyTheme.danger, size: 40),
                ),
              ]),
          ],
        ),

        // Search bar
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: MapSearchBar(
            mapController: _mapController,
            zoomOnSelect: 15.0,
            onResultSelected: (r) async {
              final pt = r.point;
              setState(() { _picked = pt; _resolvedAddress = null; _isResolving = true; });
              final addr = await GeocodingService.instance
                  .reverseGeocode(pt.latitude, pt.longitude);
              if (mounted) setState(() { _resolvedAddress = addr; _isResolving = false; });
            },
          ),
        ),

        // Instruction banner
        Positioned(
          top: 80,
          left: 16,
          right: 16,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _isResolving
                ? const Row(children: [
                    SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: TripReadyTheme.teal)),
                    SizedBox(width: 10),
                    Text('Resolving address…', style: TextStyle(fontSize: 13)),
                  ])
                : Text(
                    _resolvedAddress ?? (_picked != null
                        ? '${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}'
                        : 'Tap the map to place a pin'),
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ),
        ),

        // Confirm FAB
        if (_picked != null)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FilledButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.check),
              label: Text(_resolvedAddress != null ? 'Use this location' : 'Confirm pin'),
              style: FilledButton.styleFrom(
                backgroundColor: TripReadyTheme.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
      ]),
    );
  }
}
