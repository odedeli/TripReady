import 'package:flutter/material.dart';
import '../../models/lookup_value.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/lookup_service.dart';
import '../../services/language_service.dart';
import '../../theme/app_theme.dart';

/// Settings screen for managing all four customizable lookup lists.
class CustomizeListsScreen extends StatelessWidget {
  const CustomizeListsScreen({super.key});

  static const _titles = {
    LookupCategory.tripType:        ('Trip Type',        'סוג נסיעה'),
    LookupCategory.tripPurpose:     ('Trip Purpose',     'מטרת נסיעה'),
    LookupCategory.packingCategory: ('Packing Category', 'קטגוריית אריזה'),
    LookupCategory.storageLocation: ('Storage Location', 'מיקום אחסון'),
    LookupCategory.packingAction:     ('Packing Actions',  'פעולות אריזה'),
  };

  static const _icons = {
    LookupCategory.tripType:        Icons.category_outlined,
    LookupCategory.tripPurpose:     Icons.flag_outlined,
    LookupCategory.packingCategory: Icons.label_outline,
    LookupCategory.storageLocation: Icons.luggage_outlined,
    LookupCategory.packingAction:     Icons.bolt_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final lang   = LanguageService.instance.locale.languageCode;
    final isHe   = lang == 'he';
    final theme  = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(isHe ? 'התאמת רשימות' : 'Customize Lists'),
        leading: HomeButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isHe
                ? 'הפעל, בטל, שנה שם או הוסף ערכים לכל רשימת בחירה.'
                : 'Enable, disable, rename or add values to each dropdown list.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          for (final cat in LookupCategory.values) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icons[cat], color: primary, size: 20),
                ),
                title: Text(
                  isHe ? _titles[cat]!.$2 : _titles[cat]!.$1,
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: _EnabledCount(cat: cat, lang: lang),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _LookupListEditor(
                      cat: cat,
                      title: isHe ? _titles[cat]!.$2 : _titles[cat]!.$1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Shows "N enabled" subtitle, live-updated
class _EnabledCount extends StatefulWidget {
  final LookupCategory cat;
  final String lang;
  const _EnabledCount({required this.cat, required this.lang});
  @override
  State<_EnabledCount> createState() => _EnabledCountState();
}

class _EnabledCountState extends State<_EnabledCount> {
  @override
  void initState() {
    super.initState();
    LookupService.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    LookupService.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final total   = LookupService.instance.all(widget.cat).length;
    final enabled = LookupService.instance.enabled(widget.cat).length;
    final isHe    = widget.lang == 'he';
    return Text(
      isHe ? '$enabled מתוך $total פעילים' : '$enabled of $total enabled',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

// ── Per-category editor ───────────────────────────────────────────────────────

class _LookupListEditor extends StatefulWidget {
  final LookupCategory cat;
  final String title;
  const _LookupListEditor({required this.cat, required this.title});

  @override
  State<_LookupListEditor> createState() => _LookupListEditorState();
}

class _LookupListEditorState extends State<_LookupListEditor> {
  String get _lang => LanguageService.instance.locale.languageCode;
  bool get _isHe   => _lang == 'he';

  List<LookupValue> get _values => LookupService.instance.all(widget.cat);

  @override
  void initState() {
    super.initState();
    LookupService.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    LookupService.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _toggleEnabled(LookupValue v) async {
    // Prevent disabling the last enabled value
    if (v.isEnabled && LookupService.instance.enabled(widget.cat).length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isHe
            ? 'חייב להישאר לפחות ערך אחד פעיל'
            : 'At least one value must remain enabled'),
      ));
      return;
    }
    await LookupService.instance.toggleEnabled(v);
  }

  Future<void> _showAddDialog() async {
    final enCtrl = TextEditingController();
    final heCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isHe ? 'הוסף ערך חדש' : 'Add Custom Value'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: enCtrl,
              decoration: const InputDecoration(labelText: 'English'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heCtrl,
              decoration: const InputDecoration(labelText: 'עברית'),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_isHe ? 'ביטול' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final en = enCtrl.text.trim();
              if (en.isEmpty) return;
              await LookupService.instance.add(
                widget.cat,
                displayEn: en,
                displayHe: heCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(_isHe ? 'הוסף' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(LookupValue v) async {
    final enCtrl = TextEditingController(text: v.displayEn);
    final heCtrl = TextEditingController(text: v.displayHe);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isHe ? 'שנה שם' : 'Rename'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: enCtrl,
              decoration: const InputDecoration(labelText: 'English'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heCtrl,
              decoration: const InputDecoration(labelText: 'עברית'),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_isHe ? 'ביטול' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final en = enCtrl.text.trim();
              if (en.isEmpty) return;
              await LookupService.instance.rename(
                v,
                displayEn: en,
                displayHe: heCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(_isHe ? 'שמור' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(LookupValue v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isHe ? 'מחק ערך' : 'Delete Value'),
        content: Text(_isHe
            ? 'האם למחוק את "${v.label(_lang)}"?'
            : 'Delete "${v.label(_lang)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_isHe ? 'ביטול' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: TripReadyTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_isHe ? 'מחק' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LookupService.instance.delete(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final values  = _values;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: _isHe ? 'הוסף ערך' : 'Add value',
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: values.isEmpty
          ? Center(child: Text(_isHe ? 'אין ערכים' : 'No values'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              itemCount: values.length,
              onReorder: (o, n) => LookupService.instance.reorder(widget.cat, o, n),
              itemBuilder: (_, i) {
                final v = values[i];
                return Card(
                  key: ValueKey(v.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: Icon(Icons.drag_handle,
                          color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    title: Text(
                      v.label(_lang),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: v.isEnabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        decoration:
                            v.isEnabled ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: v.isDefault
                        ? Text(
                            _isHe ? 'ברירת מחדל' : 'Default',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: primary.withOpacity(0.6)),
                          )
                        : Text(
                            _isHe ? 'מותאם אישית' : 'Custom',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.tertiary
                                    .withOpacity(0.8)),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rename button
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18,
                              color: primary.withOpacity(0.7)),
                          onPressed: () => _showRenameDialog(v),
                          tooltip: _isHe ? 'שנה שם' : 'Rename',
                        ),
                        // Delete (custom only) or Enable/disable toggle
                        if (!v.isDefault)
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 18, color: TripReadyTheme.danger),
                            onPressed: () => _confirmDelete(v),
                            tooltip: _isHe ? 'מחק' : 'Delete',
                          )
                        else
                          Switch(
                            value: v.isEnabled,
                            activeColor: primary,
                            onChanged: (_) => _toggleEnabled(v),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
