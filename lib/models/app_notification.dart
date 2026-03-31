import 'package:uuid/uuid.dart';
import 'reminder.dart';

/// A fired notification event shown in the Notification Center.
/// Distinct from [Reminder] (schedule). EP4 trigger engine creates these.
class AppNotification {
  final String id;
  final ReminderRefType refType;
  final String refId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.refType,
    required this.refId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id, refType: refType, refId: refId,
    title: title, body: body,
    isRead:    isRead    ?? this.isRead,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id':         id,
    'ref_type':   refType.value,
    'ref_id':     refId,
    'title':      title,
    'body':       body,
    'is_read':    isRead ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
    id:        m['id'] as String,
    refType:   ReminderRefTypeExt.fromString(m['ref_type'] as String),
    refId:     m['ref_id'] as String,
    title:     m['title'] as String,
    body:      m['body'] as String,
    isRead:    (m['is_read'] as int) == 1,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  static String newId() => const Uuid().v4();
}
