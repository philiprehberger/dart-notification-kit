/// Per-channel rate limiter for notification delivery.
class RateLimiter {
  /// The cooldown duration between deliveries on the same channel.
  final Duration cooldown;

  final Map<String, DateTime> _lastDelivery = {};

  /// Create a rate limiter with the given [cooldown] duration.
  RateLimiter({required this.cooldown});

  /// Returns `true` if the [channelName] is allowed to deliver.
  ///
  /// A channel is allowed if the cooldown has elapsed since its last delivery.
  /// Updates the last delivery time when returning `true`.
  bool allow(String channelName) {
    final now = DateTime.now();
    final last = _lastDelivery[channelName];

    if (last != null && now.difference(last) < cooldown) {
      return false;
    }

    _lastDelivery[channelName] = now;
    return true;
  }

  /// Remove cooldown tracking for a specific [channelName].
  void reset(String channelName) {
    _lastDelivery.remove(channelName);
  }

  /// Clear all cooldown tracking.
  void resetAll() {
    _lastDelivery.clear();
  }
}
