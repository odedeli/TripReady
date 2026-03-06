import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import '../../models/packing.dart';
import '../../models/trip.dart';
import '../../database/database_helper.dart';
import '../../database/packing_database.dart';
import '../../database/trip_details_database.dart';
import '../../models/trip_details.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/localization_ext.dart';
import 'add_edit_packing_item_screen.dart';
import 'template_dialogs.dart';
import '../../services/app_notifier.dart';

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

  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  bool get _allVisibleSelected {
    final visible = _filteredItems;
    return visible.isNotEmpty && visible.every((i) => _selectedIds.contains(i.id));
  }

  void _enterSelectMode(String firstId) => setState(() { _isSelecting = true; _selectedIds.add(firstId); });
  void _exitSelectMode() => setState(() { _isSelecting = false; _selectedIds.clear(); });
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) { _selectedIds.remove(id); if (_selectedIds.isEmpty) _isSelecting = false; }
      else _selectedIds.add(id);
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allVisibleSelected) { _selectedIds.clear(); _isSelecting = false; }
      else _selectedIds.addAll(_filteredItems.map((i) => i.id));
    });
  }

  List<PackingItem> get _selectedItems => _items.where((i) => _selectedIds.contains(i.id)).toList();

  @override
  void initState() { super.initState(); _loadItems(); 
    AppNotifier.instance.addListener(_loadItems);
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await DatabaseHelper.instance.getPackingItems(widget.trip.id);
    setState(() {
      _items = items; _isLoading = false;
      _selectedIds.retainWhere((id) => items.any((i) => i.id == id));
      if (_selectedIds.isEmpty) _isSelecting = false;
    });
  }

  List<PackingItem> get _filteredItems {
    var items = _items;
    if (_filterCategory != null) items = items.where((i) => i.category == _filterCategory).toList();
    if (!_showPackedItems) items = items.where((i) => !i.isPacked).toList();
    return items;
  }

  Map<String, List<PackingItem>> get _groupedItems {
    final Map<String, List<PackingItem>> grouped = {};
    for (final item in _filteredItems) grouped.putIfAbsent(item.category ?? '__uncategorised__', () => []).add(item);
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  List<String> get _availableCategories => _items.map((i) => i.category ?? '__uncategorised__').toSet().toList()..sort();
  int get _packedCount => _items.where((i) => i.isPacked).length;
  int get _totalCount  => _items.length;

  @override
  void dispose() {
    AppNotifier.instance.removeListener(_loadItems);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isArchived = widget.trip.isArchived;
    final selCount = _selectedIds.length;

    return WillPopScope(
      onWillPop: () async { if (_isSelecting) { _exitSelectMode(); return false; } return true; },
      child: Scaffold(
        appBar: _isSelecting ? _buildSelectionAppBar(selCount, isArchived) : _buildNormalAppBar(isArchived),
        floatingActionButton: _isSelecting || isArchived ? null : FloatingActionButton.extended(
          onPressed: _addItem, icon: const Icon(Icons.add), label: Text(l.packingAddItem)),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
            : Column(children: [
                if (_totalCount > 0) _ProgressBar(packed: _packedCount, total: _totalCount),
                if (_availableCategories.length > 1)
                  _FilterChips(categories: _availableCategories, selected: _filterCategory, showPacked: _showPackedItems,
                    onCategorySelected: (c) => setState(() => _filterCategory = c),
                    onTogglePacked: () => setState(() => _showPackedItems = !_showPackedItems)),
                if (_isSelecting) _SelectionBar(selectedCount: selCount, totalVisible: _filteredItems.length, allSelected: _allVisibleSelected, onToggleAll: _toggleSelectAll),
                Expanded(child: _items.isEmpty
                    ? EmptyState(icon: Icons.backpack_outlined, title: l.packingNoItems, subtitle: isArchived ? l.archiveNoTripsSubtitle : l.packingNoItemsSubtitle,
                        buttonLabel: isArchived ? null : l.packingAddItem, onButtonPressed: isArchived ? null : _addItem)
                    : _filteredItems.isEmpty
                        ? EmptyState(icon: Icons.filter_list_off, title: l.packingNoItems, subtitle: l.actionClear)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: _groupedItems.length,
                            itemBuilder: (ctx, i) {
                              final entry = _groupedItems.entries.elementAt(i);
                              return _CategoryGroup(category: entry.key, items: entry.value, isArchived: isArchived,
                                isSelecting: _isSelecting, selectedIds: _selectedIds,
                                onToggle: _toggleItem, onEdit: _editItem, onDelete: _deleteItem,
                                onLongPress: _enterSelectMode, onTapInSelectMode: _toggleSelection);
                            })),
              ]),
      ),
    );
  }

  AppBar _buildNormalAppBar(bool isArchived) {
    final l = context.l;
    return AppBar(
      title: Text(l.packingTitle),
      actions: [
        HomeButton(),
        IconButton(icon: const Icon(Icons.filter_list_outlined), onPressed: _showFilterSheet, tooltip: l.fieldCategory),
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
              PopupMenuItem(value: 'save_template', child: ListTile(leading: const Icon(Icons.save_outlined),        title: Text(l.packingSaveTemplate),  contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'load_template', child: ListTile(leading: const Icon(Icons.folder_open_outlined), title: Text(l.packingLoadTemplate),  contentPadding: EdgeInsets.zero)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'import_excel',  child: ListTile(leading: const Icon(Icons.upload_file_outlined), title: Text(l.packingImportExcel),   contentPadding: EdgeInsets.zero)),
            ],
            PopupMenuItem(value: 'export_excel',    child: ListTile(leading: const Icon(Icons.table_chart_outlined), title: Text(l.packingExportExcel),   contentPadding: EdgeInsets.zero)),
            if (!isArchived) ...[
              const PopupMenuDivider(),
              PopupMenuItem(value: 'uncheck_all',   child: ListTile(leading: const Icon(Icons.unpublished_outlined, color: TripReadyTheme.amber),
                title: Text(l.packingUncheckAll, style: const TextStyle(color: TripReadyTheme.amber)), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'delete_all',    child: ListTile(leading: const Icon(Icons.delete_sweep_outlined, color: TripReadyTheme.danger),
                title: Text(l.packingDeleteAll, style: const TextStyle(color: TripReadyTheme.danger)), contentPadding: EdgeInsets.zero)),
            ],
          ],
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar(int selCount, bool isArchived) {
    final l = context.l;
    return AppBar(
      backgroundColor: TripReadyTheme.navy,
      leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: _exitSelectMode),
      title: Text(l.packingSelectedCount(selCount),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      actions: [
        IconButton(icon: const Icon(Icons.check_box_outlined, color: Colors.white), tooltip: l.packingMarkPacked,
          onPressed: selCount == 0 ? null : () => _bulkSetStatus(PackingStatus.packed)),
        IconButton(icon: const Icon(Icons.check_box_outline_blank, color: Colors.white), tooltip: l.packingMarkUnpacked,
          onPressed: selCount == 0 ? null : () => _bulkSetStatus(PackingStatus.notPacked)),
        if (selCount == 1) IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white), tooltip: l.actionEdit, onPressed: () => _editItem(_selectedItems.first)),
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white), tooltip: l.actionDelete, onPressed: selCount == 0 ? null : _bulkDelete),
      ],
    );
  }

  Future<void> _addItem() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditPackingItemScreen(tripId: widget.trip.id)));
    if (result == true) _loadItems();
  }

  Future<void> _editItem(PackingItem item) async {
    _exitSelectMode();
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditPackingItemScreen(tripId: widget.trip.id, item: item)));
    if (result == true) _loadItems();
  }

  Future<void> _toggleItem(PackingItem item) async {
    await DatabaseHelper.instance.togglePackingItemStatus(item);
    // Sync: if this item has a linked task, update its status too
    final newlyPacked = !item.isPacked; // toggles, so invert current
    await DatabaseHelper.instance.syncTaskFromPacking(item.id, newlyPacked);
    _loadItems();
  }

  Future<void> _deleteItem(PackingItem item) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.actionDelete, message: '"${item.name}"?', confirmLabel: l.actionDelete);
    if (confirm == true) {
      await DatabaseHelper.instance.deleteTaskForPackingItem(item.id);
      await DatabaseHelper.instance.deletePackingItem(item.id);
      _loadItems();
    }
  }

  Future<void> _bulkSetStatus(PackingStatus status) async {
    final l = context.l;
    final selected = List<PackingItem>.from(_selectedItems);
    if (selected.isEmpty) return;
    final label = status == PackingStatus.packed ? l.packingStatusPacked : l.packingStatusNotPacked;
    final confirm = await showConfirmDialog(context,
      title: status == PackingStatus.packed ? l.packingMarkPacked : l.packingMarkUnpacked,
      message: '${selected.length} ${l.packingMarkPacked}?',
      confirmLabel: label,
      confirmColor: status == PackingStatus.packed ? TripReadyTheme.success : TripReadyTheme.teal);
    if (confirm != true) return;
    final db = await DatabaseHelper.instance.database;
    await db.update('packing_items', {'status': status.name}, where: 'id IN (${selected.map((_) => '?').join(',')})', whereArgs: selected.map((i) => i.id).toList());
    _exitSelectMode(); _loadItems();
    if (mounted) showAppSnackBar(context, '${selected.length} $label');
  }

  Future<void> _bulkDelete() async {
    final l = context.l;
    final selected = List<PackingItem>.from(_selectedItems);
    if (selected.isEmpty) return;
    final confirm = await showConfirmDialog(context, title: l.packingDeleteAll, message: '${selected.length} ${l.actionDelete}?', confirmLabel: l.actionDelete);
    if (confirm != true) return;
    final db = await DatabaseHelper.instance.database;
    for (final item in selected) await db.delete('packing_item_tasks', where: 'packing_item_id = ?', whereArgs: [item.id]);
    await db.delete('packing_items', where: 'id IN (${selected.map((_) => '?').join(',')})', whereArgs: selected.map((i) => i.id).toList());
    _exitSelectMode(); _loadItems();
    if (mounted) showAppSnackBar(context, '${selected.length} ${l.actionDelete}');
  }

  Future<void> _uncheckAll() async {
    final l = context.l;
    if (_items.isEmpty) return;
    final confirm = await showConfirmDialog(context, title: l.packingUncheckAll, message: '${_items.length} ${l.packingStatusNotPacked}?', confirmLabel: l.packingUncheckAll, confirmColor: TripReadyTheme.amber);
    if (confirm != true) return;
    final db = await DatabaseHelper.instance.database;
    await db.update('packing_items', {'status': 'not_packed'}, where: 'trip_id = ?', whereArgs: [widget.trip.id]);
    _loadItems();
  }

  Future<void> _deleteAll() async {
    final l = context.l;
    if (_items.isEmpty) return;
    final confirm = await showConfirmDialog(context, title: l.packingDeleteAll, message: '${_items.length} ${l.actionDelete}?', confirmLabel: l.packingDeleteAll, confirmColor: TripReadyTheme.danger);
    if (confirm != true) return;
    final db = await DatabaseHelper.instance.database;
    for (final item in _items) await db.delete('packing_item_tasks', where: 'packing_item_id = ?', whereArgs: [item.id]);
    await db.delete('packing_items', where: 'trip_id = ?', whereArgs: [widget.trip.id]);
    _loadItems();
  }

  Future<void> _saveAsTemplate() async {
    final l = context.l;
    if (_items.isEmpty) { showAppSnackBar(context, l.packingNoItems); return; }
    final result = await showDialog<bool>(context: context, builder: (_) => SaveTemplateDialog(items: _items));
    if (result == true && mounted) showAppSnackBar(context, l.packingSaveTemplate);
  }

  Future<void> _loadTemplate() async {
    final result = await showDialog<bool>(context: context, builder: (_) => LoadTemplateDialog(tripId: widget.trip.id));
    if (result == true) _loadItems();
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _FilterSheet(categories: _availableCategories, selectedCategory: _filterCategory, showPacked: _showPackedItems,
        onApply: (cat, showPacked) { setState(() { _filterCategory = cat; _showPackedItems = showPacked; }); Navigator.pop(ctx); }));
  }

  Future<void> _exportExcel() async {
    final l = context.l;
    if (_items.isEmpty) { showAppSnackBar(context, l.packingNoItems); return; }
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Packing List'];
      excel.delete('Sheet1');
      final headers = [l.packingExcelHeaderName, l.packingExcelHeaderCategory, l.packingExcelHeaderQuantity, l.packingExcelHeaderStorage, l.packingExcelHeaderStatus, l.packingExcelHeaderNotes];
      for (var c = 0; c < headers.length; c++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.value = TextCellValue(headers[c]);
        cell.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('FF0D2B45'), fontColorHex: ExcelColor.fromHexString('FFFFFFFF'));
      }
      for (var r = 0; r < _items.length; r++) {
        final item = _items[r];
        final row = [item.name, item.category ?? '', item.quantity.toString(), item.storagePlace ?? '', item.isPacked ? l.packingStatusPacked : l.packingStatusNotPacked, item.notes ?? ''];
        for (var c = 0; c < row.length; c++) sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1)).value = TextCellValue(row[c]);
      }
      for (var w in [30, 18, 10, 22, 14, 30].asMap().entries) sheet.setColumnWidth(w.key, w.value.toDouble());
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${widget.trip.name.replaceAll(' ', '_')}_packing.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception('Excel encode failed');
      await File('${dir.path}/$filename').writeAsBytes(fileBytes);
      showAppSnackBar(context, '${l.packingExportExcel}:\n${dir.path}/$filename', duration: const Duration(seconds: 5));
    } catch (e) {
      if (mounted) showAppSnackBar(context, '$e');
    }
  }

  Future<void> _importExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx'], allowMultiple: false);
      if (result == null || result.files.single.path == null) return;
      final bytes = await File(result.files.single.path!).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      if (excel.sheets.isEmpty) return;
      final sheet = excel.sheets.values.first;
      final rows = sheet.rows;
      if (rows.isEmpty) return;
      final headerRow = rows.first.map((c) => c?.value?.toString().trim().toLowerCase() ?? '').toList();
      final nameIdx     = headerRow.indexOf('name');
      if (nameIdx == -1) return;
      final categoryIdx = headerRow.indexOf('category');
      final quantityIdx = headerRow.indexOf('quantity');
      final storageIdx  = _findHeader(headerRow, ['storage place', 'storage', 'storage_place']);
      final statusIdx   = headerRow.indexOf('status');
      final notesIdx    = headerRow.indexOf('notes');
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
        if (statusIdx >= 0) { final s = _cellStr(row, statusIdx).toLowerCase(); if (s == 'packed' || s == 'yes' || s == 'true') status = PackingStatus.packed; }
        String? notes = notesIdx >= 0 ? _cellStr(row, notesIdx) : null;
        if (notes != null && notes.isEmpty) notes = null;
        await db.insertPackingItem(PackingItem(id: '${widget.trip.id}_import_${r}_${now.microsecondsSinceEpoch}', tripId: widget.trip.id, name: name, category: category, quantity: quantity, storagePlace: storagePlace, status: status, notes: notes, createdAt: now));
        imported++;
      }
      _loadItems();
      if (mounted) showAppSnackBar(context, '${context.l.packingImportExcel}: $imported${skipped > 0 ? ', $skipped skipped' : ''}');
    } catch (e) {
      if (mounted) showAppSnackBar(context, '$e');
    }
  }

  int _findHeader(List<String> headers, List<String> candidates) {
    for (final c in candidates) { final i = headers.indexOf(c); if (i >= 0) return i; } return -1;
  }
  String _cellStr(List<Data?> row, int idx) { if (idx < 0 || idx >= row.length) return ''; return row[idx]?.value?.toString().trim() ?? ''; }
}

class _SelectionBar extends StatelessWidget {
  final int selectedCount, totalVisible;
  final bool allSelected;
  final VoidCallback onToggleAll;

  const _SelectionBar({required this.selectedCount, required this.totalVisible, required this.allSelected, required this.onToggleAll});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Container(
      color: TripReadyTheme.navy.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        GestureDetector(onTap: onToggleAll, child: Row(children: [
          Icon(allSelected ? Icons.check_box : Icons.check_box_outline_blank, color: TripReadyTheme.teal, size: 22),
          const SizedBox(width: 8),
          Text(allSelected ? l.packingDeselectAll : l.packingSelectAll(totalVisible),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TripReadyTheme.teal, fontWeight: FontWeight.w600)),
        ])),
        const Spacer(),
        Text('$selectedCount / $totalVisible', style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int packed, total;
  const _ProgressBar({required this.packed, required this.total});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final pct = total == 0 ? 0.0 : packed / total;
    return Container(
      color: TripReadyTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l.packingProgress, style: Theme.of(context).textTheme.titleSmall),
          Text(l.packingPackedCount(packed, total), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.teal, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: TripReadyTheme.warmGrey, valueColor: const AlwaysStoppedAnimation<Color>(TripReadyTheme.teal))),
      ]),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final bool showPacked;
  final Function(String?) onCategorySelected;
  final VoidCallback onTogglePacked;

  const _FilterChips({required this.categories, required this.selected, required this.showPacked, required this.onCategorySelected, required this.onTogglePacked});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Container(
      color: TripReadyTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        FilterChip(label: Text(showPacked ? l.packingStatusPacked : l.packingStatusNotPacked), selected: !showPacked, onSelected: (_) => onTogglePacked(), avatar: Icon(showPacked ? Icons.visibility : Icons.visibility_off, size: 14)),
        const SizedBox(width: 8),
        FilterChip(label: Text(l.actionClear), selected: selected == null, onSelected: (_) => onCategorySelected(null)),
        ...categories.map((c) { final display = c == '__uncategorised__' ? context.l.packingUncategorised : c; return Padding(padding: const EdgeInsets.only(left: 8),
          child: FilterChip(label: Text(display), selected: selected == c, onSelected: (_) => onCategorySelected(selected == c ? null : c))); }),
      ])),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final String category;
  final List<PackingItem> items;
  final bool isArchived, isSelecting;
  final Set<String> selectedIds;
  final Function(PackingItem) onToggle, onEdit, onDelete;
  final Function(String) onLongPress, onTapInSelectMode;

  const _CategoryGroup({required this.category, required this.items, required this.isArchived, required this.isSelecting, required this.selectedIds, required this.onToggle, required this.onEdit, required this.onDelete, required this.onLongPress, required this.onTapInSelectMode});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final displayCategory = category == '__uncategorised__' ? l.packingUncategorised : category;
    final packed = items.where((i) => i.isPacked).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 16, 4, 8), child: Row(children: [
        Text(displayCategory.toUpperCase(), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: TripReadyTheme.teal, letterSpacing: 0.8, fontSize: 11)),
        const SizedBox(width: 8),
        Text('$packed/${items.length}', style: Theme.of(context).textTheme.bodySmall),
      ])),
      ...items.map((item) => _PackingItemCard(item: item, isArchived: isArchived, isSelecting: isSelecting, isSelected: selectedIds.contains(item.id),
        onToggle: () => onToggle(item), onEdit: () => onEdit(item), onDelete: () => onDelete(item), onLongPress: () => onLongPress(item.id), onTapInSelectMode: () => onTapInSelectMode(item.id))),
    ]);
  }
}

class _PackingItemCard extends StatelessWidget {
  final PackingItem item;
  final bool isArchived, isSelecting, isSelected;
  final VoidCallback onToggle, onEdit, onDelete, onLongPress, onTapInSelectMode;

  const _PackingItemCard({required this.item, required this.isArchived, required this.isSelecting, required this.isSelected, required this.onToggle, required this.onEdit, required this.onDelete, required this.onLongPress, required this.onTapInSelectMode});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final pendingTasks = item.tasks.where((t) => !t.isDone).length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isSelected ? TripReadyTheme.teal.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? TripReadyTheme.teal : Colors.transparent, width: 2)),
      child: Card(margin: EdgeInsets.zero, color: isSelected ? TripReadyTheme.teal.withOpacity(0.04) : null,
        child: InkWell(
          onTap:      isSelecting ? onTapInSelectMode : (isArchived ? null : onToggle),
          onLongPress: isArchived || isSelecting ? null : onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            isSelecting
                ? Padding(padding: const EdgeInsets.only(top: 1), child: AnimatedSwitcher(duration: const Duration(milliseconds: 150),
                    child: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, key: ValueKey(isSelected),
                      color: isSelected ? TripReadyTheme.teal : TripReadyTheme.textLight, size: 26)))
                : GestureDetector(onTap: isArchived ? null : onToggle, child: Container(
                    width: 26, height: 26, margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: item.isPacked ? TripReadyTheme.success : Colors.transparent,
                      border: Border.all(color: item.isPacked ? TripReadyTheme.success : TripReadyTheme.textLight, width: 2), borderRadius: BorderRadius.circular(6)),
                    child: item.isPacked ? const Icon(Icons.check, size: 16, color: Colors.white) : null)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: (!isSelecting && item.isPacked) ? TextDecoration.lineThrough : null,
                  color: (!isSelecting && item.isPacked) ? TripReadyTheme.textMid : null))),
                Text('x${item.quantity}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.teal, fontWeight: FontWeight.w700)),
              ]),
              if (item.storagePlace != null) ...[const SizedBox(height: 2), Row(children: [const Icon(Icons.luggage_outlined, size: 12, color: TripReadyTheme.textLight), const SizedBox(width: 4), Text(item.storagePlace!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.textMid))])],
              if (item.tasks.isNotEmpty) ...[const SizedBox(height: 6), Row(children: [
                Icon(pendingTasks == 0 ? Icons.task_alt : Icons.pending_actions_outlined, size: 13, color: pendingTasks == 0 ? TripReadyTheme.success : TripReadyTheme.amber),
                const SizedBox(width: 4),
                Text(pendingTasks == 0 ? l.packingAllTasksDone : l.packingTasksPending(pendingTasks),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: pendingTasks == 0 ? TripReadyTheme.success : TripReadyTheme.amber)),
              ])],
              if (item.notes != null) ...[const SizedBox(height: 4), Text(item.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: TripReadyTheme.textMid))],
            ])),
            if (!isArchived && !isSelecting)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: TripReadyTheme.textLight),
                onSelected: (val) { if (val == 'edit') onEdit(); if (val == 'delete') onDelete(); },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l.actionEdit)),
                  PopupMenuItem(value: 'delete', child: Text(l.actionDelete, style: const TextStyle(color: TripReadyTheme.danger))),
                ],
              ),
          ])),
        )),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final bool showPacked;
  final Function(String?, bool) onApply;

  const _FilterSheet({required this.categories, required this.selectedCategory, required this.showPacked, required this.onApply});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _category;
  bool _showPacked = true;

  @override
  void initState() { super.initState(); _category = widget.selectedCategory; _showPacked = widget.showPacked; }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.fieldCategory, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 20),
      Text(l.fieldCategory, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilterChip(label: Text(l.actionClear), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
        ...widget.categories.map((c) { final display = c == '__uncategorised__' ? context.l.packingUncategorised : c; return FilterChip(label: Text(display), selected: _category == c, onSelected: (_) => setState(() => _category = _category == c ? null : c)); }),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Text(l.packingStatusPacked, style: Theme.of(context).textTheme.titleSmall),
        const Spacer(),
        Switch(value: _showPacked, onChanged: (v) => setState(() => _showPacked = v), activeColor: TripReadyTheme.teal),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() { _category = null; _showPacked = true; }), child: Text(l.actionClear))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: () => widget.onApply(_category, _showPacked), child: Text(l.actionApply))),
      ]),
      const SizedBox(height: 8),
    ]));
  }
}
