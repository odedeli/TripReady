import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import '../../database/database_helper.dart';
import '../../database/trip_details_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/localization_ext.dart';
import '../../services/app_notifier.dart';
import 'package:intl/intl.dart';
import '../../models/reminder.dart';
import '../../widgets/reminder_bell.dart';
import '../../widgets/item_reminder_sheet.dart';

class DocumentsScreen extends StatefulWidget {
  final Trip trip;
  const DocumentsScreen({super.key, required this.trip});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<TripDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); 
    AppNotifier.instance.addListener(_load);
  }

  @override
  void dispose() {
    AppNotifier.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final docs = await DatabaseHelper.instance.getDocuments(widget.trip.id);
    setState(() { _documents = docs; _isLoading = false; });
  }

  Map<DocumentType, List<TripDocument>> get _grouped {
    final Map<DocumentType, List<TripDocument>> grouped = {};
    for (final doc in _documents) grouped.putIfAbsent(doc.type, () => []).add(doc);
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.name.compareTo(b.key.name)));
  }

  String _typeLabel(DocumentType t, AppLocalizations l) {
    switch (t) {
      case DocumentType.ticket:      return l.documentsTypeTicket;
      case DocumentType.voucher:     return l.documentsTypeVoucher;
      case DocumentType.letter:      return l.documentsTypeLetter;
      case DocumentType.passport:    return l.documentsTypePassport;
      case DocumentType.visa:        return l.documentsTypeVisa;
      case DocumentType.insurance:   return l.documentsTypeInsurance;
      case DocumentType.reservation: return l.documentsTypeReservation;
      case DocumentType.itinerary:   return l.documentsTypeItinerary;
      case DocumentType.other:       return l.documentsTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isArchived = widget.trip.isArchived;

    return Scaffold(
      appBar: AppBar(title: Text(l.documentsTitle), actions: [HomeButton()]),
      floatingActionButton: isArchived ? null : FloatingActionButton.extended(
        onPressed: _addDocument, icon: const Icon(Icons.attach_file), label: Text(l.documentsAddDocument)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : _documents.isEmpty
              ? EmptyState(icon: Icons.folder_open_outlined, title: l.documentsNoDocuments, subtitle: isArchived ? l.archiveNoTripsSubtitle : l.documentsNoDocumentsSubtitle,
                  buttonLabel: isArchived ? null : l.documentsAddDocument, onButtonPressed: isArchived ? null : _addDocument)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _grouped.length,
                  itemBuilder: (ctx, i) {
                    final entry = _grouped.entries.elementAt(i);
                    return _DocTypeGroup(type: entry.key, docs: entry.value, isArchived: isArchived, typeLabel: _typeLabel(entry.key, l),
                      onEdit: _editDocument, onDelete: _deleteDocument, onOpen: _openDocument);
                  }),
    );
  }

  Future<void> _addDocument() async {
    final result = await showDialog<bool>(context: context, builder: (_) => _AddEditDocumentDialog(tripId: widget.trip.id, typeLabel: _typeLabel));
    if (result == true) _load();
  }

  Future<void> _editDocument(TripDocument doc) async {
    final result = await showDialog<bool>(context: context, builder: (_) => _AddEditDocumentDialog(tripId: widget.trip.id, document: doc, typeLabel: _typeLabel));
    if (result == true) _load();
  }

  Future<void> _deleteDocument(TripDocument doc) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.actionDelete, message: '"${doc.name}"?', confirmLabel: l.actionDelete);
    if (confirm == true) { await DatabaseHelper.instance.deleteDocument(doc.id); _load(); }
  }

  Future<void> _openDocument(TripDocument doc) async {
    if (!doc.hasFile) { if (mounted) showAppSnackBar(context, context.l.documentsNoFileAttached); return; }
    final file = File(doc.filePath!);
    if (!await file.exists()) { if (mounted) showAppSnackBar(context, context.l.documentsNoFileAttached); return; }
    if (mounted) showAppSnackBar(context, '${context.l.documentsFileAttached}: ${doc.filePath}');
  }
}

class _DocTypeGroup extends StatelessWidget {
  final DocumentType type;
  final List<TripDocument> docs;
  final bool isArchived;
  final String typeLabel;
  final Function(TripDocument) onEdit, onDelete, onOpen;

  const _DocTypeGroup({required this.type, required this.docs, required this.isArchived, required this.typeLabel, required this.onEdit, required this.onDelete, required this.onOpen});

  IconData get _typeIcon {
    switch (type) {
      case DocumentType.ticket:      return Icons.confirmation_number_outlined;
      case DocumentType.voucher:     return Icons.card_giftcard_outlined;
      case DocumentType.letter:      return Icons.mail_outlined;
      case DocumentType.passport:    return Icons.menu_book_outlined;
      case DocumentType.visa:        return Icons.approval_outlined;
      case DocumentType.insurance:   return Icons.health_and_safety_outlined;
      case DocumentType.reservation: return Icons.hotel_outlined;
      case DocumentType.itinerary:   return Icons.map_outlined;
      case DocumentType.other:       return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 16, 4, 8), child: Row(children: [
        Icon(_typeIcon, size: 14, color: TripReadyTheme.teal), const SizedBox(width: 6),
        Text(typeLabel.toUpperCase(), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: TripReadyTheme.teal, letterSpacing: 0.8, fontSize: 11)),
        const SizedBox(width: 8),
        Text('${docs.length}', style: Theme.of(context).textTheme.bodySmall),
      ])),
      ...docs.map((d) => _DocumentCard(doc: d, isArchived: isArchived, onEdit: () => onEdit(d), onDelete: () => onDelete(d), onOpen: () => onOpen(d))),
    ]);
  }
}

class _DocumentCard extends StatelessWidget {
  final TripDocument doc;
  final bool isArchived;
  final VoidCallback onEdit, onDelete, onOpen;

  const _DocumentCard({required this.doc, required this.isArchived, required this.onEdit, required this.onDelete, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onEdit,
        leading: Container(width: 44, height: 44,
          decoration: BoxDecoration(color: doc.hasFile ? TripReadyTheme.teal.withOpacity(0.1) : TripReadyTheme.warmGrey, borderRadius: BorderRadius.circular(12)),
          child: Icon(doc.hasFile ? Icons.insert_drive_file : Icons.insert_drive_file_outlined, color: doc.hasFile ? TripReadyTheme.teal : TripReadyTheme.textLight, size: 22)),
        title: Text(doc.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (doc.notes != null) Text(doc.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          if (doc.hasFile)
            Row(children: [const Icon(Icons.attach_file, size: 12, color: TripReadyTheme.teal), const SizedBox(width: 2),
              Expanded(child: Text(doc.filePath!.split(Platform.pathSeparator).last, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.teal), overflow: TextOverflow.ellipsis))])
          else
            Text(l.documentsNoFileAttached, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.textLight)),
          if (doc.expiryDate != null)
            Row(children: [
              const Icon(Icons.event_outlined, size: 11, color: TripReadyTheme.amber),
              const SizedBox(width: 3),
              Text('Expires ${DateFormat('dd MMM yyyy').format(doc.expiryDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: doc.expiryDate!.isBefore(DateTime.now()) ? TripReadyTheme.danger : TripReadyTheme.amber,
                  fontWeight: FontWeight.w600)),
            ]),
        ]),
        trailing: !isArchived ? SizedBox(width: 80, child: Row(mainAxisSize: MainAxisSize.min, children: [
          ReminderBell(refType: ReminderRefType.document, refId: doc.id),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: TripReadyTheme.textLight),
            onSelected: (val) { if (val == 'open') onOpen(); if (val == 'edit') onEdit(); if (val == 'delete') onDelete(); },
            itemBuilder: (_) => [
              if (doc.hasFile) PopupMenuItem(value: 'open', child: Text(l.documentsFileAttached)),
              PopupMenuItem(value: 'edit', child: Text(l.actionEdit)),
              PopupMenuItem(value: 'delete', child: Text(l.actionDelete, style: const TextStyle(color: TripReadyTheme.danger))),
            ],
          ),
        ])) : null,
      ),
    );
  }
}

class _AddEditDocumentDialog extends StatefulWidget {
  final String tripId;
  final TripDocument? document;
  final String Function(DocumentType, AppLocalizations) typeLabel;
  const _AddEditDocumentDialog({required this.tripId, this.document, required this.typeLabel});
  @override
  State<_AddEditDocumentDialog> createState() => _AddEditDocumentDialogState();
}

class _AddEditDocumentDialogState extends State<_AddEditDocumentDialog> {
  final _nameController  = TextEditingController();
  final _notesController = TextEditingController();
  final _reminderKey = GlobalKey<ItemReminderRowState>();
  DocumentType _type = DocumentType.other;
  String? _filePath;
  DateTime? _expiryDate;
  bool _isSaving = false, _isPickingFile = false;
  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) { final d = widget.document!; _nameController.text = d.name; _notesController.text = d.notes ?? ''; _type = d.type; _filePath = d.filePath; _expiryDate = d.expiryDate; }
  }

  @override
  void dispose() {
    _nameController.dispose(); _notesController.dispose(); super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        setState(() => _filePath = result.files.single.path);
        if (_nameController.text.trim().isEmpty) _nameController.text = result.files.single.name.replaceAll(RegExp(r'\.[^.]+$'), '');
      }
    } finally { if (mounted) setState(() => _isPickingFile = false); }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateDocument(widget.document!.copyWith(name: _nameController.text.trim(), type: _type, filePath: _filePath, notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(), expiryDate: _expiryDate, clearExpiryDate: _expiryDate == null));
      } else {
        final newDocId = const Uuid().v4();
        await DatabaseHelper.instance.insertDocument(TripDocument(id: newDocId, tripId: widget.tripId, name: _nameController.text.trim(), type: _type, filePath: _filePath, notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(), expiryDate: _expiryDate, createdAt: DateTime.now()));
        await _reminderKey.currentState?.commitForRef(newDocId);
      }
      if (mounted) Navigator.pop(context, true);
    } finally { if (mounted) setState(() => _isSaving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AlertDialog(
      title: Text(_isEditing ? l.actionEdit : l.documentsAddDocument),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameController, autofocus: true,
          decoration: InputDecoration(labelText: '${l.documentsDocumentName} *', prefixIcon: const Icon(Icons.description_outlined))),
        const SizedBox(height: 10),
        DropdownButtonFormField<DocumentType>(
          value: _type,
          decoration: InputDecoration(labelText: l.fieldCategory, prefixIcon: const Icon(Icons.category_outlined)),
          items: DocumentType.values.map((t) => DropdownMenuItem(value: t, child: Text(widget.typeLabel(t, l)))).toList(),
          onChanged: (v) => setState(() => _type = v!),
        ),
        const SizedBox(height: 10),
        GestureDetector(onTap: _isPickingFile ? null : _pickFile, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _filePath != null ? TripReadyTheme.teal : TripReadyTheme.warmGrey, width: _filePath != null ? 2 : 1)),
          child: Row(children: [
            Icon(_filePath != null ? Icons.attach_file : Icons.upload_file_outlined, size: 18, color: _filePath != null ? TripReadyTheme.teal : TripReadyTheme.textMid),
            const SizedBox(width: 10),
            Expanded(child: _isPickingFile ? const Text('...') : Text(_filePath != null ? _filePath!.split(Platform.pathSeparator).last : l.documentsFileAttached,
              style: TextStyle(color: _filePath != null ? TripReadyTheme.textDark : TripReadyTheme.textLight, fontSize: 13), overflow: TextOverflow.ellipsis)),
            if (_filePath != null) GestureDetector(onTap: () => setState(() => _filePath = null), child: const Icon(Icons.close, size: 16, color: TripReadyTheme.textLight)),
          ]))),
        const SizedBox(height: 10),
        TextField(controller: _notesController, maxLines: 2,
          decoration: InputDecoration(labelText: l.fieldNotes, prefixIcon: const Icon(Icons.notes_outlined), alignLabelWithHint: true)),
        const SizedBox(height: 10),
        _ExpiryDateField(
          value: _expiryDate,
          onChanged: (d) => setState(() => _expiryDate = d),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 4),
        ItemReminderRow(
          key: _reminderKey,
          refType: ReminderRefType.document,
          refId: widget.document?.id,
          label: 'Document reminder',
          contextDate: _expiryDate,
        ),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isEditing ? l.actionUpdate : l.documentsAddDocument),
        ),
      ],
    );
  }
}

// ── Expiry Date Field ─────────────────────────────────────────────────────────

class _ExpiryDateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _ExpiryDateField({required this.value, required this.onChanged});

  static final _fmt = DateFormat('dd MMM yyyy');

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2020), lastDate: DateTime(2040),
      helpText: 'Document expiry date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(
            primary: TripReadyTheme.teal, onPrimary: Colors.white)),
        child: child!),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null ? TripReadyTheme.teal : TripReadyTheme.warmGrey,
            width: value != null ? 2 : 1),
        ),
        child: Row(children: [
          Icon(Icons.event_outlined, size: 18,
              color: value != null ? TripReadyTheme.teal : TripReadyTheme.textMid),
          const SizedBox(width: 10),
          Expanded(child: Text(
            value != null ? 'Expires ${_fmt.format(value!)}' : 'Expiry date (optional)',
            style: TextStyle(fontSize: 14,
                color: value != null ? TripReadyTheme.textDark : TripReadyTheme.textLight))),
          if (value != null)
            GestureDetector(
              onTap: () => onChanged(null),
              child: const Icon(Icons.close, size: 16, color: TripReadyTheme.textLight)),
        ]),
      ),
    );
  }
}
