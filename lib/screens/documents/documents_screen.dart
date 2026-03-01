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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final docs = await DatabaseHelper.instance.getDocuments(widget.trip.id);
    setState(() {
      _documents = docs;
      _isLoading = false;
    });
  }

  Map<DocumentType, List<TripDocument>> get _grouped {
    final Map<DocumentType, List<TripDocument>> grouped = {};
    for (final doc in _documents) {
      grouped.putIfAbsent(doc.type, () => []).add(doc);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.name.compareTo(b.key.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArchived = widget.trip.isArchived;

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: isArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: _addDocument,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Document'),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : _documents.isEmpty
              ? EmptyState(
                  icon: Icons.folder_open_outlined,
                  title: 'No documents yet',
                  subtitle: isArchived
                      ? 'This trip is archived.'
                      : 'Add tickets, vouchers, letters and other documents.',
                  buttonLabel: isArchived ? null : 'Add Document',
                  onButtonPressed: isArchived ? null : _addDocument,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _grouped.length,
                  itemBuilder: (ctx, i) {
                    final entry = _grouped.entries.elementAt(i);
                    return _DocTypeGroup(
                      type: entry.key,
                      docs: entry.value,
                      isArchived: isArchived,
                      onEdit: _editDocument,
                      onDelete: _deleteDocument,
                      onOpen: _openDocument,
                    );
                  },
                ),
    );
  }

  Future<void> _addDocument() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditDocumentDialog(tripId: widget.trip.id),
    );
    if (result == true) _load();
  }

  Future<void> _editDocument(TripDocument doc) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditDocumentDialog(tripId: widget.trip.id, document: doc),
    );
    if (result == true) _load();
  }

  Future<void> _deleteDocument(TripDocument doc) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Document',
      message: 'Delete "${doc.name}"?',
      confirmLabel: 'Delete',
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteDocument(doc.id);
      _load();
    }
  }

  Future<void> _openDocument(TripDocument doc) async {
    if (!doc.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file attached to this document.')),
      );
      return;
    }
    final file = File(doc.filePath!);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found. It may have been moved or deleted.')),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File: ${doc.filePath}')),
      );
    }
  }
}

// ── Document Type Group ───────────────────────────────────────
class _DocTypeGroup extends StatelessWidget {
  final DocumentType type;
  final List<TripDocument> docs;
  final bool isArchived;
  final Function(TripDocument) onEdit;
  final Function(TripDocument) onDelete;
  final Function(TripDocument) onOpen;

  const _DocTypeGroup({
    required this.type,
    required this.docs,
    required this.isArchived,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  });

  IconData get _typeIcon {
    switch (type) {
      case DocumentType.ticket: return Icons.confirmation_number_outlined;
      case DocumentType.voucher: return Icons.card_giftcard_outlined;
      case DocumentType.letter: return Icons.mail_outlined;
      case DocumentType.passport: return Icons.menu_book_outlined;
      case DocumentType.visa: return Icons.approval_outlined;
      case DocumentType.insurance: return Icons.health_and_safety_outlined;
      case DocumentType.reservation: return Icons.hotel_outlined;
      case DocumentType.itinerary: return Icons.map_outlined;
      case DocumentType.other: return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Icon(_typeIcon, size: 14, color: TripReadyTheme.teal),
              const SizedBox(width: 6),
              Text(
                docs.first.typeLabel.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: TripReadyTheme.teal,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text('${docs.length}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        ...docs.map((d) => _DocumentCard(
              doc: d,
              isArchived: isArchived,
              onEdit: () => onEdit(d),
              onDelete: () => onDelete(d),
              onOpen: () => onOpen(d),
            )),
      ],
    );
  }
}

// ── Document Card ─────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final TripDocument doc;
  final bool isArchived;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _DocumentCard({
    required this.doc,
    required this.isArchived,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: doc.hasFile
                ? TripReadyTheme.teal.withOpacity(0.1)
                : TripReadyTheme.warmGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            doc.hasFile ? Icons.insert_drive_file : Icons.insert_drive_file_outlined,
            color: doc.hasFile ? TripReadyTheme.teal : TripReadyTheme.textLight,
            size: 22,
          ),
        ),
        title: Text(doc.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc.notes != null)
              Text(doc.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic)),
            if (doc.hasFile)
              Row(children: [
                const Icon(Icons.attach_file, size: 12, color: TripReadyTheme.teal),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    doc.filePath!.split(Platform.pathSeparator).last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TripReadyTheme.teal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ])
            else
              Text('No file attached',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TripReadyTheme.textLight)),
          ],
        ),
        trailing: !isArchived
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: TripReadyTheme.textLight),
                onSelected: (val) {
                  if (val == 'open') onOpen();
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (doc.hasFile)
                    const PopupMenuItem(value: 'open', child: Text('View File Path')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: TripReadyTheme.danger))),
                ],
              )
            : null,
      ),
    );
  }
}

// ── Add/Edit Document Dialog ──────────────────────────────────
class _AddEditDocumentDialog extends StatefulWidget {
  final String tripId;
  final TripDocument? document;

  const _AddEditDocumentDialog({required this.tripId, this.document});

  @override
  State<_AddEditDocumentDialog> createState() => _AddEditDocumentDialogState();
}

class _AddEditDocumentDialogState extends State<_AddEditDocumentDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DocumentType _type = DocumentType.other;
  String? _filePath;
  bool _isSaving = false;
  bool _isPickingFile = false;

  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final d = widget.document!;
      _nameController.text = d.name;
      _notesController.text = d.notes ?? '';
      _type = d.type;
      _filePath = d.filePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _filePath = result.files.single.path);
        // Auto-fill name if empty
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = result.files.single.name
              .replaceAll(RegExp(r'\.[^.]+$'), '');
        }
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.document!.copyWith(
          name: _nameController.text.trim(),
          type: _type,
          filePath: _filePath,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        await DatabaseHelper.instance.updateDocument(updated);
      } else {
        final doc = TripDocument(
          id: const Uuid().v4(),
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          type: _type,
          filePath: _filePath,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: DateTime.now(),
        );
        await DatabaseHelper.instance.insertDocument(doc);
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Document' : 'New Document'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Document Name *',
                hintText: 'e.g. Flight Ticket, Hotel Voucher',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<DocumentType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: DocumentType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.typeLabel),
              )).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 10),

            // File picker
            GestureDetector(
              onTap: _isPickingFile ? null : _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _filePath != null
                        ? TripReadyTheme.teal
                        : TripReadyTheme.warmGrey,
                    width: _filePath != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _filePath != null
                          ? Icons.attach_file
                          : Icons.upload_file_outlined,
                      size: 18,
                      color: _filePath != null
                          ? TripReadyTheme.teal
                          : TripReadyTheme.textMid,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isPickingFile
                          ? const Text('Selecting file...',
                              style: TextStyle(color: TripReadyTheme.textMid, fontSize: 13))
                          : Text(
                              _filePath != null
                                  ? _filePath!.split(Platform.pathSeparator).last
                                  : 'Attach a file (optional)',
                              style: TextStyle(
                                color: _filePath != null
                                    ? TripReadyTheme.textDark
                                    : TripReadyTheme.textLight,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (_filePath != null)
                      GestureDetector(
                        onTap: () => setState(() => _filePath = null),
                        child: const Icon(Icons.close,
                            size: 16, color: TripReadyTheme.textLight),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEditing ? 'Update' : 'Add Document'),
        ),
      ],
    );
  }
}

extension on DocumentType {
  String get typeLabel {
    switch (this) {
      case DocumentType.ticket: return 'Ticket';
      case DocumentType.voucher: return 'Voucher';
      case DocumentType.letter: return 'Letter';
      case DocumentType.passport: return 'Passport';
      case DocumentType.visa: return 'Visa';
      case DocumentType.insurance: return 'Insurance';
      case DocumentType.reservation: return 'Reservation';
      case DocumentType.itinerary: return 'Itinerary';
      case DocumentType.other: return 'Other';
    }
  }
}
