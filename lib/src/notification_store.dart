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

  /// Search notifications by combining filters with AND semantics.
  ///
  /// All non-null parameters are combined as filters:
  /// - [query] matches case-insensitively as a substring against title and body.
  /// - [priority] requires an exact priority match.
  /// - [channel] requires the channel name to match exactly.
  /// - [after] keeps notifications whose `deliverAt` is at or after this time.
  /// - [before] keeps notifications whose `deliverAt` is at or before this time.
  ///
  /// Notifications without a `deliverAt` are excluded when [after] or [before]
  /// is provided.
  List<Notification> search({
    String? query,
    Priority? priority,
    String? channel,
    DateTime? after,
    DateTime? before,
  }) {
    final lowered = query?.toLowerCase();

    return _store.values.where((n) {
      if (lowered != null) {
        final inTitle = n.title.toLowerCase().contains(lowered);
        final inBody = n.body.toLowerCase().contains(lowered);
        if (!inTitle && !inBody) return false;
      }
      if (priority != null && n.priority != priority) return false;
      if (channel != null && n.channel?.name != channel) return false;
      if (after != null) {
        if (n.deliverAt == null) return false;
        if (n.deliverAt!.isBefore(after)) return false;
      }
      if (before != null) {
        if (n.deliverAt == null) return false;
        if (n.deliverAt!.isAfter(before)) return false;
      }
      return true;
    }).toList();
  }

  /// The number of notifications in the store.
  int get count => _store.length;

  /// Remove all notifications matching the [predicate].
  ///
  /// Returns the number of notifications removed.
  int removeWhere(bool Function(Notification) predicate) {
    final toRemove = _store.entries
        .where((e) => predicate(e.value))
        .map((e) => e.key)
        .toList();

    for (final key in toRemove) {
      _store.remove(key);
    }

    return toRemove.length;
  }

  /// Remove all notifications from the store.
  void clear() => _store.clear();
}
