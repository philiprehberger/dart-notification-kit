// ignore_for_file: unused_local_variable

import 'package:philiprehberger_notification_kit/notification_kit.dart';

Future<void> main() async {
  // Create a delivery backend
  final backend = MemoryDeliveryBackend();

  // Create a notification manager
  final manager = NotificationManager(
    backend: backend,
    onDeliver: (n) => print('Delivered: ${n.title}'),
  );

  // Define channels
  final alerts = NotificationChannel(
    name: 'alerts',
    importance: Importance.high,
    sound: true,
    description: 'Critical alerts',
  );

  final updates = NotificationChannel(
    name: 'updates',
    importance: Importance.normal,
    sound: false,
  );

  // Schedule an immediate notification
  manager.schedule(Notification(
    title: 'Welcome',
    body: 'Thanks for signing up!',
    channel: updates,
  ));

  // Schedule a future notification
  final reminderTime = DateTime.now().add(Duration(hours: 1));
  manager.schedule(Notification(
    id: 'reminder-1',
    title: 'Meeting Reminder',
    body: 'Team standup in 15 minutes',
    channel: alerts,
    priority: Priority.high,
    payload: {'meeting_id': '42', 'room': 'A3'},
    deliverAt: reminderTime,
  ));

  // Check pending and delivered
  print('Pending: ${manager.pending().length}');
  print('Delivered: ${manager.delivered().length}');

  // Deliver all due notifications
  final delivered = await manager.deliverDue();
  print('Just delivered: ${delivered.length}');

  // Cancel a scheduled notification
  manager.cancel('reminder-1');

  // Use the store for indexed access
  final store = NotificationStore();

  store.add(Notification(
    id: 'n1',
    title: 'Low priority',
    body: 'FYI',
    priority: Priority.low,
    channel: updates,
  ));

  store.add(Notification(
    id: 'n2',
    title: 'Urgent alert',
    body: 'Server down!',
    priority: Priority.urgent,
    channel: alerts,
  ));

  // Query by channel or priority
  final alertNotifs = store.byChannel('alerts');
  print('Alerts: ${alertNotifs.length}');

  final urgentNotifs = store.byPriority(Priority.urgent);
  print('Urgent: ${urgentNotifs.length}');

  print('Total in store: ${store.count}');

  // Use the scheduler directly
  final scheduler = NotificationScheduler();
  final deliverTime = DateTime.now().subtract(Duration(minutes: 5));

  scheduler.schedule(Notification(
    id: 'past-1',
    title: 'Overdue',
    body: 'This was due 5 minutes ago',
    deliverAt: deliverTime,
  ));

  final due = scheduler.deliverDue();
  print('Delivered overdue: ${due.length}');

  // Notification templates with variable substitution
  final welcomeTemplate = NotificationTemplate(
    titleTemplate: 'Welcome {{name}}!',
    bodyTemplate: 'Your account {{accountId}} is ready.',
    channel: updates,
    priority: Priority.normal,
  );

  print('Placeholders: ${welcomeTemplate.placeholders}');

  final welcomeNotif = welcomeTemplate.build({
    'name': 'Alice',
    'accountId': 'ACC-123',
  });
  print('Template result: ${welcomeNotif.title} — ${welcomeNotif.body}');

  // Rate limiting for per-channel cooldowns
  final limiter = RateLimiter(cooldown: Duration(seconds: 30));
  final rateLimitedManager = NotificationManager(
    backend: backend,
    rateLimiter: limiter,
  );

  final pastTime = DateTime.now().subtract(Duration(minutes: 1));
  rateLimitedManager.schedule(Notification(
    title: 'Alert 1',
    body: 'First alert',
    channel: alerts,
    deliverAt: pastTime,
  ));
  rateLimitedManager.schedule(Notification(
    title: 'Alert 2',
    body: 'Second alert (will be rate limited)',
    channel: alerts,
    deliverAt: pastTime,
  ));

  final rateLimited = await rateLimitedManager.deliverDue();
  print('Delivered with rate limiting: ${rateLimited.length}'); // 1

  // Bulk removal with removeWhere
  store.add(Notification(id: 'n3', title: 'Old', body: 'old', priority: Priority.low));
  final removed = store.removeWhere((n) => n.priority == Priority.low);
  print('Removed $removed low-priority notifications');
}
