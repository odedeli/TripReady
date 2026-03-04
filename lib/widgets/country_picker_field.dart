import 'package:flutter/material.dart';
import '../data/countries.dart';
import '../services/language_service.dart';

/// A form field that opens a searchable, locale-aware country picker.
///
/// Stores the ISO alpha-2 code; displays the flag + localized name.
/// Country names are shown in the active UI language (English / Hebrew),
/// and search works against the localized name as well as the ISO code.
class CountryPickerField extends StatefulWidget {
  const CountryPickerField({
    super.key,
    this.initialCode,
    required this.label,
    required this.onChanged,
  });

  final String? initialCode;
  final String label;
  final ValueChanged<Country?> onChanged;

  @override
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  Country? _selected;

  @override
  void initState() {
    super.initState();
    _selected = countryByCode(widget.initialCode);
  }

  String get _lang => LanguageService.instance.locale.languageCode;

  Future<void> _openPicker() async {
    final result = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(current: _selected, lang: _lang),
    );
    if (result != null) {
      setState(() => _selected = result);
      widget.onChanged(_selected);
    }
  }

  void _clear() {
    setState(() => _selected = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final hasValue = _selected != null;
    final primary  = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: _openPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? primary : onSurface.withOpacity(0.2),
            width: hasValue ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            if (hasValue)
              Text(_selected!.flag, style: const TextStyle(fontSize: 22))
            else
              Icon(Icons.flag_outlined, size: 22, color: onSurface.withOpacity(0.4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValue ? _selected!.localizedName(_lang) : widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasValue ? onSurface : onSurface.withOpacity(0.45),
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: _clear,
                child: Icon(Icons.close, size: 18, color: onSurface.withOpacity(0.4)),
              )
            else
              Icon(Icons.keyboard_arrow_down, size: 20, color: onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet ─────────────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({this.current, required this.lang});
  final Country? current;
  final String lang;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<Country> _filtered;

  // Pre-sort list by localized name for the active language
  late final List<Country> _sorted;

  @override
  void initState() {
    super.initState();
    _sorted = List.of(kCountries)
      ..sort((a, b) => a.localizedName(widget.lang)
          .compareTo(b.localizedName(widget.lang)));
    _filtered = _sorted;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _sorted
          : _sorted.where((c) =>
              c.localizedName(widget.lang).toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q) || // always search English too
              c.code.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final mq        = MediaQuery.of(context);
    final maxHeight = mq.size.height * 0.85;
    final isRTL     = widget.lang == 'he';

    // Localized UI strings
    final titleText  = isRTL ? 'בחר מדינה'        : 'Select Country';
    final cancelText = isRTL ? 'ביטול'             : 'Cancel';
    final hintText   = isRTL ? 'חפש מדינה...'      : 'Search countries...';
    final emptyText  = isRTL ? 'לא נמצאו מדינות'   : 'No countries found';

    return Directionality(
      // Sheet always matches app text direction
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title + Cancel ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Text(titleText,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(cancelText),
                  ),
                ],
              ),
            ),

            // ── Search ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                textDirection: TextDirection.ltr, // search input always LTR
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintTextDirection:
                      isRTL ? TextDirection.rtl : TextDirection.ltr,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),

            const Divider(height: 1),

            // ── List ──────────────────────────────────────────────
            Flexible(
              child: _filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(emptyText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          )),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemExtent: 52,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (_, i) {
                        final country   = _filtered[i];
                        final isSelected = country.code == widget.current?.code;
                        return InkWell(
                          onTap: () => Navigator.pop(context, country),
                          child: Container(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.08)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Text(country.flag,
                                    style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    country.localizedName(widget.lang),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: 18,
                                      color: theme.colorScheme.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: mq.padding.bottom),
          ],
        ),
      ),
    );
  }
}
