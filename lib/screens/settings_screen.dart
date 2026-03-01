import 'package:flutter/material.dart';
import '../database/backup_service.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionLabel('Data Management'),
          _SettingsTile(
            icon: Icons.upload_outlined,
            title: 'Export Backup',
            subtitle: 'Save a copy of all your trip data',
            color: TripReadyTheme.teal,
            onTap: () => _exportBackup(context),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Restore Backup',
            subtitle: 'Restore from a previously exported backup file',
            color: TripReadyTheme.amber,
            onTap: () => _importBackup(context),
          ),

          const SizedBox(height: 24),
          _SectionLabel('Danger Zone'),
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Reset App Data',
            subtitle: 'Permanently delete all trips, packing lists, tasks and all other data',
            color: TripReadyTheme.danger,
            onTap: () => _resetAppData(context),
          ),

          const SizedBox(height: 24),
          _SectionLabel('About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'TripReady',
            subtitle: 'Version 1.0.0 · Personal travel planner',
            color: TripReadyTheme.navy,
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final path = await BackupService.instance.exportBackup();
    if (path != null) {
      scaffoldMsg.showSnackBar(SnackBar(
        content: Text('Backup saved to:\n$path'),
        duration: const Duration(seconds: 6),
      ));
    } else {
      scaffoldMsg.showSnackBar(
          const SnackBar(content: Text('Backup failed. No data found.')));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace ALL current data with the backup file. '
          'Your current data will be lost.\n\nContinue?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TripReadyTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await BackupService.instance.importBackup();
    if (success) {
      scaffoldMsg.showSnackBar(const SnackBar(
        content: Text('Backup restored successfully. Please restart the app.'),
        duration: Duration(seconds: 5),
      ));
    } else {
      scaffoldMsg.showSnackBar(const SnackBar(
          content: Text('Restore failed or cancelled. Your data is unchanged.')));
    }
  }

  Future<void> _resetAppData(BuildContext context) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);

    // ── Step 1: first warning ──
    final step1 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(children: const [
          Icon(Icons.warning_amber_rounded, color: TripReadyTheme.danger, size: 26),
          SizedBox(width: 10),
          Text('Reset App Data'),
        ]),
        content: const Text(
          'This will permanently delete EVERYTHING:\n\n'
          '• All trips (active, planned and archived)\n'
          '• All packing lists and templates\n'
          '• All tasks, addresses and documents\n'
          '• All receipts and expense records\n\n'
          'This action CANNOT be undone.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TripReadyTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (step1 != true) return;

    // ── Step 2: typed confirmation ──
    final step2 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FinalResetConfirmDialog(),
    );
    if (step2 != true) return;

    // ── Execute ──
    try {
      await DatabaseHelper.instance.resetAllData();
      if (context.mounted) {
        // Rebuild the entire shell so all screens reinitialise from scratch
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMsg.showSnackBar(SnackBar(content: Text('Reset failed: $e')));
      }
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'TripReady',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Personal travel planner.\nAll data stored locally on your device.',
    );
  }
}

// ── Final confirmation dialog with typed keyword ──────────────
class _FinalResetConfirmDialog extends StatefulWidget {
  const _FinalResetConfirmDialog();

  @override
  State<_FinalResetConfirmDialog> createState() =>
      _FinalResetConfirmDialogState();
}

class _FinalResetConfirmDialogState extends State<_FinalResetConfirmDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;
  static const _keyword = 'RESET';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _confirmed = _controller.text.trim() == _keyword);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Final Confirmation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('To confirm, type the word below exactly as shown:'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: TripReadyTheme.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: TripReadyTheme.danger.withOpacity(0.4)),
            ),
            child: const Text(
              _keyword,
              style: TextStyle(
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
              hintText: 'Type $_keyword here',
              errorText: _controller.text.isNotEmpty && !_confirmed
                  ? 'Must match exactly'
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
            child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _confirmed ? TripReadyTheme.danger : Colors.grey.shade300,
          ),
          onPressed: _confirmed ? () => Navigator.pop(context, true) : null,
          child: Text(
            'Reset Everything',
            style: TextStyle(
                color: _confirmed ? Colors.white : Colors.grey.shade500),
          ),
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
          width: 44,
          height: 44,
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
