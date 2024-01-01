import 'notification.dart';

/// Schedules notifications for future delivery and tracks their state.
class NotificationScheduler {
  final List<Notification> _pending = [];
  final List<Notification> _delivered = [];

  /// Schedule a notification for delivery.
  ///
  /// If [notification.deliverAt] is `null`, it is delivered immediately
  /// (moved to the delivered list).
  void schedule(Notification notification) {
    if (notification.deliverAt == null) {
      _delivered.add(notification);
    } else {
      _pending.add(notification);
    }
  }

  /// Cancel a pending notification by [id].
  ///
  /// Returns `true` if a notification was found and removed.
  bool cancel(String id) {
    final index = _pending.indexWhere((n) => n.id == id);
    if (index == -1) return false;
    _pending.removeAt(index);
    return true;
  }

  /// Returns a list of all pending (not yet delivered) notifications.
  List<Notification> pending() => List.unmodifiable(_pending);

  /// Returns a list of all delivered notifications.
  List<Notification> delivered() => List.unmodifiable(_delivered);

  /// Delivers all pending notifications whose [deliverAt] is at or before [now].
  ///
  /// Returns the list of notifications that were delivered.
  List<Notification> deliverDue({DateTime? now}) {
    final cutoff = now ?? DateTime.now();
    final due = <Notification>[];

    _pending.removeWhere((n) {
      if (n.deliverAt != null && !n.deliverAt!.isAfter(cutoff)) {
        due.add(n);
        return true;
      }
      return false;
    });

    _delivered.addAll(due);
    return due;
  }

  /// Reschedule a pending notification to a new delivery time.
  ///
  /// Returns `true` if the notification was found and rescheduled.
  bool reschedule(String id, DateTime newTime) {
    final index = _pending.indexWhere((n) => n.id == id);
    if (index == -1) return false;

    final old = _pending.removeAt(index);
    _pending.add(Notification(
      id: old.id,
      title: old.title,
      body: old.body,
      channel: old.channel,
      priority: old.priority,
      payload: old.payload,
      deliverAt: newTime,
      createdAt: old.createdAt,
    ));
    return true;
  }

  /// Clear all pending and delivered notifications.
  void clear() {
    _pending.clear();
    _delivered.clear();
  }
}
