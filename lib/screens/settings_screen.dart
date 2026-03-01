import 'package:flutter/material.dart';
import 'package:tripready/l10n/app_localizations.dart';
import '../database/backup_service.dart';
import '../database/database_helper.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Language ──
          _SectionLabel(l.settingsLanguage),
          const _LanguageTile(),

          const SizedBox(height: 24),

          // ── Data Management ──
          _SectionLabel(l.settingsDataManagement),
          _SettingsTile(
            icon: Icons.upload_outlined,
            title: l.settingsExportBackup,
            subtitle: l.settingsExportBackupSubtitle,
            color: TripReadyTheme.teal,
            onTap: () => _exportBackup(context, l),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: l.settingsRestoreBackup,
            subtitle: l.settingsRestoreBackupSubtitle,
            color: TripReadyTheme.amber,
            onTap: () => _importBackup(context, l),
          ),

          const SizedBox(height: 24),

          // ── Danger Zone ──
          _SectionLabel(l.settingsDangerZone),
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: l.settingsResetData,
            subtitle: l.settingsResetDataSubtitle,
            color: TripReadyTheme.danger,
            onTap: () => _resetAppData(context, l),
          ),

          const SizedBox(height: 24),

          // ── About ──
          _SectionLabel(l.settingsAbout),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l.appTitle,
            subtitle: l.settingsAboutSubtitle,
            color: TripReadyTheme.navy,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'TripReady',
              applicationVersion: '1.1.0',
              applicationLegalese:
                  'Personal travel planner.\nAll data stored locally on your device.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, AppLocalizations l) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final path = await BackupService.instance.exportBackup();
    if (path != null) {
      scaffoldMsg.showSnackBar(SnackBar(
        content: Text('${l.settingsExportBackup}:\n$path'),
        duration: const Duration(seconds: 6),
      ));
    } else {
      scaffoldMsg.showSnackBar(
          SnackBar(content: Text(l.settingsBackupFailed)));
    }
  }

  Future<void> _importBackup(BuildContext context, AppLocalizations l) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.settingsRestoreConfirmTitle),
        content: Text(l.settingsRestoreConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.actionCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: TripReadyTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.settingsRestoreBackup),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await BackupService.instance.importBackup();
    scaffoldMsg.showSnackBar(SnackBar(
      content: Text(success
          ? l.backupRestoredSuccess
          : l.backupRestoreFailed),
    ));
  }

  Future<void> _resetAppData(BuildContext context, AppLocalizations l) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);

    final step1 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: TripReadyTheme.danger, size: 26),
          const SizedBox(width: 10),
          Text(l.settingsResetStep1Title),
        ]),
        content: Text(l.settingsResetStep1Body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.actionCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: TripReadyTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.settingsContinue),
          ),
        ],
      ),
    );
    if (step1 != true) return;

    final step2 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FinalResetConfirmDialog(l: l),
    );
    if (step2 != true) return;

    try {
      await DatabaseHelper.instance.resetAllData();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMsg.showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

// ── Language Dropdown Tile ────────────────────────────────────
class _LanguageTile extends StatefulWidget {
  const _LanguageTile();

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile> {
  @override
  void initState() {
    super.initState();
    LanguageService.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentCode = LanguageService.instance.locale.languageCode;

    final options = [
      _LangOption(code: 'en', label: l.langEnglish, flag: '🇬🇧'),
      _LangOption(code: 'he', label: l.langHebrew, flag: '🇮🇱'),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: TripReadyTheme.navy.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language_outlined,
                color: TripReadyTheme.navy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.settingsSelectLanguage,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: currentCode,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: TripReadyTheme.warmGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: TripReadyTheme.teal, width: 2),
                  ),
                ),
                items: options.map((opt) => DropdownMenuItem<String>(
                  value: opt.code,
                  child: Row(children: [
                    Text(opt.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(opt.label, style: const TextStyle(fontSize: 14)),
                  ]),
                )).toList(),
                onChanged: (code) {
                  if (code != null) {
                    LanguageService.instance.setLocale(Locale(code));
                  }
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String label;
  final String flag;
  const _LangOption({required this.code, required this.label, required this.flag});
}

// ── Final Reset Confirmation ──────────────────────────────────
class _FinalResetConfirmDialog extends StatefulWidget {
  final AppLocalizations l;
  const _FinalResetConfirmDialog({required this.l});

  @override
  State<_FinalResetConfirmDialog> createState() =>
      _FinalResetConfirmDialogState();
}

class _FinalResetConfirmDialogState
    extends State<_FinalResetConfirmDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() =>
          _confirmed = _controller.text.trim() == widget.l.settingsResetKeyword);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return AlertDialog(
      title: Text(l.settingsResetStep2Title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.settingsResetStep2Body),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: TripReadyTheme.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TripReadyTheme.danger.withOpacity(0.4)),
            ),
            child: Text(
              l.settingsResetKeyword,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: TripReadyTheme.danger,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: l.settingsResetKeyword,
              errorText: _controller.text.isNotEmpty && !_confirmed
                  ? l.resetConfirmMismatch
                  : null,
              suffixIcon: _confirmed
                  ? const Icon(Icons.check_circle, color: TripReadyTheme.success)
                  : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.actionCancel)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _confirmed ? TripReadyTheme.danger : Colors.grey.shade300,
          ),
          onPressed:
              _confirmed ? () => Navigator.pop(context, true) : null,
          child: Text(l.settingsResetButton,
              style: TextStyle(
                  color: _confirmed ? Colors.white : Colors.grey.shade500)),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: TripReadyTheme.teal,
              letterSpacing: 1,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right, color: TripReadyTheme.textLight),
      ),
    );
  }
}
