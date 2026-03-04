import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import '../../database/database_helper.dart';
import '../../database/trip_details_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/localization_ext.dart';

class TasksScreen extends StatefulWidget {
  final Trip trip;
  const TasksScreen({super.key, required this.trip});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  List<TripTask> _tasks = [];
  bool _isLoading = true;
  late TabController _tabController;
  TaskSource? _sourceFilter; // null = all, task = manual only, packing = packing only

  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); _load(); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final tasks = await DatabaseHelper.instance.getTasks(widget.trip.id);
    setState(() { _tasks = tasks; _isLoading = false; });
  }

  List<TripTask> get _filtered => _sourceFilter == null
      ? _tasks
      : _tasks.where((t) => t.source == _sourceFilter).toList();

  List<TripTask> get _pending    => _filtered.where((t) => t.status == TaskStatus.pending).toList();
  List<TripTask> get _inProgress => _filtered.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TripTask> get _done       => _filtered.where((t) => t.status == TaskStatus.done).toList();

  bool get _hasPackingTasks => _tasks.any((t) => t.isFromPacking);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isArchived = widget.trip.isArchived;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tasksTitle),
        actions: [HomeButton()],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TripReadyTheme.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: '${l.tasksTabPending} (${_pending.length})'),
            Tab(text: '${l.tasksTabInProgress} (${_inProgress.length})'),
            Tab(text: '${l.tasksTabDone} (${_done.length})'),
          ],
        ),
      ),
      floatingActionButton: isArchived ? null : FloatingActionButton.extended(
        onPressed: _addTask, icon: const Icon(Icons.add), label: Text(l.tasksAddTask)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : Column(children: [
              if (_tasks.isNotEmpty) _TaskProgressBar(done: _done.length, total: _tasks.length),
              if (_hasPackingTasks) _SourceFilterBar(
                selected: _sourceFilter,
                onChanged: (s) => setState(() => _sourceFilter = s),
              ),
              Expanded(child: TabBarView(controller: _tabController, children: [
                _TaskList(tasks: _pending, isArchived: isArchived,
                  emptyTitle: l.tasksNoPending, emptySubtitle: isArchived ? l.archiveNoTripsSubtitle : l.tasksAddTask,
                  buttonLabel: isArchived ? null : l.tasksAddTask, onButtonPressed: isArchived ? null : _addTask,
                  onEdit: _editTask, onDelete: _deleteTask, onStatusChange: _changeStatus),
                _TaskList(tasks: _inProgress, isArchived: isArchived,
                  emptyTitle: l.tasksNoInProgress, emptySubtitle: l.tasksTabPending,
                  onEdit: _editTask, onDelete: _deleteTask, onStatusChange: _changeStatus),
                _TaskList(tasks: _done, isArchived: isArchived,
                  emptyTitle: l.tasksNoDone, emptySubtitle: '',
                  onEdit: _editTask, onDelete: _deleteTask, onStatusChange: _changeStatus),
              ])),
            ]),
    );
  }

  Future<void> _addTask() async {
    final result = await showDialog<bool>(context: context, builder: (_) => _AddEditTaskDialog(tripId: widget.trip.id));
    if (result == true) _load();
  }

  Future<void> _editTask(TripTask task) async {
    final result = await showDialog<bool>(context: context, builder: (_) => _AddEditTaskDialog(tripId: widget.trip.id, task: task));
    if (result == true) _load();
  }

  Future<void> _deleteTask(TripTask task) async {
    final l = context.l;
    final confirm = await showConfirmDialog(context, title: l.actionDelete, message: '"${task.name}"?', confirmLabel: l.actionDelete);
    if (confirm == true) { await DatabaseHelper.instance.deleteTask(task.id); _load(); }
  }

  Future<void> _changeStatus(TripTask task, TaskStatus status) async {
    await DatabaseHelper.instance.setTaskStatus(task.id, status);
    // Two-way sync: if this is a packing task, update the packing item too
    if (task.isFromPacking && task.sourceId != null) {
      await DatabaseHelper.instance.syncPackingFromTask(task.sourceId!, status == TaskStatus.done);
    }
    _load();
  }
}

class _TaskProgressBar extends StatelessWidget {
  final int done, total;
  const _TaskProgressBar({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      color: TripReadyTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l.tasksProgress, style: Theme.of(context).textTheme.titleSmall),
          Text(l.tasksDoneCount(done, total), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.success, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: TripReadyTheme.warmGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(TripReadyTheme.success))),
      ]),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TripTask> tasks;
  final bool isArchived;
  final String emptyTitle, emptySubtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Function(TripTask) onEdit, onDelete;
  final Function(TripTask, TaskStatus) onStatusChange;

  const _TaskList({required this.tasks, required this.isArchived, required this.emptyTitle, required this.emptySubtitle,
    this.buttonLabel, this.onButtonPressed, required this.onEdit, required this.onDelete, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return EmptyState(icon: Icons.task_alt_outlined, title: emptyTitle, subtitle: emptySubtitle, buttonLabel: buttonLabel, onButtonPressed: onButtonPressed);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (ctx, i) => _TaskCard(task: tasks[i], isArchived: isArchived,
        onEdit: () => onEdit(tasks[i]), onDelete: () => onDelete(tasks[i]), onStatusChange: (s) => onStatusChange(tasks[i], s)),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TripTask task;
  final bool isArchived;
  final VoidCallback onEdit, onDelete;
  final Function(TaskStatus) onStatusChange;

  const _TaskCard({required this.task, required this.isArchived, required this.onEdit, required this.onDelete, required this.onStatusChange});

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.pending:    return TripReadyTheme.textMid;
      case TaskStatus.inProgress: return TripReadyTheme.amber;
      case TaskStatus.done:       return TripReadyTheme.success;
    }
  }

  bool get _isOverdue => task.dueDate != null && !task.isDone && task.dueDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fmt = DateFormat('dd MMM yyyy');

    String statusLabel;
    switch (task.status) {
      case TaskStatus.pending:    statusLabel = l.tasksStatusPending; break;
      case TaskStatus.inProgress: statusLabel = l.tasksStatusInProgress; break;
      case TaskStatus.done:       statusLabel = l.tasksStatusDone; break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: isArchived ? null : () {
                final next = task.status == TaskStatus.pending ? TaskStatus.inProgress
                    : task.status == TaskStatus.inProgress ? TaskStatus.done : TaskStatus.pending;
                onStatusChange(next);
              },
              child: Container(
                width: 28, height: 28,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: _statusColor, width: 2)),
                child: task.isDone ? Icon(Icons.check, size: 14, color: _statusColor)
                    : task.status == TaskStatus.inProgress ? Icon(Icons.timelapse, size: 14, color: _statusColor) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (task.isFromPacking) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: TripReadyTheme.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.luggage_outlined, size: 10, color: TripReadyTheme.teal),
                      const SizedBox(width: 3),
                      Text('PACKING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                          color: TripReadyTheme.teal, letterSpacing: 0.5)),
                    ]),
                  ),
                ],
                Expanded(child: Text(task.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                  color: task.isDone ? TripReadyTheme.textMid : null))),
              ]),
              if (task.dueDate != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: _isOverdue ? TripReadyTheme.danger : TripReadyTheme.textMid),
                  const SizedBox(width: 4),
                  Text(fmt.format(task.dueDate!), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _isOverdue ? TripReadyTheme.danger : null, fontWeight: _isOverdue ? FontWeight.w700 : null)),
                  if (_isOverdue) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: TripReadyTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(l.tasksOverdue, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: TripReadyTheme.danger, letterSpacing: 0.5)),
                    ),
                  ],
                ]),
              ],
              if (task.notes != null) ...[
                const SizedBox(height: 4),
                Text(task.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: TripReadyTheme.textMid)),
              ],
            ])),
            if (!isArchived)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: TripReadyTheme.textLight),
                onSelected: (val) {
                  if (val == 'edit')        onEdit();
                  if (val == 'delete')      onDelete();
                  if (val == 'pending')     onStatusChange(TaskStatus.pending);
                  if (val == 'in_progress') onStatusChange(TaskStatus.inProgress);
                  if (val == 'done')        onStatusChange(TaskStatus.done);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l.actionEdit)),
                  const PopupMenuDivider(),
                  if (task.status != TaskStatus.pending)    PopupMenuItem(value: 'pending',     child: Text(l.tasksMarkPending)),
                  if (task.status != TaskStatus.inProgress) PopupMenuItem(value: 'in_progress', child: Text(l.tasksMarkInProgress)),
                  if (task.status != TaskStatus.done)       PopupMenuItem(value: 'done',        child: Text(l.tasksMarkDone)),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'delete', child: Text(l.actionDelete, style: const TextStyle(color: TripReadyTheme.danger))),
                ],
              ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            StatusBadge(label: statusLabel.toUpperCase(), color: _statusColor.withOpacity(0.15), textColor: _statusColor),
            if (!isArchived && !task.isDone) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onStatusChange(task.status == TaskStatus.pending ? TaskStatus.inProgress : TaskStatus.done),
                child: Row(children: [
                  Text(task.status == TaskStatus.pending ? l.tasksStart : l.tasksComplete,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12)),
                  const Icon(Icons.chevron_right, size: 16, color: TripReadyTheme.teal),
                ]),
              ),
            ],
          ]),
        ]),
      ),
    );
  }
}

// ── Source filter bar ────────────────────────────────────────────────────────

class _SourceFilterBar extends StatelessWidget {
  final TaskSource? selected;
  final ValueChanged<TaskSource?> onChanged;
  const _SourceFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      color: TripReadyTheme.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        _chip(context, label: 'All', icon: Icons.list_outlined,
            active: selected == null, color: primary,
            onTap: () => onChanged(null)),
        const SizedBox(width: 8),
        _chip(context, label: 'Tasks', icon: Icons.task_outlined,
            active: selected == TaskSource.task, color: TripReadyTheme.amber,
            onTap: () => onChanged(selected == TaskSource.task ? null : TaskSource.task)),
        const SizedBox(width: 8),
        _chip(context, label: 'Packing', icon: Icons.luggage_outlined,
            active: selected == TaskSource.packing, color: TripReadyTheme.teal,
            onTap: () => onChanged(selected == TaskSource.packing ? null : TaskSource.packing)),
      ]),
    );
  }

  Widget _chip(BuildContext context, {
    required String label, required IconData icon,
    required bool active, required Color color, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : TripReadyTheme.warmGrey,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? color : TripReadyTheme.textMid),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? color : TripReadyTheme.textMid,
          )),
        ]),
      ),
    );
  }
}

class _AddEditTaskDialog extends StatefulWidget {
  final String tripId;
  final TripTask? task;
  const _AddEditTaskDialog({required this.tripId, this.task});
  @override
  State<_AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<_AddEditTaskDialog> {
  final _nameController  = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.pending;
  bool _isSaving = false;
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text  = widget.task!.name;
      _notesController.text = widget.task!.notes ?? '';
      _dueDate = widget.task!.dueDate;
      _status  = widget.task!.status;
    }
  }

  @override
  void dispose() { _nameController.dispose(); _notesController.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: TripReadyTheme.teal)), child: child!));
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      if (_isEditing) {
        await DatabaseHelper.instance.updateTask(widget.task!.copyWith(
          name: _nameController.text.trim(), dueDate: _dueDate, clearDueDate: _dueDate == null,
          status: _status, notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim()));
      } else {
        await DatabaseHelper.instance.insertTask(TripTask(
          id: const Uuid().v4(), tripId: widget.tripId, name: _nameController.text.trim(),
          dueDate: _dueDate, status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(), createdAt: now));
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _statusLabel(TaskStatus s, AppLocalizations l) {
    switch (s) {
      case TaskStatus.pending:    return l.tasksStatusPending;
      case TaskStatus.inProgress: return l.tasksStatusInProgress;
      case TaskStatus.done:       return l.tasksStatusDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fmt = DateFormat('dd MMM yyyy');
    return AlertDialog(
      title: Text(_isEditing ? l.actionEdit : l.tasksAddTask),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _nameController, autofocus: true,
          decoration: InputDecoration(labelText: '${l.tasksTaskName} *', prefixIcon: const Icon(Icons.task_outlined))),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _dueDate != null ? TripReadyTheme.teal : TripReadyTheme.warmGrey, width: _dueDate != null ? 2 : 1)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: TripReadyTheme.teal),
              const SizedBox(width: 10),
              Expanded(child: Text(_dueDate != null ? fmt.format(_dueDate!) : l.tasksDueDate,
                style: TextStyle(color: _dueDate != null ? TripReadyTheme.textDark : TripReadyTheme.textLight, fontSize: 14))),
              if (_dueDate != null) GestureDetector(onTap: () => setState(() => _dueDate = null), child: const Icon(Icons.close, size: 16, color: TripReadyTheme.textLight)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<TaskStatus>(
          value: _status,
          decoration: InputDecoration(labelText: l.fieldStatus, prefixIcon: const Icon(Icons.toggle_on_outlined)),
          items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s, l)))).toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
        const SizedBox(height: 12),
        TextField(controller: _notesController, maxLines: 2,
          decoration: InputDecoration(labelText: l.fieldNotes, prefixIcon: const Icon(Icons.notes_outlined), alignLabelWithHint: true)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEditing ? l.actionUpdate : l.tasksAddTask),
        ),
      ],
    );
  }
}
