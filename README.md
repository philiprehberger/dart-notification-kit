# philiprehberger_notification_kit

[![Tests](https://github.com/philiprehberger/dart-notification-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/dart-notification-kit/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/philiprehberger_notification_kit.svg)](https://pub.dev/packages/philiprehberger_notification_kit)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/dart-notification-kit)](https://github.com/philiprehberger/dart-notification-kit/commits/main)

Unified notification scheduling with channels, priorities, and payload management

## Requirements

- Dart >= 3.5

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  philiprehberger_notification_kit: ^0.3.0
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:philiprehberger_notification_kit/notification_kit.dart';

final backend = MemoryDeliveryBackend();
final manager = NotificationManager(backend: backend);

manager.schedule(Notification(
  title: 'Welcome',
  body: 'Thanks for signing up!',
));
```

### Channels and Priorities

```dart
final alerts = NotificationChannel(
  name: 'alerts',
  importance: Importance.high,
  sound: true,
);

manager.schedule(Notification(
  title: 'Server Down',
  body: 'Production is unreachable',
  channel: alerts,
  priority: Priority.urgent,
  payload: {'incident_id': '42'},
));
```

### Scheduled Delivery

```dart
manager.schedule(Notification(
  title: 'Reminder',
  body: 'Meeting in 15 minutes',
  deliverAt: DateTime.now().add(Duration(minutes: 15)),
));

// Later — deliver all due notifications
final delivered = await manager.deliverDue();
```

### Notification Store

```dart
final store = NotificationStore();

store.add(Notification(id: 'n1', title: 'Alert', body: 'text', priority: Priority.high));
store.add(Notification(id: 'n2', title: 'Info', body: 'text', priority: Priority.low));

final urgent = store.byPriority(Priority.high);
final channelNotifs = store.byChannel('alerts');
```

### Notification Groups

```dart
final store = NotificationStore();

store.add(Notification(title: 'Alert 1', body: 'text', groupId: 'alerts'));
store.add(Notification(title: 'Alert 2', body: 'text', groupId: 'alerts'));

final alertGroup = store.byGroup('alerts'); // 2 notifications
```

### Delivery Status

```dart
final n = Notification(title: 'Test', body: 'body');
print(n.deliveryStatus); // DeliveryStatus.pending

n.deliveryStatus = DeliveryStatus.delivered;

final pending = store.byStatus(DeliveryStatus.pending);
```

### Repeating Notifications

```dart
final scheduler = NotificationScheduler();

final ids = scheduler.scheduleRepeating(
  Notification(title: 'Standup', body: 'Daily standup reminder', deliverAt: DateTime.now()),
  interval: Duration(hours: 24),
  count: 7,
);
```

### Notification Templates

```dart
final template = NotificationTemplate(
  titleTemplate: 'Hello {{name}}',
  bodyTemplate: 'Your order {{orderId}} is {{status}}',
  priority: Priority.high,
);

// Extract placeholder names
print(template.placeholders); // [name, orderId, status]

// Build a notification with variable substitution
final notification = template.build({
  'name': 'Alice',
  'orderId': '42',
  'status': 'shipped',
});
```

### Rate Limiting

```dart
final limiter = RateLimiter(cooldown: Duration(seconds: 30));

final manager = NotificationManager(
  backend: backend,
  rateLimiter: limiter,
);

// Rapid deliveries on the same channel are throttled
```

### Bulk Removal

```dart
final store = NotificationStore();

// Remove all low-priority notifications
final removed = store.removeWhere((n) => n.priority == Priority.low);
print('Removed $removed notifications');
```

### Delivery Callbacks

```dart
final manager = NotificationManager(
  backend: backend,
  onDeliver: (n) => print('Delivered: ${n.title}'),
);
```

## API

| Class / Method | Description |
|--------|-------------|
| `Notification()` | Create a notification with title, body, channel, priority, payload, group, delivery status, and optional delivery time |
| `DeliveryStatus` | Enum for notification delivery status (pending, delivered, failed, retrying) |
| `NotificationChannel()` | Define a named channel with importance and sound settings |
| `NotificationStore.add()` | Add a notification to the in-memory store |
| `NotificationStore.get()` | Retrieve a notification by ID |
| `NotificationStore.remove()` | Remove a notification by ID |
| `NotificationStore.all()` | List all stored notifications |
| `NotificationStore.byChannel()` | Filter notifications by channel name |
| `NotificationStore.byPriority()` | Filter notifications by priority level |
| `NotificationStore.clear()` | Remove all notifications from the store |
| `NotificationStore.byGroup()` | Filter notifications by group ID |
| `NotificationStore.byStatus()` | Filter notifications by delivery status |
| `NotificationStore.removeWhere()` | Remove all notifications matching a predicate |
| `NotificationTemplate()` | Create a reusable template with `{{variable}}` placeholders |
| `NotificationTemplate.build()` | Build a notification by substituting variables into the template |
| `NotificationTemplate.placeholders` | Extract all placeholder names from the template |
| `RateLimiter()` | Create a per-channel rate limiter with a cooldown duration |
| `RateLimiter.allow()` | Check if a channel is allowed to deliver |
| `RateLimiter.reset()` | Clear cooldown tracking for a channel |
| `RateLimiter.resetAll()` | Clear all cooldown tracking |
| `NotificationScheduler.schedule()` | Schedule a notification for delivery |
| `NotificationScheduler.cancel()` | Cancel a pending notification |
| `NotificationScheduler.pending()` | List all pending notifications |
| `NotificationScheduler.delivered()` | List all delivered notifications |
| `NotificationScheduler.deliverDue()` | Deliver all notifications whose time has arrived |
| `NotificationScheduler.reschedule()` | Change the delivery time of a pending notification |
| `NotificationScheduler.scheduleRepeating()` | Schedule a notification to repeat at a fixed interval |
| `NotificationManager.schedule()` | Schedule via the high-level facade |
| `NotificationManager.deliverDue()` | Deliver due notifications through the backend |
| `NotificationManager.cancel()` | Cancel a pending notification |
| `MemoryDeliveryBackend` | In-memory backend for testing |

## Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/dart-notification-kit)

🐛 [Report issues](https://github.com/philiprehberger/dart-notification-kit/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/dart-notification-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
