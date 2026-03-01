import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/packing.dart';
import '../../database/database_helper.dart';
import '../../database/packing_database.dart';
import '../../theme/app_theme.dart';
import '../../services/localization_ext.dart';

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
  final _newTaskController = TextEditingController();
  final _customStorageController = TextEditingController();

  String? _storagePlaceSelected;
  bool _showCustomStorage = false;
  String? _category;
  int _quantity = 1;
  PackingStatus _status = PackingStatus.notPacked;
  List<PackingItemTask> _tasks = [];
  bool _isSaving = false;
  String? _pendingStoragePlace; // holds raw DB value until l10n is ready

  bool get _isEditing => widget.item != null;

  List<String> _packingCategories(AppLocalizations l) => [
    l.packingCatClothing, l.packingCatToiletries, l.packingCatElectronics,
    l.packingCatDocuments, l.packingCatMedication, l.packingCatFoodSnacks,
    l.packingCatAccessories, l.packingCatSportOutdoor, l.packingCatBabyKids,
    l.packingCatWorkOffice, l.packingCatOther,
  ];

  List<String> _storagePlaces(AppLocalizations l) => [
    l.storageCheckin, l.storageHandLuggage, l.storageBackpack, l.storageToiletryBag,
    l.storageLaptopBag, l.storageHandbag, l.storageWallet, l.storageMoneyBelt,
    l.storageCarBoot, l.storageShippingBox, l.storageOther,
  ];

  String? _resolvedStoragePlace(AppLocalizations l) {
    if (_showCustomStorage) {
      final v = _customStorageController.text.trim();
      return v.isEmpty ? null : v;
    }
    if (_storagePlaceSelected == null || _storagePlaceSelected == l.storageOther) return null;
    return _storagePlaceSelected;
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.item!;
      _nameController.text = item.name;
      _notesController.text = item.notes ?? '';
      _category = item.category;
      _quantity = item.quantity;
      _status = item.status;
      _tasks = List.from(item.tasks);
      _pendingStoragePlace = item.storagePlace;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pendingStoragePlace != null) {
      final l = context.l;
      final places = _storagePlaces(l);
      if (places.contains(_pendingStoragePlace)) {
        _storagePlaceSelected = _pendingStoragePlace;
      } else {
        _storagePlaceSelected = l.storageOther;
        _showCustomStorage = true;
        _customStorageController.text = _pendingStoragePlace!;
      }
      _pendingStoragePlace = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose(); _notesController.dispose();
    _newTaskController.dispose(); _customStorageController.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(PackingItemTask(
        id: const Uuid().v4(), packingItemId: widget.item?.id ?? '',
        tripId: widget.tripId, description: text, createdAt: DateTime.now(),
      ));
      _newTaskController.clear();
    });
  }

  void _removeTask(int index) => setState(() => _tasks.removeAt(index));

  Future<void> _save() async {
    final l = context.l;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final db = DatabaseHelper.instance;
      final now = DateTime.now();
      final storage = _resolvedStoragePlace(l);
      if (_isEditing) {
        await db.updatePackingItem(widget.item!.copyWith(
          name: _nameController.text.trim(), category: _category,
          quantity: _quantity, storagePlace: storage, status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        ));
        final rawDb = await db.database;
        await rawDb.delete('packing_item_tasks', where: 'packing_item_id = ?', whereArgs: [widget.item!.id]);
        for (final task in _tasks) {
          await db.insertPackingItemTask(PackingItemTask(
            id: task.id, packingItemId: widget.item!.id, tripId: widget.tripId,
            description: task.description, isDone: task.isDone, createdAt: task.createdAt,
          ));
        }
      } else {
        final newId = const Uuid().v4();
        await db.insertPackingItem(PackingItem(
          id: newId, tripId: widget.tripId, name: _nameController.text.trim(),
          category: _category, quantity: _quantity, storagePlace: storage, status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: now,
        ));
        for (final task in _tasks) {
          await db.insertPackingItemTask(PackingItemTask(
            id: task.id, packingItemId: newId, tripId: widget.tripId,
            description: task.description, isDone: task.isDone, createdAt: task.createdAt,
          ));
        }
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
    final l = context.l;
    final categories = _packingCategories(l);
    final storagePlaces = _storagePlaces(l);
    final catValue = categories.contains(_category) ? _category : null;
    final storeValue = storagePlaces.contains(_storagePlaceSelected) ? _storagePlaceSelected : null;

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
          DropdownButtonFormField<String>(
            value: catValue,
            decoration: InputDecoration(hintText: l.packingSelectCategory, prefixIcon: const Icon(Icons.label_outline)),
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v),
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
          DropdownButtonFormField<String>(
            value: storeValue,
            decoration: InputDecoration(hintText: l.packingStoragePlaceHint, prefixIcon: const Icon(Icons.luggage_outlined)),
            items: storagePlaces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) {
              setState(() {
                _storagePlaceSelected = v;
                _showCustomStorage = v == l.storageOther;
                if (!_showCustomStorage) _customStorageController.clear();
              });
            },
          ),
          if (_showCustomStorage) ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: _customStorageController,
              decoration: InputDecoration(hintText: l.packingCustomStorageHint, prefixIcon: const Icon(Icons.edit_outlined)),
              autofocus: true,
            ),
          ],
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
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.packingItemTasksLabel, style: Theme.of(context).textTheme.headlineSmall),
            Text(l.packingItemTasksHint, style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _newTaskController,
              decoration: InputDecoration(hintText: l.packingAddTaskHint, prefixIcon: const Icon(Icons.add_task_outlined)),
              onFieldSubmitted: (_) => _addTask())),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                backgroundColor: TripReadyTheme.teal),
              child: const Icon(Icons.add, color: Colors.white)),
          ]),
          if (_tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._tasks.asMap().entries.map((e) => _TaskInputRow(
              task: e.value,
              onRemove: () => _removeTask(e.key),
              onToggle: () => setState(() {
                _tasks[e.key] = _tasks[e.key].copyWith(isDone: !_tasks[e.key].isDone);
              }),
            )),
          ],

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

class _TaskInputRow extends StatelessWidget {
  final PackingItemTask task;
  final VoidCallback onRemove;
  final VoidCallback onToggle;
  const _TaskInputRow({required this.task, required this.onRemove, required this.onToggle});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: task.isDone ? TripReadyTheme.success.withOpacity(0.06) : TripReadyTheme.warmGrey.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: task.isDone ? TripReadyTheme.success.withOpacity(0.3) : Colors.transparent)),
    child: Row(children: [
      GestureDetector(onTap: onToggle,
        child: Icon(task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isDone ? TripReadyTheme.success : TripReadyTheme.textLight, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Text(task.description, style: TextStyle(
        decoration: task.isDone ? TextDecoration.lineThrough : null,
        color: task.isDone ? TripReadyTheme.textMid : TripReadyTheme.textDark, fontSize: 14))),
      GestureDetector(onTap: onRemove,
        child: const Icon(Icons.close, size: 18, color: TripReadyTheme.textLight)),
    ]));
}
