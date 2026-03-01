import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/packing.dart';
import '../../database/database_helper.dart';
import '../../database/packing_database.dart';
import '../../theme/app_theme.dart';

class SaveTemplateDialog extends StatefulWidget {
  final List<PackingItem> items;

  const SaveTemplateDialog({super.key, required this.items});

  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<SaveTemplateDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final templateId = const Uuid().v4();
      final template = PackingTemplate(
        id: templateId,
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        createdAt: DateTime.now(),
        items: widget.items.map((item) => PackingTemplateItem(
          id: const Uuid().v4(),
          templateId: templateId,
          name: item.name,
          category: item.category,
          quantity: item.quantity,
          storagePlace: item.storagePlace,
        )).toList(),
      );

      await DatabaseHelper.instance.savePackingTemplate(template);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving template: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save as Template'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will save ${widget.items.length} item(s) as a reusable template.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Template Name *',
              hintText: 'e.g. Summer Holiday Packing',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. For 1-2 week beach trips',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Template'),
        ),
      ],
    );
  }
}

class LoadTemplateDialog extends StatefulWidget {
  final String tripId;

  const LoadTemplateDialog({super.key, required this.tripId});

  @override
  State<LoadTemplateDialog> createState() => _LoadTemplateDialogState();
}

class _LoadTemplateDialogState extends State<LoadTemplateDialog> {
  List<PackingTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final templates = await DatabaseHelper.instance.getPackingTemplates();
    setState(() {
      _templates = templates;
      _isLoading = false;
    });
  }

  Future<void> _loadTemplate(PackingTemplate template) async {
    await DatabaseHelper.instance.loadTemplateIntoTrip(template.id, widget.tripId);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteTemplate(PackingTemplate template) async {
    await DatabaseHelper.instance.deletePackingTemplate(template.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load Template'),
      content: SizedBox(
        width: double.maxFinite,
        height: 320,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : _templates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_open_outlined,
                            size: 48, color: TripReadyTheme.textLight),
                        const SizedBox(height: 12),
                        Text('No templates saved yet',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text('Save a packing list as a template first.',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final t = _templates[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: TripReadyTheme.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.folder_outlined,
                              color: TripReadyTheme.teal, size: 20),
                        ),
                        title: Text(t.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(
                          t.description ?? '${t.items.length} items',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${t.items.length} items',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: TripReadyTheme.teal)),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: TripReadyTheme.danger),
                              onPressed: () => _deleteTemplate(t),
                            ),
                          ],
                        ),
                        onTap: () => _loadTemplate(t),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
