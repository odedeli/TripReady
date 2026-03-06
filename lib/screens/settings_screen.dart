import 'package:flutter/material.dart';
import '../widgets/flag_widget.dart';
import 'package:country_flags/country_flags.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/recent_destinations_service.dart';
import '../services/map_language_service.dart';

import '../widgets/app_logo.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/watermark_scaffold.dart';
import 'package:tripready/l10n/app_localizations.dart';
import '../database/backup_service.dart';
import '../database/database_helper.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';
import '../services/font_size_service.dart';
import '../services/color_theme_service.dart';
import 'settings/customize_lists_screen.dart';
import '../theme/color_palettes.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: AppLogo.whiteLandscape(height: 28), centerTitle: true, leading: HomeButton()),
      body: WatermarkBody(
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionLabel(l.settingsLanguage),
          const _LanguageTile(),
          const SizedBox(height: 24),

          _SectionLabel(l.settingsAppearance),
          const _ThemeTile(),
          const _FontSizeTile(),
          const _ColorThemeTile(),
          const SizedBox(height: 24),

          _SectionLabel('Customize Lists'),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: 'Trip & Packing Lists',
            subtitle: 'Manage dropdown values for trip type, purpose, packing categories and storage locations',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeListsScreen())),
          ),
          const SizedBox(height: 24),

          _SectionLabel(l.settingsDataManagement),
          _SettingsTile(icon: Icons.upload_outlined,  title: l.settingsExportBackup,  subtitle: l.settingsExportBackupSubtitle,  onTap: () => _exportBackup(context, l)),
          _SettingsTile(icon: Icons.download_outlined, title: l.settingsRestoreBackup, subtitle: l.settingsRestoreBackupSubtitle, onTap: () => _importBackup(context, l)),
          const SizedBox(height: 24),

          _SectionLabel(l.settingsDangerZone),
          _SettingsTile(icon: Icons.delete_forever_outlined, title: l.settingsResetData, subtitle: l.settingsResetDataSubtitle, isDanger: true, onTap: () => _resetAppData(context, l)),
          const SizedBox(height: 24),


          _SectionLabel('Maps'),
          const _MapLanguageTile(),
          const SizedBox(height: 24),

          _SectionLabel('Recent Destinations'),
          const _RecentDestinationsTile(),
          const SizedBox(height: 24),

          _SectionLabel(l.settingsAbout),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'TripReady',
                applicationVersion: '1.4.1',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AppLogo.icon(size: 56),
                ),
                applicationLegalese: 'Personal travel planner.\nAll data stored locally on your device.',
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    AppLogo.icon(size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(text: 'Trip', style: TextStyle(color: Color(0xFFE35A2D))),
                                TextSpan(text: 'Ready', style: TextStyle(color: Color(0xFF171FA7))),
                              ],
                            ),
                          ),
                          FutureBuilder<String>(
                            future: PackageInfo.fromPlatform()
                                .then((i) => i.version)
                                .catchError((_) => '1.4.1'),
                            builder: (_, snap) => Text(
                              "v${snap.data ?? '1.4.1'}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, AppLocalizations l) async {
    final msg = ScaffoldMessenger.of(context);
    final path = await BackupService.instance.exportBackup();
    showAppSnackBar(context, path != null ? '${l.settingsExportBackup}:\n$path' : l.settingsBackupFailed);
  }

  Future<void> _importBackup(BuildContext context, AppLocalizations l) async {
    final msg = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.settingsRestoreConfirmTitle),
        content: Text(l.settingsRestoreConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: TripReadyTheme.danger), onPressed: () => Navigator.pop(context, true), child: Text(l.settingsRestoreBackup)),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await BackupService.instance.importBackup();
    showAppSnackBar(context, success ? l.backupRestoredSuccess : l.backupRestoreFailed);
  }

  Future<void> _resetAppData(BuildContext context, AppLocalizations l) async {
    final msg = ScaffoldMessenger.of(context);
    final step1 = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(children: [const Icon(Icons.warning_amber_rounded, color: TripReadyTheme.danger, size: 26), const SizedBox(width: 10), Text(l.settingsResetStep1Title)]),
        content: Text(l.settingsResetStep1Body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: TripReadyTheme.danger), onPressed: () => Navigator.pop(context, true), child: Text(l.settingsContinue)),
        ],
      ),
    );
    if (step1 != true) return;
    final step2 = await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => _FinalResetConfirmDialog(l: l));
    if (step2 != true) return;
    try {
      await DatabaseHelper.instance.resetAllData();
      if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (e) {
      if (context.mounted) showAppSnackBar(context, '$e');
    }
  }
}

// ── Language Tile ─────────────────────────────────────────────
class _LanguageTile extends StatefulWidget {
  const _LanguageTile();
  @override State<_LanguageTile> createState() => _LanguageTileState();
}
class _LanguageTileState extends State<_LanguageTile> {
  @override void initState() { super.initState(); LanguageService.instance.addListener(_rebuild); }
  @override void dispose()   { LanguageService.instance.removeListener(_rebuild); super.dispose(); }
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final currentCode = LanguageService.instance.locale.languageCode;
    final options = [_LangOption(code: 'en', label: l.langEnglish, countryCode: 'GB'), _LangOption(code: 'he', label: l.langHebrew, countryCode: 'IL')];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          _TileIcon(icon: Icons.language_outlined),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.settingsSelectLanguage, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: currentCode,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 2)),
              ),
              items: options.map((opt) => DropdownMenuItem<String>(value: opt.code, child: Row(children: [CountryFlag.fromCountryCode(opt.countryCode, height: 20, width: 27, borderRadius: 2), const SizedBox(width: 10), Text(opt.label, style: const TextStyle(fontSize: 14))]))).toList(),
              onChanged: (code) { if (code != null) LanguageService.instance.setLocale(Locale(code)); },
            ),
          ])),
        ]),
      ),
    );
  }
}
class _LangOption { final String code, label, countryCode; const _LangOption({required this.code, required this.label, required this.countryCode}); }

// ── Theme Tile ────────────────────────────────────────────────
class _ThemeTile extends StatefulWidget {
  const _ThemeTile();
  @override State<_ThemeTile> createState() => _ThemeTileState();
}
class _ThemeTileState extends State<_ThemeTile> {
  @override void initState() { super.initState(); ThemeService.instance.addListener(_rebuild); }
  @override void dispose()   { ThemeService.instance.removeListener(_rebuild); super.dispose(); }
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final current = ThemeService.instance.mode;
    final options = [
      _ThemeOption(mode: AppThemeMode.light,  label: l.themeLight,  icon: Icons.light_mode_outlined),
      _ThemeOption(mode: AppThemeMode.dark,   label: l.themeDark,   icon: Icons.dark_mode_outlined),
      _ThemeOption(mode: AppThemeMode.system, label: l.themeSystem, icon: Icons.brightness_auto_outlined),
    ];
    return _SelectorCard(
      icon: Icons.palette_outlined,
      title: l.settingsSelectTheme,
      child: Row(children: options.map((opt) {
        final sel = current == opt.mode;
        return Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SelectorButton(
            selected: sel, primary: primary,
            onTap: () => ThemeService.instance.setMode(opt.mode),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(opt.icon, size: 22, color: sel ? Colors.white : primary),
              const SizedBox(height: 4),
              Text(opt.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : primary)),
            ]),
          ),
        ));
      }).toList()),
    );
  }
}
class _ThemeOption { final AppThemeMode mode; final String label; final IconData icon; const _ThemeOption({required this.mode, required this.label, required this.icon}); }

// ── Font Size Tile ────────────────────────────────────────────
class _FontSizeTile extends StatefulWidget {
  const _FontSizeTile();
  @override State<_FontSizeTile> createState() => _FontSizeTileState();
}
class _FontSizeTileState extends State<_FontSizeTile> {
  @override void initState() { super.initState(); FontSizeService.instance.addListener(_rebuild); }
  @override void dispose()   { FontSizeService.instance.removeListener(_rebuild); super.dispose(); }
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final current = FontSizeService.instance.size;
    final options = [
      _FontOption(size: AppFontSize.small,  label: l.fontSmall,  previewSize: 12),
      _FontOption(size: AppFontSize.normal, label: l.fontNormal, previewSize: 15),
      _FontOption(size: AppFontSize.large,  label: l.fontLarge,  previewSize: 18),
    ];
    return _SelectorCard(
      icon: Icons.text_fields_outlined,
      title: l.settingsTextSize,
      child: Row(children: options.map((opt) {
        final sel = current == opt.size;
        return Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SelectorButton(
            selected: sel, primary: primary,
            onTap: () => FontSizeService.instance.setSize(opt.size),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('A', style: TextStyle(fontSize: opt.previewSize, fontWeight: FontWeight.w700, color: sel ? Colors.white : primary)),
              const SizedBox(height: 2),
              Text(opt.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : primary)),
            ]),
          ),
        ));
      }).toList()),
    );
  }
}
class _FontOption { final AppFontSize size; final String label; final double previewSize; const _FontOption({required this.size, required this.label, required this.previewSize}); }

// ── Color Theme Tile ──────────────────────────────────────────
class _ColorThemeTile extends StatefulWidget {
  const _ColorThemeTile();
  @override State<_ColorThemeTile> createState() => _ColorThemeTileState();
}
class _ColorThemeTileState extends State<_ColorThemeTile> {
  @override void initState() { super.initState(); ColorThemeService.instance.addListener(_rebuild); }
  @override void dispose()   { ColorThemeService.instance.removeListener(_rebuild); super.dispose(); }
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = ColorThemeService.instance.colorTheme;
    final opts = [
      _ColorOption(theme: AppColorTheme.oceanDusk,     label: l.colorOceanDusk,     primary: AppPalettes.oceanDusk.primary,     accent: AppPalettes.oceanDusk.accent),
      _ColorOption(theme: AppColorTheme.oceanMidnight, label: l.colorOceanMidnight, primary: AppPalettes.oceanMidnight.primary, accent: AppPalettes.oceanMidnight.accent),
      _ColorOption(theme: AppColorTheme.amberSunset,   label: l.colorAmberSunset,   primary: AppPalettes.amberSunset.primary,   accent: AppPalettes.amberSunset.accent),
      _ColorOption(theme: AppColorTheme.cobaltStorm,   label: l.colorCobaltStorm,   primary: AppPalettes.cobaltStorm.primary,   accent: AppPalettes.cobaltStorm.accent),
      _ColorOption(theme: AppColorTheme.grassForest,   label: l.colorGrassForest,   primary: AppPalettes.grassForest.primary,   accent: AppPalettes.grassForest.accent),
      _ColorOption(theme: AppColorTheme.orchidDusk,    label: l.colorOrchidDusk,    primary: AppPalettes.orchidDusk.primary,    accent: AppPalettes.orchidDusk.accent),
    ];

    Widget row(List<_ColorOption> rowOpts) => Row(
      children: rowOpts.map((opt) {
        final sel = current == opt.theme;
        final parts = opt.label.split(' · ');
        return Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SelectorButton(
            selected: sel, primary: opt.primary,
            onTap: () => ColorThemeService.instance.setColorTheme(opt.theme),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(parts[0], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : opt.primary)),
              if (parts.length > 1) Text(parts[1], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: sel ? Colors.white.withOpacity(0.85) : opt.accent)),
            ]),
          ),
        ));
      }).toList(),
    );

    return _SelectorCard(
      icon: Icons.color_lens_outlined,
      title: l.settingsColorTheme,
      child: Column(children: [
        row(opts.sublist(0, 3)),
        const SizedBox(height: 8),
        row(opts.sublist(3, 6)),
      ]),
    );
  }
}
class _ColorOption { final AppColorTheme theme; final String label; final Color primary, accent; const _ColorOption({required this.theme, required this.label, required this.primary, required this.accent}); }

// ── Final Reset Confirmation ──────────────────────────────────
class _FinalResetConfirmDialog extends StatefulWidget {
  final AppLocalizations l;
  const _FinalResetConfirmDialog({required this.l});
  @override State<_FinalResetConfirmDialog> createState() => _FinalResetConfirmDialogState();
}
class _FinalResetConfirmDialogState extends State<_FinalResetConfirmDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;
  @override void initState() { super.initState(); _controller.addListener(() { setState(() => _confirmed = _controller.text.trim() == widget.l.settingsResetKeyword); }); }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return AlertDialog(
      title: Text(l.settingsResetStep2Title),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.settingsResetStep2Body),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: TripReadyTheme.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: TripReadyTheme.danger.withOpacity(0.4))),
          child: Text(l.settingsResetKeyword, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 20, color: TripReadyTheme.danger, letterSpacing: 6)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller, autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: l.settingsResetKeyword,
            errorText: _controller.text.isNotEmpty && !_confirmed ? l.resetConfirmMismatch : null,
            suffixIcon: _confirmed ? const Icon(Icons.check_circle, color: TripReadyTheme.success) : null,
          ),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _confirmed ? TripReadyTheme.danger : Colors.grey.shade300),
          onPressed: _confirmed ? () => Navigator.pop(context, true) : null,
          child: Text(l.settingsResetButton, style: TextStyle(color: _confirmed ? Colors.white : Colors.grey.shade500)),
        ),
      ],
    );
  }
}

// ── Shared Primitives ─────────────────────────────────────────

/// Icon container, always primary-colored
class _TileIcon extends StatelessWidget {
  final IconData icon;
  const _TileIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: primary, size: 22),
    );
  }
}

/// Reusable card wrapper for selector tiles (theme/font/color)
class _SelectorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SelectorCard({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _TileIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ])),
        ]),
      ),
    );
  }
}

/// Reusable animated selector button
class _SelectorButton extends StatelessWidget {
  final bool selected;
  final Color primary;
  final VoidCallback onTap;
  final Widget child;
  const _SelectorButton({required this.selected, required this.primary, required this.onTap, required this.child});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : primary.withOpacity(0.3), width: 1.5),
        ),
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: primary, letterSpacing: 1, fontSize: 11)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isDanger;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final iconColor = isDanger ? TripReadyTheme.danger : primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(Icons.chevron_right, color: onSurface.withOpacity(0.3)),
      ),
    );
  }
}

// ── Map Language tile ────────────────────────────────────────────────────────

class _MapLanguageTile extends StatefulWidget {
  const _MapLanguageTile();
  @override
  State<_MapLanguageTile> createState() => _MapLanguageTileState();
}

class _MapLanguageTileState extends State<_MapLanguageTile> {
  @override
  void initState() {
    super.initState();
    MapLanguageService.instance.addListener(_rebuild);
    MapLanguageService.instance.load();
  }

  @override
  void dispose() {
    MapLanguageService.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final follow = MapLanguageService.instance.followUiLanguage;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.language, color: primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Map labels language',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                follow
                    ? 'Place names match app language'
                    : 'Place names always in English',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          )),
          Switch(
            value: follow,
            activeColor: TripReadyTheme.teal,
            onChanged: (v) => MapLanguageService.instance.setFollowUiLanguage(v),
          ),
        ]),
      ),
    );
  }
}

// ── Recent Destinations tile ─────────────────────────────────────────────────

class _RecentDestinationsTile extends StatefulWidget {
  const _RecentDestinationsTile();
  @override
  State<_RecentDestinationsTile> createState() => _RecentDestinationsTileState();
}

class _RecentDestinationsTileState extends State<_RecentDestinationsTile> {
  List<RecentDestination> _items = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await RecentDestinationsService.instance.getAll();
    if (mounted) setState(() { _items = all.toList(); _loaded = true; });
  }

  Future<void> _removeOne(RecentDestination r) async {
    await RecentDestinationsService.instance.remove(r);
    _load();
  }

  Future<void> _clearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear recent destinations?'),
        content: const Text('This will remove all saved recent destinations.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: TripReadyTheme.danger),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await RecentDestinationsService.instance.clearAll();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (!_loaded) {
      return const Card(
        margin: EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_items.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Icon(Icons.history, color: primary.withOpacity(0.4), size: 22),
            const SizedBox(width: 16),
            Text('No recent destinations yet.',
                style: TextStyle(color: Theme.of(context)
                    .colorScheme.onSurface.withOpacity(0.5))),
          ]),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        // Header row with clear-all
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(children: [
            Icon(Icons.history, color: primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('${_items.length} saved destinations',
                style: Theme.of(context).textTheme.bodyMedium)),
            TextButton(
              onPressed: () => _clearAll(context),
              style: TextButton.styleFrom(foregroundColor: TripReadyTheme.danger),
              child: const Text('Clear all'),
            ),
          ]),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        ..._items.map((r) => Dismissible(
          key: ValueKey('${r.city}_${r.countryCode}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            color: TripReadyTheme.danger.withOpacity(0.12),
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: TripReadyTheme.danger),
          ),
          onDismissed: (_) => _removeOne(r),
          child: ListTile(
            dense: true,
            leading: FlagWidget(code: r.countryCode, size: 18),
            title: Text(r.city),
            subtitle: r.countryName != null
                ? Text(r.countryName!,
                    style: const TextStyle(fontSize: 11))
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: Colors.grey.shade400,
              onPressed: () => _removeOne(r),
            ),
          ),
        )),
        const SizedBox(height: 8),
      ]),
    );
  }
}
