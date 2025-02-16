import 'notification.dart';

/// In-memory store for notifications with lookup by id, channel, and priority.
class NotificationStore {
  final Map<String, Notification> _store = {};

  /// Add a notification to the store.
  void add(Notification notification) {
    _store[notification.id] = notification;
  }

  /// Get a notification by [id], or `null` if not found.
  Notification? get(String id) => _store[id];

  /// Remove a notification by [id].
  ///
  /// Returns `true` if the notification was found and removed.
  bool remove(String id) => _store.remove(id) != null;

  /// Returns all notifications in the store.
  List<Notification> all() => List.unmodifiable(_store.values);

  /// Returns all notifications belonging to the channel with [name].
  List<Notification> byChannel(String name) =>
      _store.values.where((n) => n.channel?.name == name).toList();

  /// Returns all notifications with the given [priority].
  List<Notification> byPriority(Priority priority) =>
      _store.values.where((n) => n.priority == priority).toList();

  /// Get notifications by group ID.
  List<Notification> byGroup(String groupId) {
    return _store.values.where((n) => n.groupId == groupId).toList();
  }

  /// Get notifications by delivery status.
  List<Notification> byStatus(DeliveryStatus status) {
    return _store.values.where((n) => n.deliveryStatus == status).toList();
  }

  /// The number of notifications in the store.
  int get count => _store.length;

  /// Remove all notifications from the store.
  void clear() => _store.clear();
}
