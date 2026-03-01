import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/packing.dart';
import '../../database/database_helper.dart';
import '../../database/packing_database.dart';
import '../../theme/app_theme.dart';

const List<String> kPackingCategories = [
  'Clothing',
  'Toiletries',
  'Electronics',
  'Documents',
  'Medication',
  'Food & Snacks',
  'Accessories',
  'Sport & Outdoor',
  'Baby & Kids',
  'Work & Office',
  'Other',
];

const List<String> kStoragePlaces = [
  'Check-in Luggage',
  'Hand Luggage',
  'Backpack',
  'Toiletry Bag',
  'Laptop Bag',
  'Handbag / Purse',
  'Wallet',
  'Money Belt',
  'Car Boot',
  'Shipping Box',
  'Other',
];

class AddEditPackingItemScreen extends StatefulWidget {
  final String tripId;
  final PackingItem? item;

  const AddEditPackingItemScreen({
    super.key,
    required this.tripId,
    this.item,
  });

  @override
  State<AddEditPackingItemScreen> createState() =>
      _AddEditPackingItemScreenState();
}

class _AddEditPackingItemScreenState extends State<AddEditPackingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _newTaskController = TextEditingController();

  // Storage place: tracks both selected preset and any custom typed value
  String? _storagePlaceSelected; // value from dropdown (null = none selected)
  final _customStorageController = TextEditingController();
  bool _showCustomStorage = false;

  String? _category;
  int _quantity = 1;
  PackingStatus _status = PackingStatus.notPacked;
  List<PackingItemTask> _tasks = [];
  bool _isSaving = false;

  bool get _isEditing => widget.item != null;

  // Resolves the actual storage place string to save
  String? get _resolvedStoragePlace {
    if (_showCustomStorage) {
      final v = _customStorageController.text.trim();
      return v.isEmpty ? null : v;
    }
    if (_storagePlaceSelected == 'Other') return null;
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

      // Restore storage place
      if (item.storagePlace != null) {
        if (kStoragePlaces.contains(item.storagePlace)) {
          _storagePlaceSelected = item.storagePlace;
        } else {
          _storagePlaceSelected = 'Other';
          _showCustomStorage = true;
          _customStorageController.text = item.storagePlace!;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _newTaskController.dispose();
    _customStorageController.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(PackingItemTask(
        id: const Uuid().v4(),
        packingItemId: widget.item?.id ?? '',
        tripId: widget.tripId,
        description: text,
        createdAt: DateTime.now(),
      ));
      _newTaskController.clear();
    });
  }

  void _removeTask(int index) => setState(() => _tasks.removeAt(index));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final db = DatabaseHelper.instance;
      final now = DateTime.now();

      if (_isEditing) {
        final updated = widget.item!.copyWith(
          name: _nameController.text.trim(),
          category: _category,
          quantity: _quantity,
          storagePlace: _resolvedStoragePlace,
          status: _status,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await db.updatePackingItem(updated);
        final rawDb = await db.database;
        await rawDb.delete('packing_item_tasks',
            where: 'packing_item_id = ?', whereArgs: [widget.item!.id]);
        for (final task in _tasks) {
          await db.insertPackingItemTask(PackingItemTask(
            id: task.id,
            packingItemId: widget.item!.id,
            tripId: widget.tripId,
            description: task.description,
            isDone: task.isDone,
            createdAt: task.createdAt,
          ));
        }
      } else {
        final newId = const Uuid().v4();
        await db.insertPackingItem(PackingItem(
          id: newId,
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          category: _category,
          quantity: _quantity,
          storagePlace: _resolvedStoragePlace,
          status: _status,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
        ));
        for (final task in _tasks) {
          await db.insertPackingItemTask(PackingItemTask(
            id: task.id,
            packingItemId: newId,
            tripId: widget.tripId,
            description: task.description,
            isDone: task.isDone,
            createdAt: task.createdAt,
          ));
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving item: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Name ──
            _label('Item Name *'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Passport, Charger, T-shirt...',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Item name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Category ──
            _label('Category'),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                hintText: 'Select a category',
                prefixIcon: Icon(Icons.label_outline),
              ),
              items: kPackingCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),

            // ── Quantity ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Quantity'),
                      Row(children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                        ),
                        const SizedBox(width: 12),
                        Text('$_quantity',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 12),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _quantity++),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Storage Place (combo-box) ──
            _label('Storage Place'),
            DropdownButtonFormField<String>(
              value: _storagePlaceSelected,
              decoration: const InputDecoration(
                hintText: 'Where will you store this?',
                prefixIcon: Icon(Icons.luggage_outlined),
              ),
              items: [
                ...kStoragePlaces.map((p) =>
                    DropdownMenuItem(value: p, child: Text(p))),
              ],
              onChanged: (v) {
                setState(() {
                  _storagePlaceSelected = v;
                  _showCustomStorage = v == 'Other';
                  if (!_showCustomStorage) _customStorageController.clear();
                });
              },
            ),
            // Custom storage place input — shown when 'Other' or when editing
            // an item whose storage value isn't in the preset list
            if (_showCustomStorage) ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _customStorageController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Luggage 23 kg, Camera Bag...',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                autofocus: true,
              ),
            ],
            const SizedBox(height: 16),

            // ── Status (edit only) ──
            if (_isEditing) ...[
              _label('Status'),
              Row(children: [
                Expanded(
                    child: _StatusToggle(
                  label: 'Not Packed',
                  icon: Icons.radio_button_unchecked,
                  selected: _status == PackingStatus.notPacked,
                  color: TripReadyTheme.textMid,
                  onTap: () =>
                      setState(() => _status = PackingStatus.notPacked),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatusToggle(
                  label: 'Packed',
                  icon: Icons.check_circle_outline,
                  selected: _status == PackingStatus.packed,
                  color: TripReadyTheme.success,
                  onTap: () => setState(() => _status = PackingStatus.packed),
                )),
              ]),
              const SizedBox(height: 16),
            ],

            // ── Notes ──
            _label('Notes (optional)'),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any notes about this item...',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // ── Sub-tasks ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item Tasks',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('e.g. to buy, to iron',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _newTaskController,
                  decoration: const InputDecoration(
                    hintText: 'Add a task for this item...',
                    prefixIcon: Icon(Icons.add_task_outlined),
                  ),
                  onFieldSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    backgroundColor: TripReadyTheme.teal),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ]),
            if (_tasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._tasks.asMap().entries.map((e) => _TaskInputRow(
                    task: e.value,
                    onRemove: () => _removeTask(e.key),
                    onToggle: () => setState(() {
                      _tasks[e.key] =
                          _tasks[e.key].copyWith(isDone: !_tasks[e.key].isDone);
                    }),
                  )),
            ],

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Update Item' : 'Add Item'),
            ),
          ],
        ),
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
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: TripReadyTheme.warmGrey,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: TripReadyTheme.textDark),
        ),
      );
}

class _StatusToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusToggle(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? color : TripReadyTheme.warmGrey,
                width: selected ? 2 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: selected ? color : TripReadyTheme.textMid),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? color : TripReadyTheme.textMid,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13)),
          ]),
        ),
      );
}

class _TaskInputRow extends StatelessWidget {
  final PackingItemTask task;
  final VoidCallback onRemove;
  final VoidCallback onToggle;

  const _TaskInputRow(
      {required this.task, required this.onRemove, required this.onToggle});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: task.isDone
              ? TripReadyTheme.success.withOpacity(0.06)
              : TripReadyTheme.warmGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: task.isDone
                  ? TripReadyTheme.success.withOpacity(0.3)
                  : Colors.transparent),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              task.isDone
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: task.isDone
                  ? TripReadyTheme.success
                  : TripReadyTheme.textLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(task.description,
                style: TextStyle(
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? TripReadyTheme.textMid
                        : TripReadyTheme.textDark,
                    fontSize: 14)),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 18, color: TripReadyTheme.textLight),
          ),
        ]),
      );
}
