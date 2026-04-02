import 'notification_channel.dart';

/// Status of notification delivery.
enum DeliveryStatus {
  /// Waiting to be delivered.
  pending,
  /// Successfully delivered.
  delivered,
  /// Delivery failed.
  failed,
  /// Being retried.
  retrying,
}

/// Priority level for a notification.
enum Priority {
  /// Low priority — informational, non-urgent.
  low,

  /// Normal priority — default level.
  normal,

  /// High priority — important, should be seen soon.
  high,

  /// Urgent priority — requires immediate attention.
  urgent,
}

/// A notification with a title, body, optional channel, priority, and payload.
class Notification {
  /// Unique identifier for this notification.
  final String id;

  /// The notification title.
  final String title;

  /// The notification body text.
  final String body;

  /// Optional channel this notification belongs to.
  final NotificationChannel? channel;

  /// Priority level. Defaults to [Priority.normal].
  final Priority priority;

  /// Arbitrary key-value payload attached to the notification.
  final Map<String, String> payload;

  /// Optional group identifier for grouping related notifications.
  final String? groupId;

  /// Current delivery status.
  DeliveryStatus deliveryStatus;

  /// When this notification should be delivered. `null` means immediate.
  final DateTime? deliverAt;

  /// When this notification was created.
  final DateTime createdAt;

  static int _counter = 0;

  /// Create a new notification.
  ///
  /// An [id] is auto-generated if not provided.
  Notification({
    String? id,
    required this.title,
    required this.body,
    this.channel,
    this.priority = Priority.normal,
    Map<String, String>? payload,
    this.groupId,
    this.deliveryStatus = DeliveryStatus.pending,
    this.deliverAt,
    DateTime? createdAt,
  })  : id = id ?? _generateId(),
        payload = payload ?? const {},
        createdAt = createdAt ?? DateTime.now();

  static String _generateId() {
    _counter++;
    return 'notif_${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }
}
