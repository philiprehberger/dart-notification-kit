import 'delivery_backend.dart';
import 'notification.dart';

/// A delivery backend decorator that logs each notification before delegating
/// delivery to an [inner] backend.
///
/// The [sink] callback is invoked with the notification before it is forwarded
/// to [inner.deliver]. Useful for adding observability (logging, metrics, audit
/// trails) without modifying the underlying backend.
class LoggingDeliveryBackend implements DeliveryBackend {
  /// The wrapped backend that performs the actual delivery.
  final DeliveryBackend inner;

  /// Callback invoked with each notification before delivery.
  final void Function(Notification) sink;

  /// Create a logging decorator that wraps [inner] and emits each notification
  /// to [sink] before delivery.
  const LoggingDeliveryBackend({required this.inner, required this.sink});

  @override
  Future<void> deliver(Notification notification) async {
    sink(notification);
    await inner.deliver(notification);
  }
}
