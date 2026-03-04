import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/packing.dart'; // PackingItem, PackingStatus
import '../../database/database_helper.dart';
import '../../database/packing_database.dart';
import '../../theme/app_theme.dart';
import '../../services/localization_ext.dart';
import '../../services/lookup_service.dart';
import '../../database/trip_details_database.dart';
import '../../services/language_service.dart';
import '../../models/lookup_value.dart';

class AddEditPackingItemScreen extends StatefulWidget {
  final String tripId;
  final PackingItem? item;
  const AddEditPackingItemScreen({super.key, required this.tripId, this.item});
  @override
  State<AddEditPackingItemScreen> createState() => _AddEditPackingItemScreenState();
}

class _AddEditPackingItemScreenState extends State<AddEditPackingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  // LookupValue IDs — resolved from LookupService
  String? _categoryId;
  String? _storageId;
  bool _trackAsTask = false; // create/maintain a linked task
  final _taskSubjectController = TextEditingController();
  String? _taskActionId; // selected packing action LookupValue.id
  int _quantity = 1;
  PackingStatus _status = PackingStatus.notPacked;
  bool _isSaving = false;

  bool get _isEditing => widget.item != null;

  /// Resolve _categoryId to display string for DB storage (use value_key).
  String? _resolvedCategory() {
    if (_categoryId == null) return null;
    final v = LookupService.instance.byId(LookupCategory.packingCategory, _categoryId!);
    return v?.valueKey ?? v?.displayEn;
  }

  /// Resolve _storageId to display string for DB storage (use value_key).
  String? _resolvedStoragePlace(AppLocalizations l) {
    if (_storageId == null) return null;
    final v = LookupService.instance.byId(LookupCategory.storageLocation, _storageId!);
    return v?.valueKey ?? v?.displayEn;
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.item!;
      _nameController.text  = item.name;
      _notesController.text = item.notes ?? '';
      _quantity = item.quantity;
      _status   = item.status;
      // Resolve stored value_key → LookupValue.id
      _categoryId = LookupService.instance
          .resolve(LookupCategory.packingCategory, item.category)?.id;
      _storageId  = LookupService.instance
          .resolve(LookupCategory.storageLocation, item.storagePlace)?.id;
      // Check if a linked task already exists and pre-fill subject
      DatabaseHelper.instance.getTaskForPackingItem(widget.item!.id).then((task) {
        if (mounted && task != null) {
          setState(() {
            _trackAsTask = true;
            _taskSubjectController.text = task.name;
          });
        }
      });
    }
  }



  @override
  void dispose() {
    _nameController.dispose(); _notesController.dispose();
    _taskSubjectController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l    = context.l;
    final lang = LanguageService.instance.locale.languageCode;
    final isHe = lang == 'he';
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    String? newId;
    try {
      final db = DatabaseHelper.instance;
      final now = DateTime.now();
      final storage = _resolvedStoragePlace(l);
      final category = _resolvedCategory();
      if (_isEditing) {
        await db.updatePackingItem(widget.item!.copyWith(
          name: _nameController.text.trim(), category: category,
          quantity: _quantity, storagePlace: storage, status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        ));

      } else {
        newId = const Uuid().v4();
        await db.insertPackingItem(PackingItem(
          id: newId, tripId: widget.tripId, name: _nameController.text.trim(),
          category: category, quantity: _quantity, storagePlace: storage, status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: now,
        ));

      }
      // Handle track-as-task toggle
      final savedItemId = _isEditing ? widget.item!.id : newId;
      if (_trackAsTask) {
        final action  = _taskActionId == null ? null
            : LookupService.instance.byId(LookupCategory.packingAction, _taskActionId!);
        final subject = _taskSubjectController.text.trim();
        final itemName = _nameController.text.trim();
        // Build task name: "Buy: Passport" / "Passport" (no action) / subject override
        final taskName = subject.isNotEmpty
            ? subject
            : action != null
                ? '${action.label(lang)}: $itemName'
                : itemName;
        await DatabaseHelper.instance.upsertPackingTask(
          tripId: widget.tripId,
          packingItemId: savedItemId ?? '',
          itemName: taskName,
        );
      } else if (_isEditing) {
        // User turned off tracking — remove linked task if it exists
        await DatabaseHelper.instance.deleteTaskForPackingItem(widget.item!.id);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l.packingErrorSaving}: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l    = context.l;
    final lang = LanguageService.instance.locale.languageCode;
    final isHe = lang == 'he';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.packingEditItem : l.packingAddItem),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
          else
            TextButton(onPressed: _save,
              child: Text(l.actionSave, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [

          _label(l.packingItemName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.packingItemNameHint, prefixIcon: const Icon(Icons.inventory_2_outlined)),
            validator: (v) => (v == null || v.trim().isEmpty) ? l.packingItemNameRequired : null,
          ),
          const SizedBox(height: 16),

          _label(l.fieldCategory),
          _PackingLookupDropdown(
            cat: LookupCategory.packingCategory,
            selectedId: _categoryId,
            hint: l.packingSelectCategory,
            icon: Icons.label_outline,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          const SizedBox(height: 16),

          _label(l.fieldQuantity),
          Row(children: [
            _QtyButton(icon: Icons.remove, onTap: () { if (_quantity > 1) setState(() => _quantity--); }),
            const SizedBox(width: 16),
            Text('$_quantity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 16),
            _QtyButton(icon: Icons.add, onTap: () => setState(() => _quantity++)),
          ]),
          const SizedBox(height: 16),

          _label(l.fieldStoragePlace),
          _PackingLookupDropdown(
            cat: LookupCategory.storageLocation,
            selectedId: _storageId,
            hint: l.packingStoragePlaceHint,
            icon: Icons.luggage_outlined,
            onChanged: (id) => setState(() => _storageId = id),
          ),
          const SizedBox(height: 16),

          if (_isEditing) ...[
            _label(l.fieldStatus),
            Row(children: [
              Expanded(child: _StatusToggle(label: l.packingStatusNotPacked, icon: Icons.radio_button_unchecked,
                selected: _status == PackingStatus.notPacked, color: TripReadyTheme.textMid,
                onTap: () => setState(() => _status = PackingStatus.notPacked))),
              const SizedBox(width: 10),
              Expanded(child: _StatusToggle(label: l.packingStatusPacked, icon: Icons.check_circle_outline,
                selected: _status == PackingStatus.packed, color: TripReadyTheme.success,
                onTap: () => setState(() => _status = PackingStatus.packed))),
            ]),
            const SizedBox(height: 16),
          ],

          _label(l.fieldNotes),
          TextFormField(controller: _notesController, maxLines: 2,
            decoration: InputDecoration(hintText: l.packingNotesHint,
              prefixIcon: const Icon(Icons.notes_outlined), alignLabelWithHint: true)),
          const SizedBox(height: 16),

          // ── Track as Task ─────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _trackAsTask
                  ? TripReadyTheme.teal.withOpacity(0.06)
                  : TripReadyTheme.warmGrey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _trackAsTask
                    ? TripReadyTheme.teal.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header row — toggle
              Row(children: [
                Icon(Icons.task_alt_outlined,
                    size: 20,
                    color: _trackAsTask ? TripReadyTheme.teal : TripReadyTheme.textMid),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    isHe ? 'מעקב כמשימה' : 'Track as Task',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _trackAsTask ? TripReadyTheme.teal : TripReadyTheme.textDark,
                    ),
                  ),
                  Text(
                    isHe
                        ? 'הצג פריט זה בלשונית משימות למעקב'
                        : 'Show this item in the Tasks tab for follow-up',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TripReadyTheme.textMid,
                    ),
                  ),
                ])),
                Switch(
                  value: _trackAsTask,
                  activeColor: TripReadyTheme.teal,
                  onChanged: (v) => setState(() {
                    _trackAsTask = v;
                    if (!v) {
                      _taskActionId = null;
                      _taskSubjectController.clear();
                    }
                  }),
                ),
              ]),

              // Expanded inline task setup — shown when toggle is on
              if (_trackAsTask) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Action dropdown
                Text(
                  isHe ? 'פעולה' : 'Action',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: TripReadyTheme.textMid),
                ),
                const SizedBox(height: 6),
                _PackingLookupDropdown(
                  cat: LookupCategory.packingAction,
                  selectedId: _taskActionId,
                  hint: isHe ? 'בחר פעולה (אופציונלי)' : 'Select action (optional)',
                  icon: Icons.bolt_outlined,
                  onChanged: (id) => setState(() => _taskActionId = id),
                ),
                const SizedBox(height: 12),

                // Subject override field
                Text(
                  isHe ? 'נושא המשימה' : 'Task subject',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: TripReadyTheme.textMid),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _taskSubjectController,
                  decoration: InputDecoration(
                    hintText: isHe
                        ? 'כברירת מחדל: פעולה + שם הפריט'
                        : 'Default: action + item name',
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHe
                      ? 'השאר ריק לשימוש בפעולה ושם הפריט אוטומטית'
                      : 'Leave empty to auto-build from action and item name',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TripReadyTheme.textMid,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.check),
            label: Text(_isEditing ? l.packingUpdateItem : l.packingAddItem),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: TripReadyTheme.warmGrey, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: TripReadyTheme.textDark)));
}

class _StatusToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusToggle({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? color : TripReadyTheme.warmGrey, width: selected ? 2 : 1),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: selected ? color : TripReadyTheme.textMid),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: selected ? color : TripReadyTheme.textMid,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400, fontSize: 13)),
      ])));
}


// ── Packing lookup dropdown ───────────────────────────────────────────────────

class _PackingLookupDropdown extends StatelessWidget {
  const _PackingLookupDropdown({
    required this.cat,
    required this.selectedId,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  final LookupCategory cat;
  final String? selectedId;
  final String hint;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final lang   = LanguageService.instance.locale.languageCode;
    final values = LookupService.instance.enabled(cat);
    final currentId = values.any((v) => v.id == selectedId)
        ? selectedId
        : null;

    return DropdownButtonFormField<String>(
      value: currentId,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(hint,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4))),
        ),
        ...values.map((v) =>
            DropdownMenuItem(value: v.id, child: Text(v.label(lang)))),
      ],
      onChanged: onChanged,
    );
  }
}
