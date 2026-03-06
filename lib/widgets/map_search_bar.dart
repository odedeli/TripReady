import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class MapSearchResult {
  final String name;
  final String display;
  final LatLng point;
  const MapSearchResult({required this.name, required this.display, required this.point});
}

/// Floating search bar overlay for FlutterMap.
/// Searches Nominatim, shows dropdown, on selection calls [onResultSelected]
/// with the result — caller handles panning and pin dropping.
class MapSearchBar extends StatefulWidget {
  final MapController mapController;
  final void Function(MapSearchResult result) onResultSelected;
  final double zoomOnSelect;

  const MapSearchBar({
    super.key,
    required this.mapController,
    required this.onResultSelected,
    this.zoomOnSelect = 13.0,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final _ctrl   = TextEditingController();
  final _focus  = FocusNode();
  List<MapSearchResult> _results = [];
  bool _searching = false;
  bool _expanded  = false;
  Timer? _debounce;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() { _results = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q.trim()));
  }

  Future<void> _search(String q) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search'
          '?format=json&q=${Uri.encodeComponent(q)}&limit=5&addressdetails=0';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'TripReady/1.4 (travel planner app)'})
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
        final results = list.map((item) {
          final display = item['display_name'] as String;
          final name    = display.split(',').first.trim();
          return MapSearchResult(
            name: name,
            display: display.split(',').take(3).join(','),
            point: LatLng(
              double.parse(item['lat'] as String),
              double.parse(item['lon'] as String),
            ),
          );
        }).toList();
        setState(() { _results = results; _searching = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _results = []; _searching = false; });
    }
  }

  void _select(MapSearchResult r) {
    _ctrl.text = r.name;
    _focus.unfocus();
    setState(() { _results = []; _expanded = false; });
    widget.mapController.move(r.point, widget.zoomOnSelect);
    widget.onResultSelected(r);
  }

  void _clear() {
    _ctrl.clear();
    setState(() { _results = []; _expanded = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ── Search field ─────────────────────────────────────────
      Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: _onChanged,
          onTap: () => setState(() => _expanded = true),
          decoration: InputDecoration(
            hintText: 'Search location…',
            prefixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2,
                            color: TripReadyTheme.teal)))
                : const Icon(Icons.search, color: TripReadyTheme.textMid),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _clear)
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),

      // ── Results dropdown ─────────────────────────────────────
      if (_results.isNotEmpty)
        Material(
          elevation: 4,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          child: Column(
            children: _results.asMap().entries.map((e) {
              final r = e.value;
              return InkWell(
                onTap: () => _select(r),
                borderRadius: e.key == _results.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.place_outlined, size: 16,
                        color: TripReadyTheme.teal),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.name, style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(r.display, style: const TextStyle(
                          fontSize: 11, color: TripReadyTheme.textMid),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
    ]);
  }
}
