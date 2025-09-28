import 'notification.dart';
import 'notification_channel.dart';

/// A reusable notification template with `{{variable}}` placeholder substitution.
class NotificationTemplate {
  /// The title template with optional `{{key}}` placeholders.
  final String titleTemplate;

  /// The body template with optional `{{key}}` placeholders.
  final String bodyTemplate;

  /// Optional channel to assign to built notifications.
  final NotificationChannel? channel;

  /// Optional priority to assign to built notifications.
  final Priority? priority;

  static final RegExp _placeholderPattern = RegExp(r'\{\{(\w+)\}\}');

  /// Create a notification template.
  const NotificationTemplate({
    required this.titleTemplate,
    required this.bodyTemplate,
    this.channel,
    this.priority,
  });

  /// Build a [Notification] by substituting [variables] into the templates.
  ///
  /// Placeholders that do not have a matching key in [variables] are left as-is.
  Notification build(Map<String, String> variables) {
    final title = _substitute(titleTemplate, variables);
    final body = _substitute(bodyTemplate, variables);

    return Notification(
      title: title,
      body: body,
      channel: channel,
      priority: priority ?? Priority.normal,
    );
  }

  /// Extracts all `{{key}}` placeholder names from both templates.
  List<String> get placeholders {
    final matches = <String>{};

    for (final match in _placeholderPattern.allMatches(titleTemplate)) {
      matches.add(match.group(1)!);
    }
    for (final match in _placeholderPattern.allMatches(bodyTemplate)) {
      matches.add(match.group(1)!);
    }

    return matches.toList();
  }

  String _substitute(String template, Map<String, String> variables) {
    return template.replaceAllMapped(_placeholderPattern, (match) {
      final key = match.group(1)!;
      return variables.containsKey(key) ? variables[key]! : match.group(0)!;
    });
  }
}
