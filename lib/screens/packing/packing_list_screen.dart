import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import '../../models/packing.dart';
import '../../models/trip.dart';
import '../../database/database_helper.dart';
import '../../database/packing_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'add_edit_packing_item_screen.dart';
import 'template_dialogs.dart';

class PackingListScreen extends StatefulWidget {
  final Trip trip;
  const PackingListScreen({super.key, required this.trip});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  List<PackingItem> _items = [];
  bool _isLoading = true;
  String? _filterCategory;
  bool _showPackedItems = true;

  // ── Multi-select state ──
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  bool get _allVisibleSelected {
    final visible = _filteredItems;
    return visible.isNotEmpty && visible.every((i) => _selectedIds.contains(i.id));
  }

  void _enterSelectMode(String firstId) {
    setState(() {
      _isSelecting = true;
      _selectedIds.add(firstId);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelecting = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allVisibleSelected) {
        _selectedIds.clear();
        _isSelecting = false;
      } else {
        _selectedIds.addAll(_filteredItems.map((i) => i.id));
      }
    });
  }

  List<PackingItem> get _selectedItems =>
      _items.where((i) => _selectedIds.contains(i.id)).toList();

  // ── Data ──
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await DatabaseHelper.instance.getPackingItems(widget.trip.id);
    setState(() {
      _items = items;
      _isLoading = false;
      // Clean up selected ids that no longer exist
      _selectedIds.retainWhere((id) => items.any((i) => i.id == id));
      if (_selectedIds.isEmpty) _isSelecting = false;
    });
  }

  List<PackingItem> get _filteredItems {
    var items = _items;
    if (_filterCategory != null) {
      items = items.where((i) => i.category == _filterCategory).toList();
    }
    if (!_showPackedItems) {
      items = items.where((i) => !i.isPacked).toList();
    }
    return items;
  }

  Map<String, List<PackingItem>> get _groupedItems {
    final Map<String, List<PackingItem>> grouped = {};
    for (final item in _filteredItems) {
      final cat = item.category ?? 'Uncategorised';
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  List<String> get _availableCategories => _items
      .map((i) => i.category ?? 'Uncategorised')
      .toSet()
      .toList()
    ..sort();

  int get _packedCount => _items.where((i) => i.isPacked).length;
  int get _totalCount => _items.length;

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final isArchived = widget.trip.isArchived;
    final selCount = _selectedIds.length;

    return WillPopScope(
      onWillPop: () async {
        if (_isSelecting) { _exitSelectMode(); return false; }
        return true;
      },
      child: Scaffold(
        appBar: _isSelecting
            ? _buildSelectionAppBar(selCount, isArchived)
            : _buildNormalAppBar(isArchived),
        floatingActionButton: _isSelecting || isArchived
            ? null
            : FloatingActionButton.extended(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : Column(children: [
                if (_totalCount > 0)
                  _ProgressBar(packed: _packedCount, total: _totalCount),
                if (_availableCategories.length > 1)
                  _FilterChips(
                    categories: _availableCategories,
                    selected: _filterCategory,
                    showPacked: _showPackedItems,
                    onCategorySelected: (c) => setState(() => _filterCategory = c),
                    onTogglePacked: () =>
                        setState(() => _showPackedItems = !_showPackedItems),
                  ),
                // Selection summary bar
                if (_isSelecting)
                  _SelectionBar(
                    selectedCount: selCount,
                    totalVisible: _filteredItems.length,
                    allSelected: _allVisibleSelected,
                    onToggleAll: _toggleSelectAll,
                  ),
                Expanded(
                  child: _items.isEmpty
                      ? EmptyState(
                          icon: Icons.backpack_outlined,
                          title: 'No items yet',
                          subtitle: isArchived
                              ? 'This trip is archived.'
                              : 'Add items manually, load a template, or import from Excel.',
                          buttonLabel: isArchived ? null : 'Add First Item',
                          onButtonPressed: isArchived ? null : _addItem,
                        )
                      : _filteredItems.isEmpty
                          ? const EmptyState(
                              icon: Icons.filter_list_off,
                              title: 'No items match filter',
                              subtitle: 'Try changing or clearing the filter.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: _groupedItems.length,
                              itemBuilder: (ctx, i) {
                                final entry = _groupedItems.entries.elementAt(i);
                                return _CategoryGroup(
                                  category: entry.key,
                                  items: entry.value,
                                  isArchived: isArchived,
                                  isSelecting: _isSelecting,
                                  selectedIds: _selectedIds,
                                  onToggle: _toggleItem,
                                  onEdit: _editItem,
                                  onDelete: _deleteItem,
                                  onLongPress: _enterSelectMode,
                                  onTapInSelectMode: _toggleSelection,
                                );
                              },
                            ),
                ),
              ]),
      ),
    );
  }

  // ── App Bars ──────────────────────────────────────────────
  AppBar _buildNormalAppBar(bool isArchived) {
    return AppBar(
      title: const Text('Packing List'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_outlined),
          onPressed: _showFilterSheet,
          tooltip: 'Filter',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) {
            switch (val) {
              case 'save_template': _saveAsTemplate(); break;
              case 'load_template': _loadTemplate(); break;
              case 'export_excel':  _exportExcel(); break;
              case 'import_excel':  _importExcel(); break;
              case 'uncheck_all':   _uncheckAll(); break;
              case 'delete_all':    _deleteAll(); break;
            }
          },
          itemBuilder: (_) => [
            if (!isArchived) ...[
              const PopupMenuItem(value: 'save_template',
                  child: ListTile(leading: Icon(Icons.save_outlined),        title: Text('Save as Template'),  contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'load_template',
                  child: ListTile(leading: Icon(Icons.folder_open_outlined), title: Text('Load Template'),     contentPadding: EdgeInsets.zero)),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'import_excel',
                  child: ListTile(leading: Icon(Icons.upload_file_outlined), title: Text('Import from Excel'), contentPadding: EdgeInsets.zero)),
            ],
            const PopupMenuItem(value: 'export_excel',
                child: ListTile(leading: Icon(Icons.table_chart_outlined),   title: Text('Export as Excel'),   contentPadding: EdgeInsets.zero)),
            if (!isArchived) ...[
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'uncheck_all',
                  child: ListTile(leading: Icon(Icons.unpublished_outlined, color: TripReadyTheme.amber),
                      title: Text('Uncheck All Items', style: TextStyle(color: TripReadyTheme.amber)), contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'delete_all',
                  child: ListTile(leading: Icon(Icons.delete_sweep_outlined, color: TripReadyTheme.danger),
                      title: Text('Delete All Items', style: TextStyle(color: TripReadyTheme.danger)), contentPadding: EdgeInsets.zero)),
            ],
          ],
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar(int selCount, bool isArchived) {
    return AppBar(
      backgroundColor: TripReadyTheme.navy,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _exitSelectMode,
        tooltip: 'Cancel selection',
      ),
      title: Text(
        '$selCount selected',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      actions: [
        // Mark as Packed
        IconButton(
          icon: const Icon(Icons.check_box_outlined, color: Colors.white),
          tooltip: 'Mark as Packed',
          onPressed: selCount == 0 ? null : () => _bulkSetStatus(PackingStatus.packed),
        ),
        // Mark as Not Packed
        IconButton(
          icon: const Icon(Icons.check_box_outline_blank, color: Colors.white),
          tooltip: 'Mark as Not Packed',
          onPressed: selCount == 0 ? null : () => _bulkSetStatus(PackingStatus.notPacked),
        ),
        // Edit (single selection only)
        if (selCount == 1)
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit',
            onPressed: () => _editItem(_selectedItems.first),
          ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          tooltip: 'Delete selected',
          onPressed: selCount == 0 ? null : _bulkDelete,
        ),
      ],
    );
  }

  // ── Single-item CRUD ──────────────────────────────────────
  Future<void> _addItem() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddEditPackingItemScreen(tripId: widget.trip.id)));
    if (result == true) _loadItems();
  }

  Future<void> _editItem(PackingItem item) async {
    _exitSelectMode();
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddEditPackingItemScreen(tripId: widget.trip.id, item: item)));
    if (result == true) _loadItems();
  }

  Future<void> _toggleItem(PackingItem item) async {
    await DatabaseHelper.instance.togglePackingItemStatus(item);
    _loadItems();
  }

  Future<void> _deleteItem(PackingItem item) async {
    final confirm = await showConfirmDialog(context,
        title: 'Delete Item', message: 'Delete "${item.name}"?', confirmLabel: 'Delete');
    if (confirm == true) {
      await DatabaseHelper.instance.deletePackingItem(item.id);
      _loadItems();
    }
  }

  // ── Bulk actions ──────────────────────────────────────────
  Future<void> _bulkSetStatus(PackingStatus status) async {
    final selected = List<PackingItem>.from(_selectedItems);
    if (selected.isEmpty) return;
    final label = status == PackingStatus.packed ? 'packed' : 'not packed';
    final confirm = await showConfirmDialog(
      context,
      title: status == PackingStatus.packed ? 'Mark as Packed' : 'Mark as Not Packed',
      message: 'Mark ${selected.length} item${selected.length > 1 ? 's' : ''} as $label?',
      confirmLabel: status == PackingStatus.packed ? 'Mark Packed' : 'Mark Unpacked',
      confirmColor: status == PackingStatus.packed ? TripReadyTheme.success : TripReadyTheme.teal,
    );
    if (confirm != true) return;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'packing_items',
      {'status': status.name},
      where: 'id IN (${selected.map((_) => '?').join(',')})',
      whereArgs: selected.map((i) => i.id).toList(),
    );
    _exitSelectMode();
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selected.length} item${selected.length > 1 ? 's' : ''} marked as $label.')),
      );
    }
  }

  Future<void> _bulkDelete() async {
    final selected = List<PackingItem>.from(_selectedItems);
    if (selected.isEmpty) return;
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Items',
      message: 'Delete ${selected.length} selected item${selected.length > 1 ? 's' : ''}? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirm != true) return;

    final db = await DatabaseHelper.instance.database;
    for (final item in selected) {
      await db.delete('packing_item_tasks', where: 'packing_item_id = ?', whereArgs: [item.id]);
    }
    await db.delete(
      'packing_items',
      where: 'id IN (${selected.map((_) => '?').join(',')})',
      whereArgs: selected.map((i) => i.id).toList(),
    );
    _exitSelectMode();
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selected.length} item${selected.length > 1 ? 's' : ''} deleted.')),
      );
    }
  }

  // ── Uncheck All / Delete All ──────────────────────────────
  Future<void> _uncheckAll() async {
    if (_items.isEmpty) return;
    final confirm = await showConfirmDialog(
      context,
      title: 'Uncheck All Items',
      message: 'Mark all ${_items.length} items as "Not Packed"?',
      confirmLabel: 'Uncheck All',
      confirmColor: TripReadyTheme.amber,
    );
    if (confirm != true) return;
    final db = await DatabaseHelper.instance.database;
    await db.update('packing_items', {'status': 'not_packed'},
        where: 'trip_id = ?', whereArgs: [widget.trip.id]);
    _loadItems();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All items marked as not packed.')));
  }

  Future<void> _deleteAll() async {
    if (_items.isEmpty) return;
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete All Items',
      message: 'Permanently delete all ${_items.length} items? This cannot be undone.',
      confirmLabel: 'Delete All',
      confirmColor: TripReadyTheme.danger,
    );
    if (confirm != true) return;
    final db = await DatabaseHelper.instance.database;
    for (final item in _items) {
      await db.delete('packing_item_tasks', where: 'packing_item_id = ?', whereArgs: [item.id]);
    }
    await db.delete('packing_items', where: 'trip_id = ?', whereArgs: [widget.trip.id]);
    _loadItems();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All packing items deleted.')));
  }

  // ── Templates ─────────────────────────────────────────────
  Future<void> _saveAsTemplate() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add some items first.')));
      return;
    }
    final result = await showDialog<bool>(
        context: context, builder: (_) => SaveTemplateDialog(items: _items));
    if (result == true && mounted)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved successfully!')));
  }

  Future<void> _loadTemplate() async {
    final result = await showDialog<bool>(
        context: context, builder: (_) => LoadTemplateDialog(tripId: widget.trip.id));
    if (result == true) _loadItems();
  }

  // ── Filter ────────────────────────────────────────────────
  Future<void> _showFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _FilterSheet(
        categories: _availableCategories,
        selectedCategory: _filterCategory,
        showPacked: _showPackedItems,
        onApply: (cat, showPacked) {
          setState(() { _filterCategory = cat; _showPackedItems = showPacked; });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // ── Export Excel ──────────────────────────────────────────
  Future<void> _exportExcel() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to export.')));
      return;
    }
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Packing List'];
      excel.delete('Sheet1');
      final headers = ['Name', 'Category', 'Quantity', 'Storage Place', 'Status', 'Notes'];
      for (var c = 0; c < headers.length; c++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.value = TextCellValue(headers[c]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('FF0D2B45'),
          fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        );
      }
      for (var r = 0; r < _items.length; r++) {
        final item = _items[r];
        final row = [item.name, item.category ?? '', item.quantity.toString(),
            item.storagePlace ?? '', item.isPacked ? 'Packed' : 'Not Packed', item.notes ?? ''];
        for (var c = 0; c < row.length; c++) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
              .value = TextCellValue(row[c]);
        }
      }
      sheet.setColumnWidth(0, 30);
      sheet.setColumnWidth(1, 18);
      sheet.setColumnWidth(2, 10);
      sheet.setColumnWidth(3, 22);
      sheet.setColumnWidth(4, 14);
      sheet.setColumnWidth(5, 30);
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${widget.trip.name.replaceAll(' ', '_')}_packing.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception('Excel encode failed');
      await File('${dir.path}/$filename').writeAsBytes(fileBytes);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to:\n${dir.path}/$filename'), duration: const Duration(seconds: 5)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  // ── Import Excel ──────────────────────────────────────────
  Future<void> _importExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['xlsx'], allowMultiple: false);
      if (result == null || result.files.single.path == null) return;
      final bytes = await File(result.files.single.path!).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      if (excel.sheets.isEmpty) { _showImportError('The Excel file has no sheets.'); return; }
      final sheet = excel.sheets.values.first;
      final rows = sheet.rows;
      if (rows.isEmpty) { _showImportError('The sheet is empty.'); return; }
      final headerRow = rows.first.map((c) => c?.value?.toString().trim().toLowerCase() ?? '').toList();
      final nameIdx = headerRow.indexOf('name');
      if (nameIdx == -1) {
        _showImportError('Required column "Name" not found.\n\nExpected headers: Name, Category, Quantity, Storage Place, Status, Notes\n(Only "Name" is mandatory.)');
        return;
      }
      final categoryIdx = headerRow.indexOf('category');
      final quantityIdx = headerRow.indexOf('quantity');
      final storageIdx = _findHeader(headerRow, ['storage place', 'storage', 'storage_place']);
      final statusIdx = headerRow.indexOf('status');
      final notesIdx = headerRow.indexOf('notes');
      int imported = 0, skipped = 0;
      final db = DatabaseHelper.instance;
      final now = DateTime.now();
      for (var r = 1; r < rows.length; r++) {
        final row = rows[r];
        final name = _cellStr(row, nameIdx).trim();
        if (name.isEmpty) { skipped++; continue; }
        String? category = categoryIdx >= 0 ? _cellStr(row, categoryIdx) : null;
        if (category != null && category.isEmpty) category = null;
        int quantity = quantityIdx >= 0 ? (int.tryParse(_cellStr(row, quantityIdx)) ?? 1) : 1;
        if (quantity < 1) quantity = 1;
        String? storagePlace = storageIdx >= 0 ? _cellStr(row, storageIdx) : null;
        if (storagePlace != null && storagePlace.isEmpty) storagePlace = null;
        PackingStatus status = PackingStatus.notPacked;
        if (statusIdx >= 0) {
          final s = _cellStr(row, statusIdx).toLowerCase();
          if (s == 'packed' || s == 'yes' || s == 'true') status = PackingStatus.packed;
        }
        String? notes = notesIdx >= 0 ? _cellStr(row, notesIdx) : null;
        if (notes != null && notes.isEmpty) notes = null;
        await db.insertPackingItem(PackingItem(
          id: '${widget.trip.id}_import_${r}_${now.microsecondsSinceEpoch}',
          tripId: widget.trip.id,
          name: name, category: category, quantity: quantity,
          storagePlace: storagePlace, status: status, notes: notes, createdAt: now,
        ));
        imported++;
      }
      _loadItems();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Import complete: $imported added${skipped > 0 ? ', $skipped skipped.' : '.'}'),
          duration: const Duration(seconds: 4)));
    } catch (e) {
      _showImportError('Failed to read the Excel file.\n\nError: $e');
    }
  }

  int _findHeader(List<String> headers, List<String> candidates) {
    for (final c in candidates) { final i = headers.indexOf(c); if (i >= 0) return i; }
    return -1;
  }

  String _cellStr(List<Data?> row, int idx) {
    if (idx < 0 || idx >= row.length) return '';
    return row[idx]?.value?.toString().trim() ?? '';
  }

  void _showImportError(String message) {
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Import Error'),
      content: Text(message),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }
}

// ── Selection Summary Bar ─────────────────────────────────────
class _SelectionBar extends StatelessWidget {
  final int selectedCount;
  final int totalVisible;
  final bool allSelected;
  final VoidCallback onToggleAll;

  const _SelectionBar({
    required this.selectedCount,
    required this.totalVisible,
    required this.allSelected,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TripReadyTheme.navy.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        GestureDetector(
          onTap: onToggleAll,
          child: Row(children: [
            Icon(
              allSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: TripReadyTheme.teal,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              allSelected ? 'Deselect all' : 'Select all ($totalVisible)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TripReadyTheme.teal, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
        const Spacer(),
        Text('$selectedCount / $totalVisible',
            style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int packed;
  final int total;
  const _ProgressBar({required this.packed, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : packed / total;
    return Container(
      color: TripReadyTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Packing Progress', style: Theme.of(context).textTheme.titleSmall),
          Text('$packed / $total packed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TripReadyTheme.teal, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct, minHeight: 8,
            backgroundColor: TripReadyTheme.warmGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(TripReadyTheme.teal),
          ),
        ),
      ]),
    );
  }
}

// ── Filter Chips ──────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final bool showPacked;
  final Function(String?) onCategorySelected;
  final VoidCallback onTogglePacked;

  const _FilterChips({
    required this.categories, required this.selected, required this.showPacked,
    required this.onCategorySelected, required this.onTogglePacked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TripReadyTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          FilterChip(
            label: Text(showPacked ? 'Showing All' : 'Hiding Packed'),
            selected: !showPacked,
            onSelected: (_) => onTogglePacked(),
            avatar: Icon(showPacked ? Icons.visibility : Icons.visibility_off, size: 14),
          ),
          const SizedBox(width: 8),
          FilterChip(label: const Text('All Categories'), selected: selected == null,
              onSelected: (_) => onCategorySelected(null)),
          ...categories.map((c) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(label: Text(c), selected: selected == c,
                onSelected: (_) => onCategorySelected(selected == c ? null : c)),
          )),
        ]),
      ),
    );
  }
}

// ── Category Group ────────────────────────────────────────────
class _CategoryGroup extends StatelessWidget {
  final String category;
  final List<PackingItem> items;
  final bool isArchived;
  final bool isSelecting;
  final Set<String> selectedIds;
  final Function(PackingItem) onToggle;
  final Function(PackingItem) onEdit;
  final Function(PackingItem) onDelete;
  final Function(String) onLongPress;
  final Function(String) onTapInSelectMode;

  const _CategoryGroup({
    required this.category, required this.items, required this.isArchived,
    required this.isSelecting, required this.selectedIds,
    required this.onToggle, required this.onEdit, required this.onDelete,
    required this.onLongPress, required this.onTapInSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    final packed = items.where((i) => i.isPacked).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Row(children: [
          Text(category.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: TripReadyTheme.teal, letterSpacing: 0.8, fontSize: 11)),
          const SizedBox(width: 8),
          Text('$packed/${items.length}', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
      ...items.map((item) => _PackingItemCard(
        item: item,
        isArchived: isArchived,
        isSelecting: isSelecting,
        isSelected: selectedIds.contains(item.id),
        onToggle: () => onToggle(item),
        onEdit: () => onEdit(item),
        onDelete: () => onDelete(item),
        onLongPress: () => onLongPress(item.id),
        onTapInSelectMode: () => onTapInSelectMode(item.id),
      )),
    ]);
  }
}

// ── Packing Item Card ─────────────────────────────────────────
class _PackingItemCard extends StatelessWidget {
  final PackingItem item;
  final bool isArchived;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;
  final VoidCallback onTapInSelectMode;

  const _PackingItemCard({
    required this.item, required this.isArchived,
    required this.isSelecting, required this.isSelected,
    required this.onToggle, required this.onEdit, required this.onDelete,
    required this.onLongPress, required this.onTapInSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTasks = item.tasks.where((t) => !t.isDone).length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? TripReadyTheme.teal.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? TripReadyTheme.teal : Colors.transparent,
          width: 2,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: isSelected ? TripReadyTheme.teal.withOpacity(0.04) : null,
        child: InkWell(
          onTap: isSelecting
              ? onTapInSelectMode
              : (isArchived ? null : onToggle),
          onLongPress: isArchived || isSelecting ? null : onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Leading: selection checkbox OR packed checkbox
              isSelecting
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          key: ValueKey(isSelected),
                          color: isSelected ? TripReadyTheme.teal : TripReadyTheme.textLight,
                          size: 26,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: isArchived ? null : onToggle,
                      child: Container(
                        width: 26, height: 26,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: item.isPacked ? TripReadyTheme.success : Colors.transparent,
                          border: Border.all(
                              color: item.isPacked ? TripReadyTheme.success : TripReadyTheme.textLight,
                              width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: item.isPacked
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),

              const SizedBox(width: 12),

              // Content
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: (!isSelecting && item.isPacked) ? TextDecoration.lineThrough : null,
                        color: (!isSelecting && item.isPacked) ? TripReadyTheme.textMid : null,
                      ))),
                  Text('x${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TripReadyTheme.teal, fontWeight: FontWeight.w700)),
                ]),
                if (item.storagePlace != null) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.luggage_outlined, size: 12, color: TripReadyTheme.textLight),
                    const SizedBox(width: 4),
                    Text(item.storagePlace!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.textMid)),
                  ]),
                ],
                if (item.tasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(pendingTasks == 0 ? Icons.task_alt : Icons.pending_actions_outlined,
                        size: 13,
                        color: pendingTasks == 0 ? TripReadyTheme.success : TripReadyTheme.amber),
                    const SizedBox(width: 4),
                    Text(pendingTasks == 0 ? 'All tasks done' : '$pendingTasks task${pendingTasks > 1 ? 's' : ''} pending',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: pendingTasks == 0 ? TripReadyTheme.success : TripReadyTheme.amber)),
                  ]),
                ],
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(item.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic, color: TripReadyTheme.textMid)),
                ],
              ])),

              // Per-item ⋮ menu (hidden during selection mode)
              if (!isArchived && !isSelecting)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: TripReadyTheme.textLight),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete',
                        child: Text('Delete', style: TextStyle(color: TripReadyTheme.danger))),
                  ],
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final bool showPacked;
  final Function(String?, bool) onApply;

  const _FilterSheet({required this.categories, required this.selectedCategory,
      required this.showPacked, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _category;
  bool _showPacked = true;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _showPacked = widget.showPacked;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Filter Items', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Text('Category', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilterChip(label: const Text('All'), selected: _category == null,
              onSelected: (_) => setState(() => _category = null)),
          ...widget.categories.map((c) => FilterChip(label: Text(c), selected: _category == c,
              onSelected: (_) => setState(() => _category = _category == c ? null : c))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Text('Show packed items', style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          Switch(value: _showPacked, onChanged: (v) => setState(() => _showPacked = v),
              activeColor: TripReadyTheme.teal),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(
              onPressed: () => setState(() { _category = null; _showPacked = true; }),
              child: const Text('Clear Filters'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
              onPressed: () => widget.onApply(_category, _showPacked),
              child: const Text('Apply'))),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }
}
