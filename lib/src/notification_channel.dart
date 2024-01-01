/// Importance level for a notification channel.
enum Importance {
  /// Low importance — no sound, minimal visual interruption.
  low,

  /// Normal importance — default behavior.
  normal,

  /// High importance — sound and prominent display.
  high,
}

/// A named channel that groups related notifications.
class NotificationChannel {
  /// The channel name, used as its identifier.
  final String name;

  /// The importance level of this channel.
  final Importance importance;

  /// Whether notifications on this channel should play a sound.
  final bool sound;

  /// Optional description of the channel's purpose.
  final String? description;

  /// Create a new notification channel.
  const NotificationChannel({
    required this.name,
    this.importance = Importance.normal,
    this.sound = true,
    this.description,
  });
}
