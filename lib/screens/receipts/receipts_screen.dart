import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../models/trip.dart';
import '../../models/receipt.dart';
import '../../database/database_helper.dart';
import '../../database/receipt_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const List<String> kCommonCurrencies = [
  'USD', 'EUR', 'GBP', 'ILS', 'JPY', 'AUD', 'CAD', 'CHF',
  'CNY', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'TRY',
  'THB', 'SGD', 'HKD', 'MXN', 'BRL', 'ZAR', 'AED', 'INR',
];

class ReceiptsScreen extends StatefulWidget {
  final Trip trip;
  const ReceiptsScreen({super.key, required this.trip});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  List<Receipt> _receipts = [];
  Map<String, double> _summary = {};
  bool _isLoading = true;
  ReceiptType? _filterType;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final receipts = await DatabaseHelper.instance.getReceipts(widget.trip.id);
    final summary = await DatabaseHelper.instance.getReceiptSummary(widget.trip.id);
    setState(() {
      _receipts = receipts;
      _summary = summary;
      _isLoading = false;
    });
  }

  List<Receipt> get _filtered => _filterType == null
      ? _receipts
      : _receipts.where((r) => r.type == _filterType).toList();

  String get _baseCurrency {
    if (_receipts.isEmpty) return 'USD';
    // Infer base currency: most common currency with rate=1
    final baseCandidates = _receipts.where((r) => r.exchangeRate == 1.0);
    if (baseCandidates.isNotEmpty) return baseCandidates.first.currency;
    return _receipts.first.currency;
  }

  @override
  Widget build(BuildContext context) {
    final isArchived = widget.trip.isArchived;
    final total = _summary['total'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts & Expenses'),
        actions: [
          if (_receipts.isNotEmpty)
            PopupMenuButton<ReceiptType?>(
              icon: const Icon(Icons.filter_list_outlined),
              onSelected: (t) => setState(() => _filterType = t),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('All Types')),
                const PopupMenuDivider(),
                ...ReceiptType.values.map((t) => PopupMenuItem(
                  value: t,
                  child: Text(t.typeLabel),
                )),
              ],
            ),
        ],
      ),
      floatingActionButton: isArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: _addReceipt,
              icon: const Icon(Icons.add),
              label: const Text('Add Receipt'),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : Column(
              children: [
                if (_receipts.isNotEmpty)
                  _SummaryCard(
                    total: total,
                    summary: _summary,
                    baseCurrency: _baseCurrency,
                  ),
                Expanded(
                  child: _receipts.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No receipts yet',
                          subtitle: isArchived
                              ? 'This trip is archived.'
                              : 'Track your expenses by adding receipts.',
                          buttonLabel: isArchived ? null : 'Add Receipt',
                          onButtonPressed: isArchived ? null : _addReceipt,
                        )
                      : _filtered.isEmpty
                          ? const EmptyState(
                              icon: Icons.filter_list_off,
                              title: 'No receipts match filter',
                              subtitle: 'Try clearing the filter.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                              itemCount: _filtered.length,
                              itemBuilder: (ctx, i) => _ReceiptCard(
                                receipt: _filtered[i],
                                baseCurrency: _baseCurrency,
                                isArchived: isArchived,
                                onEdit: () => _editReceipt(_filtered[i]),
                                onDelete: () => _deleteReceipt(_filtered[i]),
                              ),
                            ),
                ),
              ],
            ),
    );
  }

  Future<void> _addReceipt() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditReceiptScreen(
          tripId: widget.trip.id,
          suggestedBaseCurrency: _baseCurrency,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _editReceipt(Receipt receipt) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditReceiptScreen(
          tripId: widget.trip.id,
          receipt: receipt,
          suggestedBaseCurrency: _baseCurrency,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _deleteReceipt(Receipt receipt) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Receipt',
      message: 'Delete "${receipt.name}"?',
      confirmLabel: 'Delete',
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteReceipt(receipt.id);
      _load();
    }
  }
}

// ── Summary Card ──────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final double total;
  final Map<String, double> summary;
  final String baseCurrency;

  const _SummaryCard({
    required this.total,
    required this.summary,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    // Top 3 categories by spend
    final cats = summary.entries
        .where((e) => e.key != 'total')
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = cats.take(3).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TripReadyTheme.navy, TripReadyTheme.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TripReadyTheme.navy.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Expenses', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white60)),
          const SizedBox(height: 4),
          Text(
            '${total.toStringAsFixed(2)} $baseCurrency',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (top3.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Row(
              children: top3.map((e) {
                final typeName = e.key;
                final type = ReceiptType.values.firstWhere(
                  (t) => t.name == typeName,
                  orElse: () => ReceiptType.other,
                );
                final pct = total > 0 ? (e.value / total * 100).round() : 0;
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.typeLabel,
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                      Text(
                        '${e.value.toStringAsFixed(0)} $baseCurrency',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('$pct%',
                          style: const TextStyle(
                            color: TripReadyTheme.amberLight,
                            fontSize: 11,
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Receipt Card ──────────────────────────────────────────────
class _ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final String baseCurrency;
  final bool isArchived;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReceiptCard({
    required this.receipt,
    required this.baseCurrency,
    required this.isArchived,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _typeColor {
    switch (receipt.type) {
      case ReceiptType.food: return const Color(0xFFE67E22);
      case ReceiptType.transport: return TripReadyTheme.teal;
      case ReceiptType.accommodation: return TripReadyTheme.navy;
      case ReceiptType.entertainment: return const Color(0xFF8E44AD);
      case ReceiptType.shopping: return const Color(0xFFE91E63);
      case ReceiptType.health: return TripReadyTheme.success;
      case ReceiptType.communication: return const Color(0xFF2196F3);
      case ReceiptType.fees: return TripReadyTheme.danger;
      case ReceiptType.other: return TripReadyTheme.textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final showConverted =
        receipt.currency != baseCurrency && receipt.exchangeRate != 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_outlined, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receipt.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Row(children: [
                    StatusBadge(
                      label: receipt.typeLabel,
                      color: _typeColor.withOpacity(0.12),
                      textColor: _typeColor,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: TripReadyTheme.textLight),
                    const SizedBox(width: 3),
                    Text(fmt.format(receipt.date),
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  if (receipt.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(receipt.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: TripReadyTheme.textMid)),
                  ],
                  if (receipt.hasPhoto) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.photo_outlined,
                          size: 12, color: TripReadyTheme.teal),
                      const SizedBox(width: 4),
                      Text('Photo attached',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TripReadyTheme.teal)),
                    ]),
                  ],
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${receipt.amount.toStringAsFixed(2)} ${receipt.currency}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TripReadyTheme.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showConverted)
                  Text(
                    '≈ ${receipt.convertedAmount.toStringAsFixed(2)} $baseCurrency',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TripReadyTheme.textMid),
                  ),
                if (!isArchived) ...[
                  const SizedBox(height: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: TripReadyTheme.textLight),
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: TripReadyTheme.danger))),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add/Edit Receipt Screen ───────────────────────────────────
class AddEditReceiptScreen extends StatefulWidget {
  final String tripId;
  final Receipt? receipt;
  final String suggestedBaseCurrency;

  const AddEditReceiptScreen({
    super.key,
    required this.tripId,
    this.receipt,
    this.suggestedBaseCurrency = 'USD',
  });

  @override
  State<AddEditReceiptScreen> createState() => _AddEditReceiptScreenState();
}

class _AddEditReceiptScreenState extends State<AddEditReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController(text: '1.0');
  final _notesController = TextEditingController();

  ReceiptType _type = ReceiptType.other;
  DateTime _date = DateTime.now();
  String _currency = 'USD';
  String? _photoPath;
  bool _isSaving = false;
  bool _isPickingFile = false;

  bool get _isEditing => widget.receipt != null;

  @override
  void initState() {
    super.initState();
    _currency = widget.suggestedBaseCurrency;
    if (_isEditing) {
      final r = widget.receipt!;
      _nameController.text = r.name;
      _amountController.text = r.amount.toString();
      _rateController.text = r.exchangeRate.toString();
      _notesController.text = r.notes ?? '';
      _type = r.type;
      _date = r.date;
      _currency = r.currency;
      _photoPath = r.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: TripReadyTheme.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickPhoto() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _photoPath = result.files.single.path);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  double get _convertedAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 1.0;
    return amount * rate;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final rate = double.tryParse(_rateController.text.trim()) ?? 1.0;

      if (_isEditing) {
        final updated = widget.receipt!.copyWith(
          name: _nameController.text.trim(),
          type: _type,
          date: _date,
          amount: amount,
          currency: _currency,
          exchangeRate: rate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          photoPath: _photoPath,
          clearPhoto: _photoPath == null,
        );
        await DatabaseHelper.instance.updateReceipt(updated);
      } else {
        final receipt = Receipt(
          id: const Uuid().v4(),
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          type: _type,
          date: _date,
          amount: amount,
          currency: _currency,
          exchangeRate: rate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          photoPath: _photoPath,
          createdAt: DateTime.now(),
        );
        await DatabaseHelper.instance.insertReceipt(receipt);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving receipt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final showConverted = _currency != widget.suggestedBaseCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Receipt' : 'New Receipt'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
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
            // Name
            _label('Receipt Name *'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Airport Taxi, Hotel Stay',
                prefixIcon: Icon(Icons.receipt_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Type
            _label('Category'),
            DropdownButtonFormField<ReceiptType>(
              value: _type,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined)),
              items: ReceiptType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.typeLabel)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),

            // Date
            _label('Date *'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TripReadyTheme.teal, width: 2),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: TripReadyTheme.teal),
                  const SizedBox(width: 10),
                  Text(fmt.format(_date),
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Amount & Currency
            _label('Amount *'),
            Row(children: [
              // Currency dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TripReadyTheme.warmGrey),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _currency,
                  underline: const SizedBox(),
                  items: kCommonCurrencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _currency = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(hintText: '0.00'),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount required';
                    if (double.tryParse(v) == null) return 'Invalid amount';
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Exchange rate (only shown when currency differs from base)
            _label('Exchange Rate to ${widget.suggestedBaseCurrency}'),
            TextFormField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,6}')),
              ],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_exchange_outlined),
                hintText: '1.0',
                helperText: showConverted && _amountController.text.isNotEmpty
                    ? '≈ ${_convertedAmount.toStringAsFixed(2)} ${widget.suggestedBaseCurrency}'
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Photo
            _label('Receipt Photo (optional)'),
            GestureDetector(
              onTap: _isPickingFile ? null : _pickPhoto,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _photoPath != null
                        ? TripReadyTheme.teal
                        : TripReadyTheme.warmGrey,
                    width: _photoPath != null ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    _photoPath != null
                        ? Icons.photo_outlined
                        : Icons.add_photo_alternate_outlined,
                    size: 18,
                    color: _photoPath != null
                        ? TripReadyTheme.teal
                        : TripReadyTheme.textMid,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _isPickingFile
                        ? const Text('Selecting...',
                            style: TextStyle(color: TripReadyTheme.textMid))
                        : Text(
                            _photoPath != null
                                ? _photoPath!.split(Platform.pathSeparator).last
                                : 'Attach photo or PDF',
                            style: TextStyle(
                              color: _photoPath != null
                                  ? TripReadyTheme.textDark
                                  : TripReadyTheme.textLight,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  if (_photoPath != null)
                    GestureDetector(
                      onTap: () => setState(() => _photoPath = null),
                      child: const Icon(Icons.close,
                          size: 16, color: TripReadyTheme.textLight),
                    ),
                ]),
              ),
            ),

            // Show photo preview if it's an image
            if (_photoPath != null && (_photoPath!.endsWith('.jpg') ||
                _photoPath!.endsWith('.jpeg') ||
                _photoPath!.endsWith('.png'))) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: TripReadyTheme.warmGrey,
                    child: const Center(
                      child: Text('Could not load image preview'),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Notes
            _label('Notes (optional)'),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any notes about this expense...',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Update Receipt' : 'Add Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

extension on ReceiptType {
  String get typeLabel {
    switch (this) {
      case ReceiptType.food: return 'Food & Drink';
      case ReceiptType.transport: return 'Transport';
      case ReceiptType.accommodation: return 'Accommodation';
      case ReceiptType.entertainment: return 'Entertainment';
      case ReceiptType.shopping: return 'Shopping';
      case ReceiptType.health: return 'Health';
      case ReceiptType.communication: return 'Communication';
      case ReceiptType.fees: return 'Fees & Charges';
      case ReceiptType.other: return 'Other';
    }
  }
}
