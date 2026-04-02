import 'notification.dart';

/// Abstract interface for delivering notifications.
abstract class DeliveryBackend {
  /// Deliver a notification through this backend.
  Future<void> deliver(Notification notification);
}

/// A delivery backend that stores delivered notifications in memory.
///
/// Useful for testing.
class MemoryDeliveryBackend implements DeliveryBackend {
  /// All notifications that have been delivered through this backend.
  final List<Notification> deliveries = [];

  @override
  Future<void> deliver(Notification notification) async {
    deliveries.add(notification);
  }
}
