import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/geocoding_service.dart';
import '../services/recent_destinations_service.dart';
import '../theme/app_theme.dart';
import 'flag_widget.dart';

/// Two-step destination picker: Country → City.
///
/// Features:
///  - Bundled offline city list filtered by country
///  - Live Nominatim autocomplete as you type (debounced 400ms)
///  - Recent destinations section (most-recent first, country-filtered)
///  - Free-text custom entry fallback
class CityPickerField extends StatefulWidget {
  final String? countryCode;
  final String? countryName;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmitted;

  const CityPickerField({
    super.key,
    required this.countryCode,
    required this.countryName,
    required this.controller,
    this.focusNode,
    this.label = 'Destination',
    this.validator,
    this.onSubmitted,
  });

  @override
  State<CityPickerField> createState() => _CityPickerFieldState();
}

class _CityPickerFieldState extends State<CityPickerField> {
  static Map<String, List<String>>? _cityData;
  List<String> _cities = [];
  bool _dataReady = false;

  @override
  void initState() {
    super.initState();
    _loadAndFilter();
  }

  @override
  void didUpdateWidget(CityPickerField old) {
    super.didUpdateWidget(old);
    if (old.countryCode != widget.countryCode) {
      widget.controller.clear();
      _loadAndFilter();
    }
  }

  Future<void> _loadAndFilter() async {
    if (_cityData == null) {
      final raw = await rootBundle.loadString('assets/data/cities.json');
      _cityData = Map<String, List<String>>.from(
        (jsonDecode(raw) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, List<String>.from(v as List))),
      );
    }
    if (!mounted) return;
    final code = widget.countryCode?.toUpperCase();
    setState(() {
      _cities = code != null ? (_cityData?[code] ?? []) : [];
      _dataReady = true;
    });
  }

  Future<void> _openPicker() async {
    final recents = await RecentDestinationsService.instance
        .getForCountry(widget.countryCode);
    if (!mounted) return;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CityPickerSheet(
        cities: _cities,
        recents: recents,
        countryCode: widget.countryCode,
        countryName: widget.countryName,
        currentValue: widget.controller.text,
      ),
    );
    if (result != null && mounted) {
      widget.controller.text = result;
      // Save to recents
      await RecentDestinationsService.instance.add(
        result,
        countryCode: widget.countryCode,
        countryName: widget.countryName,
      );
      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final hasValue = widget.controller.text.isNotEmpty;

    if (widget.countryCode == null) {
      return TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => widget.onSubmitted?.call(),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.location_city_outlined),
          hintText: 'Select a country first',
        ),
        validator: widget.validator,
      );
    }

    return GestureDetector(
      onTap: _dataReady ? _openPicker : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_city_outlined),
            suffixIcon: !_dataReady
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : Icon(Icons.arrow_drop_down,
                    color: hasValue ? primary : onSurface.withOpacity(0.4)),
            hintText: _cities.isEmpty && _dataReady
                ? 'Tap to search city' : 'Select or search city',
          ),
          validator: widget.validator,
          onTap: _dataReady ? _openPicker : null,
        ),
      ),
    );
  }
}

// ── Bottom sheet ─────────────────────────────────────────────────────────────

class _CityPickerSheet extends StatefulWidget {
  final List<String> cities;
  final List<RecentDestination> recents;
  final String? countryCode;
  final String? countryName;
  final String currentValue;

  const _CityPickerSheet({
    required this.cities,
    required this.recents,
    required this.countryCode,
    required this.countryName,
    required this.currentValue,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchCtrl = TextEditingController();

  List<String> _bundledFiltered = [];
  List<String> _autocompleteResults = [];
  bool _autoLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _bundledFiltered = List.of(widget.cities);
    _searchCtrl.addListener(_onType);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onType);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onType() {
    final q = _searchCtrl.text.trim().toLowerCase();

    // Immediately filter bundled list
    setState(() {
      _bundledFiltered = q.isEmpty
          ? List.of(widget.cities)
          : widget.cities.where((c) => c.toLowerCase().contains(q)).toList();
      if (q.isEmpty) _autocompleteResults = [];
    });

    // Debounced autocomplete for anything not already covered by bundled
    _debounce?.cancel();
    if (q.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 400), () => _runAutocomplete(q));
    }
  }

  Future<void> _runAutocomplete(String q) async {
    if (!mounted) return;
    setState(() => _autoLoading = true);
    final results = await GeocodingService.instance.autocomplete(
      q,
      countryCode: widget.countryCode,
      limit: 6,
    );
    if (!mounted) return;
    // Filter out anything already in the bundled filtered list (dedup)
    final newResults = results
        .where((r) => !_bundledFiltered
            .any((b) => b.toLowerCase() == r.toLowerCase()))
        .toList();
    setState(() {
      _autocompleteResults = newResults;
      _autoLoading = false;
    });
  }

  void _select(String city) => Navigator.pop(context, city);

  String get _q => _searchCtrl.text.trim();

  @override
  Widget build(BuildContext context) {
    final showCustom = _q.isNotEmpty &&
        !_bundledFiltered.any((c) => c.toLowerCase() == _q.toLowerCase()) &&
        !_autocompleteResults.any((c) => c.toLowerCase() == _q.toLowerCase());

    // Recents: hide when searching, show when empty query
    final showRecents = _q.isEmpty && widget.recents.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scroll) => Column(children: [
        // Handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            FlagWidget(code: widget.countryCode, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(
              widget.countryName ?? 'Select city',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            )),
          ]),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search cities…',
              suffixIcon: _q.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _autocompleteResults = []);
                      })
                  : _autoLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2,
                                  color: TripReadyTheme.teal)))
                      : null,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: ListView(controller: scroll, children: [

          // ── Recent destinations (shown when not searching) ──
          if (showRecents) ...[
            _sectionHeader('Recent', Icons.history),
            ...widget.recents.map((r) => ListTile(
              leading: FlagWidget(code: r.countryCode, size: 18),
              title: Text(r.city),
              subtitle: r.countryName != null
                  ? Text(r.countryName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
                  : null,
              selected: r.city == widget.currentValue,
              selectedTileColor: TripReadyTheme.teal.withOpacity(0.08),
              selectedColor: TripReadyTheme.teal,
              onTap: () => _select(r.city),
            )),
            const Divider(indent: 16, endIndent: 16),
          ],

          // ── Bundled city list ───────────────────────────────
          if (_bundledFiltered.isNotEmpty) ...[
            if (showRecents || _autocompleteResults.isNotEmpty)
              _sectionHeader('Cities', Icons.location_city_outlined),
            ..._bundledFiltered.map((city) => ListTile(
              leading: const Icon(Icons.location_city_outlined, size: 20),
              title: Text(city),
              selected: city == widget.currentValue,
              selectedTileColor: TripReadyTheme.teal.withOpacity(0.08),
              selectedColor: TripReadyTheme.teal,
              onTap: () => _select(city),
            )),
          ],

          // ── Live autocomplete results ───────────────────────
          if (_autocompleteResults.isNotEmpty) ...[
            _sectionHeader('Suggestions', Icons.travel_explore),
            ..._autocompleteResults.map((city) => ListTile(
              leading: const Icon(Icons.public, size: 20,
                  color: TripReadyTheme.teal),
              title: Text(city),
              onTap: () => _select(city),
            )),
          ],

          // ── Empty bundled list ──────────────────────────────
          if (_bundledFiltered.isEmpty && _autocompleteResults.isEmpty &&
              !_autoLoading && _q.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No bundled cities for this country.\nStart typing to search.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),

          // ── Custom entry ────────────────────────────────────
          if (showCustom) ...[
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.edit_location_alt_outlined,
                  color: TripReadyTheme.amber),
              title: Text('Use "$_q"'),
              subtitle: const Text('Custom destination name'),
              onTap: () => _select(_q),
            ),
          ],
          const SizedBox(height: 32),
        ])),
      ]),
    );
  }

  Widget _sectionHeader(String label, IconData icon) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Row(children: [
      Icon(icon, size: 14, color: Colors.grey.shade500),
      const SizedBox(width: 6),
      Text(label.toUpperCase(),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    ]),
  );
}
