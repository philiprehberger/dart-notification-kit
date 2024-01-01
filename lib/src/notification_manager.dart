import 'delivery_backend.dart';
import 'notification.dart';
import 'notification_scheduler.dart';

/// Callback invoked when a notification is delivered.
typedef OnDeliverCallback = void Function(Notification notification);

/// High-level facade for scheduling, delivering, and managing notifications.
class NotificationManager {
  final NotificationScheduler _scheduler = NotificationScheduler();
  final DeliveryBackend _backend;

  /// Optional callback invoked after each notification is delivered.
  OnDeliverCallback? onDeliver;

  /// Create a notification manager with the given [backend].
  NotificationManager({
    required DeliveryBackend backend,
    this.onDeliver,
  }) : _backend = backend;

  /// Schedule a notification for delivery.
  void schedule(Notification notification) {
    _scheduler.schedule(notification);
  }

  /// Cancel a pending notification by [id].
  bool cancel(String id) => _scheduler.cancel(id);

  /// Returns all pending notifications.
  List<Notification> pending() => _scheduler.pending();

  /// Returns all delivered notifications.
  List<Notification> delivered() => _scheduler.delivered();

  /// Deliver all due notifications through the backend.
  ///
  /// Returns the list of notifications that were delivered.
  Future<List<Notification>> deliverDue({DateTime? now}) async {
    final due = _scheduler.deliverDue(now: now);
    for (final notification in due) {
      await _backend.deliver(notification);
      onDeliver?.call(notification);
    }
    return due;
  }
}
