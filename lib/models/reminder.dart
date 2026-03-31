import 'package:uuid/uuid.dart';

enum ReminderRefType { trip, tripStop, task, document, packing }

extension ReminderRefTypeExt on ReminderRefType {
  String get value => name;
  static ReminderRefType fromString(String s) =>
      ReminderRefType.values.firstWhere((e) => e.name == s,
          orElse: () => ReminderRefType.trip);
}

class Reminder {
  final String id;
  final ReminderRefType refType;
  final String refId;
  final int? stopIndex;   // null for non-leg reminders; -1=departure, N=stop N, 999=return
  final int leadDays;
  final String timeOfDay; // 'HH:MM'
  final bool isEnabled;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.refType,
    required this.refId,
    this.stopIndex,
    required this.leadDays,
    required this.timeOfDay,
    required this.isEnabled,
    required this.createdAt,
  });

  Reminder copyWith({
    int? leadDays,
    String? timeOfDay,
    bool? isEnabled,
  }) => Reminder(
    id: id, refType: refType, refId: refId, stopIndex: stopIndex,
    leadDays:  leadDays  ?? this.leadDays,
    timeOfDay: timeOfDay ?? this.timeOfDay,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id':         id,
    'ref_type':   refType.value,
    'ref_id':     refId,
    'stop_index': stopIndex,
    'lead_days':  leadDays,
    'time_of_day': timeOfDay,
    'is_enabled': isEnabled ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
    id:        m['id'] as String,
    refType:   ReminderRefTypeExt.fromString(m['ref_type'] as String),
    refId:     m['ref_id'] as String,
    stopIndex: m['stop_index'] as int?,
    leadDays:  m['lead_days'] as int,
    timeOfDay: m['time_of_day'] as String,
    isEnabled: (m['is_enabled'] as int) == 1,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  static String newId() => const Uuid().v4();
}
