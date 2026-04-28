import 'package:philiprehberger_notification_kit/notification_kit.dart';
import 'package:test/test.dart';

void main() {
  group('Notification', () {
    test('creates with defaults', () {
      final n = Notification(title: 'Hello', body: 'World');

      expect(n.id, startsWith('notif_'));
      expect(n.title, equals('Hello'));
      expect(n.body, equals('World'));
      expect(n.priority, equals(Priority.normal));
      expect(n.channel, isNull);
      expect(n.payload, isEmpty);
      expect(n.deliverAt, isNull);
      expect(n.createdAt, isA<DateTime>());
    });

    test('creates with custom id and payload', () {
      final n = Notification(
        id: 'custom-1',
        title: 'Test',
        body: 'Body',
        payload: {'key': 'value'},
      );

      expect(n.id, equals('custom-1'));
      expect(n.payload['key'], equals('value'));
    });

    test('creates with channel and priority', () {
      final channel = NotificationChannel(name: 'alerts');
      final n = Notification(
        title: 'Alert',
        body: 'Something happened',
        channel: channel,
        priority: Priority.urgent,
      );

      expect(n.channel?.name, equals('alerts'));
      expect(n.priority, equals(Priority.urgent));
    });

    test('auto-generates unique ids', () {
      final a = Notification(title: 'A', body: 'a');
      final b = Notification(title: 'B', body: 'b');

      expect(a.id, isNot(equals(b.id)));
    });
  });

  group('Priority', () {
    test('has four values', () {
      expect(Priority.values, hasLength(4));
      expect(Priority.values, contains(Priority.low));
      expect(Priority.values, contains(Priority.normal));
      expect(Priority.values, contains(Priority.high));
      expect(Priority.values, contains(Priority.urgent));
    });
  });

  group('NotificationChannel', () {
    test('creates with defaults', () {
      final ch = NotificationChannel(name: 'general');

      expect(ch.name, equals('general'));
      expect(ch.importance, equals(Importance.normal));
      expect(ch.sound, isTrue);
      expect(ch.description, isNull);
    });

    test('creates with all fields', () {
      final ch = NotificationChannel(
        name: 'alerts',
        importance: Importance.high,
        sound: false,
        description: 'Critical alerts',
      );

      expect(ch.name, equals('alerts'));
      expect(ch.importance, equals(Importance.high));
      expect(ch.sound, isFalse);
      expect(ch.description, equals('Critical alerts'));
    });
  });

  group('Importance', () {
    test('has three values', () {
      expect(Importance.values, hasLength(3));
      expect(Importance.values, contains(Importance.low));
      expect(Importance.values, contains(Importance.normal));
      expect(Importance.values, contains(Importance.high));
    });
  });

  group('NotificationStore', () {
    late NotificationStore store;

    setUp(() {
      store = NotificationStore();
    });

    test('starts empty', () {
      expect(store.count, equals(0));
      expect(store.all(), isEmpty);
    });

    test('add and get', () {
      final n = Notification(id: 'n1', title: 'T', body: 'B');
      store.add(n);

      expect(store.count, equals(1));
      expect(store.get('n1')?.title, equals('T'));
    });

    test('get returns null for missing id', () {
      expect(store.get('missing'), isNull);
    });

    test('remove existing notification', () {
      final n = Notification(id: 'n1', title: 'T', body: 'B');
      store.add(n);

      expect(store.remove('n1'), isTrue);
      expect(store.count, equals(0));
      expect(store.get('n1'), isNull);
    });

    test('remove returns false for missing id', () {
      expect(store.remove('missing'), isFalse);
    });

    test('all returns all notifications', () {
      store.add(Notification(id: 'a', title: 'A', body: 'a'));
      store.add(Notification(id: 'b', title: 'B', body: 'b'));

      expect(store.all(), hasLength(2));
    });

    test('byChannel filters correctly', () {
      final ch = NotificationChannel(name: 'alerts');
      store.add(Notification(id: 'a', title: 'A', body: 'a', channel: ch));
      store.add(Notification(id: 'b', title: 'B', body: 'b'));

      expect(store.byChannel('alerts'), hasLength(1));
      expect(store.byChannel('alerts').first.id, equals('a'));
      expect(store.byChannel('other'), isEmpty);
    });

    test('byPriority filters correctly', () {
      store.add(Notification(
        id: 'u',
        title: 'Urgent',
        body: 'b',
        priority: Priority.urgent,
      ));
      store.add(Notification(id: 'n', title: 'Normal', body: 'b'));

      expect(store.byPriority(Priority.urgent), hasLength(1));
      expect(store.byPriority(Priority.normal), hasLength(1));
      expect(store.byPriority(Priority.low), isEmpty);
    });

    test('clear removes all', () {
      store.add(Notification(id: 'a', title: 'A', body: 'a'));
      store.add(Notification(id: 'b', title: 'B', body: 'b'));
      store.clear();

      expect(store.count, equals(0));
      expect(store.all(), isEmpty);
    });
  });

  group('Notification groups', () {
    test('byGroup filters by groupId', () {
      final store = NotificationStore();
      store.add(Notification(title: 'A', body: 'a', groupId: 'g1'));
      store.add(Notification(title: 'B', body: 'b', groupId: 'g1'));
      store.add(Notification(title: 'C', body: 'c', groupId: 'g2'));
      expect(store.byGroup('g1').length, equals(2));
    });
  });

  group('Delivery status', () {
    test('default status is pending', () {
      final n = Notification(title: 'Test', body: 'test');
      expect(n.deliveryStatus, equals(DeliveryStatus.pending));
    });

    test('byStatus filters correctly', () {
      final store = NotificationStore();
      final n1 = Notification(title: 'A', body: 'a');
      final n2 = Notification(title: 'B', body: 'b');
      n2.deliveryStatus = DeliveryStatus.delivered;
      store.add(n1);
      store.add(n2);
      expect(store.byStatus(DeliveryStatus.pending).length, equals(1));
      expect(store.byStatus(DeliveryStatus.delivered).length, equals(1));
    });
  });

  group('Repeating notifications', () {
    test('scheduleRepeating creates multiple notifications', () {
      final scheduler = NotificationScheduler();
      final ids = scheduler.scheduleRepeating(
        Notification(title: 'Reminder', body: 'test', deliverAt: DateTime.now()),
        interval: const Duration(hours: 1),
        count: 5,
      );
      expect(ids.length, equals(5));
      expect(scheduler.pending().length, equals(5));
    });

    test('scheduleRepeating respects endAt', () {
      final scheduler = NotificationScheduler();
      final now = DateTime.now();
      final ids = scheduler.scheduleRepeating(
        Notification(title: 'Test', body: 'test', deliverAt: now),
        interval: const Duration(hours: 1),
        count: 100,
        endAt: now.add(const Duration(hours: 3)),
      );
      expect(ids.length, lessThanOrEqualTo(4));
    });
  });

  group('NotificationScheduler', () {
    late NotificationScheduler scheduler;

    setUp(() {
      scheduler = NotificationScheduler();
    });

    test('schedule with deliverAt adds to pending', () {
      final future = DateTime.now().add(Duration(hours: 1));
      final n = Notification(title: 'T', body: 'B', deliverAt: future);
      scheduler.schedule(n);

      expect(scheduler.pending(), hasLength(1));
      expect(scheduler.delivered(), isEmpty);
    });

    test('schedule without deliverAt delivers immediately', () {
      final n = Notification(title: 'T', body: 'B');
      scheduler.schedule(n);

      expect(scheduler.pending(), isEmpty);
      expect(scheduler.delivered(), hasLength(1));
    });

    test('cancel removes from pending', () {
      final future = DateTime.now().add(Duration(hours: 1));
      final n = Notification(id: 'x', title: 'T', body: 'B', deliverAt: future);
      scheduler.schedule(n);

      expect(scheduler.cancel('x'), isTrue);
      expect(scheduler.pending(), isEmpty);
    });

    test('cancel returns false for unknown id', () {
      expect(scheduler.cancel('missing'), isFalse);
    });

    test('deliverDue moves due notifications to delivered', () {
      final past = DateTime.now().subtract(Duration(hours: 1));
      final future = DateTime.now().add(Duration(hours: 1));

      scheduler.schedule(Notification(
        id: 'past',
        title: 'Past',
        body: 'B',
        deliverAt: past,
      ));
      scheduler.schedule(Notification(
        id: 'future',
        title: 'Future',
        body: 'B',
        deliverAt: future,
      ));

      final due = scheduler.deliverDue();

      expect(due, hasLength(1));
      expect(due.first.id, equals('past'));
      expect(scheduler.pending(), hasLength(1));
      expect(scheduler.delivered(), hasLength(1));
    });

    test('reschedule changes delivery time', () {
      final original = DateTime.now().add(Duration(hours: 1));
      final updated = DateTime.now().add(Duration(hours: 2));
      final n = Notification(id: 'r', title: 'T', body: 'B', deliverAt: original);
      scheduler.schedule(n);

      expect(scheduler.reschedule('r', updated), isTrue);

      final pending = scheduler.pending();
      expect(pending, hasLength(1));
      expect(pending.first.deliverAt, equals(updated));
    });

    test('reschedule returns false for unknown id', () {
      expect(scheduler.reschedule('missing', DateTime.now()), isFalse);
    });

    test('clear removes all pending and delivered', () {
      scheduler.schedule(Notification(title: 'Immediate', body: 'B'));
      scheduler.schedule(Notification(
        title: 'Later',
        body: 'B',
        deliverAt: DateTime.now().add(Duration(hours: 1)),
      ));
      scheduler.clear();

      expect(scheduler.pending(), isEmpty);
      expect(scheduler.delivered(), isEmpty);
    });
  });

  group('MemoryDeliveryBackend', () {
    test('captures delivered notifications', () async {
      final backend = MemoryDeliveryBackend();
      final n = Notification(title: 'Test', body: 'Body');

      await backend.deliver(n);

      expect(backend.deliveries, hasLength(1));
      expect(backend.deliveries.first.title, equals('Test'));
    });

    test('captures multiple deliveries in order', () async {
      final backend = MemoryDeliveryBackend();

      await backend.deliver(Notification(id: 'a', title: 'A', body: 'a'));
      await backend.deliver(Notification(id: 'b', title: 'B', body: 'b'));

      expect(backend.deliveries, hasLength(2));
      expect(backend.deliveries[0].id, equals('a'));
      expect(backend.deliveries[1].id, equals('b'));
    });
  });

  group('NotificationTemplate', () {
    test('build substitutes variables in title and body', () {
      final template = NotificationTemplate(
        titleTemplate: 'Hello {{name}}',
        bodyTemplate: 'Your order {{orderId}} is {{status}}',
      );

      final n = template.build({
        'name': 'Alice',
        'orderId': '42',
        'status': 'shipped',
      });

      expect(n.title, equals('Hello Alice'));
      expect(n.body, equals('Your order 42 is shipped'));
    });

    test('placeholders extracts all placeholder names', () {
      final template = NotificationTemplate(
        titleTemplate: '{{greeting}} {{name}}',
        bodyTemplate: 'Your {{item}} is {{status}}',
      );

      final names = template.placeholders;
      expect(names, containsAll(['greeting', 'name', 'item', 'status']));
      expect(names, hasLength(4));
    });

    test('build leaves missing variables as-is', () {
      final template = NotificationTemplate(
        titleTemplate: 'Hello {{name}}',
        bodyTemplate: 'Order {{orderId}}',
      );

      final n = template.build({'name': 'Bob'});

      expect(n.title, equals('Hello Bob'));
      expect(n.body, equals('Order {{orderId}}'));
    });

    test('build applies channel and priority', () {
      final channel = NotificationChannel(name: 'alerts');
      final template = NotificationTemplate(
        titleTemplate: 'Alert',
        bodyTemplate: 'Something happened',
        channel: channel,
        priority: Priority.high,
      );

      final n = template.build({});

      expect(n.channel?.name, equals('alerts'));
      expect(n.priority, equals(Priority.high));
    });

    test('placeholders deduplicates across templates', () {
      final template = NotificationTemplate(
        titleTemplate: '{{name}}',
        bodyTemplate: 'Hello {{name}}',
      );

      expect(template.placeholders, hasLength(1));
      expect(template.placeholders, contains('name'));
    });
  });

  group('RateLimiter', () {
    test('allow returns true on first call', () {
      final limiter = RateLimiter(cooldown: Duration(seconds: 10));
      expect(limiter.allow('alerts'), isTrue);
    });

    test('allow returns false within cooldown', () {
      final limiter = RateLimiter(cooldown: Duration(seconds: 10));
      limiter.allow('alerts');
      expect(limiter.allow('alerts'), isFalse);
    });

    test('allow returns true for different channels', () {
      final limiter = RateLimiter(cooldown: Duration(seconds: 10));
      limiter.allow('alerts');
      expect(limiter.allow('updates'), isTrue);
    });

    test('reset clears tracking for a channel', () {
      final limiter = RateLimiter(cooldown: Duration(seconds: 10));
      limiter.allow('alerts');
      limiter.reset('alerts');
      expect(limiter.allow('alerts'), isTrue);
    });

    test('resetAll clears all tracking', () {
      final limiter = RateLimiter(cooldown: Duration(seconds: 10));
      limiter.allow('alerts');
      limiter.allow('updates');
      limiter.resetAll();
      expect(limiter.allow('alerts'), isTrue);
      expect(limiter.allow('updates'), isTrue);
    });

    test('cooldown exposes duration', () {
      final limiter = RateLimiter(cooldown: Duration(seconds: 5));
      expect(limiter.cooldown, equals(Duration(seconds: 5)));
    });
  });

  group('NotificationStore removeWhere', () {
    test('removeWhere removes matching notifications', () {
      final store = NotificationStore();
      store.add(Notification(id: 'a', title: 'Low', body: 'b', priority: Priority.low));
      store.add(Notification(id: 'b', title: 'High', body: 'b', priority: Priority.high));
      store.add(Notification(id: 'c', title: 'Low2', body: 'b', priority: Priority.low));

      final removed = store.removeWhere((n) => n.priority == Priority.low);

      expect(removed, equals(2));
      expect(store.count, equals(1));
      expect(store.get('b')?.title, equals('High'));
    });

    test('removeWhere returns 0 when nothing matches', () {
      final store = NotificationStore();
      store.add(Notification(id: 'a', title: 'A', body: 'a'));

      final removed = store.removeWhere((n) => n.priority == Priority.urgent);

      expect(removed, equals(0));
      expect(store.count, equals(1));
    });
  });

  group('NotificationManager', () {
    late MemoryDeliveryBackend backend;
    late NotificationManager manager;

    setUp(() {
      backend = MemoryDeliveryBackend();
      manager = NotificationManager(backend: backend);
    });

    test('schedule and deliver due notifications', () async {
      final past = DateTime.now().subtract(Duration(hours: 1));
      manager.schedule(Notification(
        id: 'due',
        title: 'Due',
        body: 'B',
        deliverAt: past,
      ));

      final delivered = await manager.deliverDue();

      expect(delivered, hasLength(1));
      expect(delivered.first.id, equals('due'));
      expect(backend.deliveries, hasLength(1));
    });

    test('cancel prevents delivery', () async {
      final future = DateTime.now().add(Duration(hours: 1));
      manager.schedule(Notification(
        id: 'cancel-me',
        title: 'T',
        body: 'B',
        deliverAt: future,
      ));

      expect(manager.cancel('cancel-me'), isTrue);
      expect(manager.pending(), isEmpty);
    });

    test('pending and delivered track state', () async {
      manager.schedule(Notification(title: 'Immediate', body: 'B'));
      manager.schedule(Notification(
        title: 'Later',
        body: 'B',
        deliverAt: DateTime.now().add(Duration(hours: 1)),
      ));

      expect(manager.pending(), hasLength(1));
      expect(manager.delivered(), hasLength(1));
    });

    test('onDeliver callback is invoked', () async {
      final callbackIds = <String>[];
      manager.onDeliver = (n) => callbackIds.add(n.id);

      final past = DateTime.now().subtract(Duration(hours: 1));
      manager.schedule(Notification(
        id: 'cb-1',
        title: 'T',
        body: 'B',
        deliverAt: past,
      ));

      await manager.deliverDue();

      expect(callbackIds, equals(['cb-1']));
    });

    test('deliverDue with no due notifications returns empty', () async {
      manager.schedule(Notification(
        title: 'Future',
        body: 'B',
        deliverAt: DateTime.now().add(Duration(hours: 1)),
      ));

      final delivered = await manager.deliverDue();

      expect(delivered, isEmpty);
      expect(backend.deliveries, isEmpty);
    });

    test('rate limiter blocks rapid delivery on same channel', () async {
      final limiter = RateLimiter(cooldown: Duration(seconds: 60));
      final rateLimitedBackend = MemoryDeliveryBackend();
      final rateLimitedManager = NotificationManager(
        backend: rateLimitedBackend,
        rateLimiter: limiter,
      );

      final channel = NotificationChannel(name: 'alerts');
      final past = DateTime.now().subtract(Duration(hours: 1));

      rateLimitedManager.schedule(Notification(
        id: 'r1',
        title: 'First',
        body: 'B',
        channel: channel,
        deliverAt: past,
      ));
      rateLimitedManager.schedule(Notification(
        id: 'r2',
        title: 'Second',
        body: 'B',
        channel: channel,
        deliverAt: past,
      ));

      final delivered = await rateLimitedManager.deliverDue();

      expect(delivered, hasLength(1));
      expect(delivered.first.id, equals('r1'));
      expect(rateLimitedBackend.deliveries, hasLength(1));
    });
  });

  group('NotificationStore.search', () {
    final base = DateTime(2026, 4, 1, 12, 0);
    final alerts = NotificationChannel(name: 'alerts');
    final updates = NotificationChannel(name: 'updates');

    NotificationStore buildStore() {
      final store = NotificationStore();
      store.add(Notification(
        id: 's1',
        title: 'Server Down',
        body: 'Production is unreachable',
        channel: alerts,
        priority: Priority.high,
        deliverAt: base,
      ));
      store.add(Notification(
        id: 's2',
        title: 'Welcome',
        body: 'Thanks for signing up!',
        channel: updates,
        priority: Priority.normal,
        deliverAt: base.add(Duration(hours: 1)),
      ));
      store.add(Notification(
        id: 's3',
        title: 'Critical Alert',
        body: 'Database server overheated',
        channel: alerts,
        priority: Priority.urgent,
        deliverAt: base.add(Duration(hours: 2)),
      ));
      store.add(Notification(
        id: 's4',
        title: 'Newsletter',
        body: 'Monthly digest is ready',
        channel: updates,
        priority: Priority.low,
        deliverAt: base.add(Duration(hours: 3)),
      ));
      return store;
    }

    test('search by query is case-insensitive across title and body', () {
      final store = buildStore();
      final results = store.search(query: 'SERVER');
      expect(results.map((n) => n.id), containsAll(['s1', 's3']));
      expect(results, hasLength(2));
    });

    test('search by query matches body only', () {
      final store = buildStore();
      final results = store.search(query: 'digest');
      expect(results, hasLength(1));
      expect(results.first.id, equals('s4'));
    });

    test('search by priority filters exact match', () {
      final store = buildStore();
      final results = store.search(priority: Priority.urgent);
      expect(results, hasLength(1));
      expect(results.first.id, equals('s3'));
    });

    test('search by channel filters by channel name', () {
      final store = buildStore();
      final results = store.search(channel: 'alerts');
      expect(results.map((n) => n.id), containsAll(['s1', 's3']));
      expect(results, hasLength(2));
    });

    test('search by date range with after and before', () {
      final store = buildStore();
      final results = store.search(
        after: base.add(Duration(minutes: 30)),
        before: base.add(Duration(hours: 2, minutes: 30)),
      );
      expect(results.map((n) => n.id), containsAll(['s2', 's3']));
      expect(results, hasLength(2));
    });

    test('search after is inclusive', () {
      final store = buildStore();
      final results = store.search(after: base);
      expect(results, hasLength(4));
    });

    test('search before is inclusive', () {
      final store = buildStore();
      final results = store.search(before: base);
      expect(results, hasLength(1));
      expect(results.first.id, equals('s1'));
    });

    test('search combines multiple filters with AND', () {
      final store = buildStore();
      final results = store.search(
        query: 'server',
        priority: Priority.urgent,
        channel: 'alerts',
        after: base.add(Duration(hours: 1)),
        before: base.add(Duration(hours: 3)),
      );
      expect(results, hasLength(1));
      expect(results.first.id, equals('s3'));
    });

    test('search with no filters returns everything', () {
      final store = buildStore();
      expect(store.search(), hasLength(4));
    });

    test('search returns empty when no notification matches all filters', () {
      final store = buildStore();
      final results = store.search(
        query: 'server',
        priority: Priority.low,
      );
      expect(results, isEmpty);
    });

    test('search with date filter excludes notifications without deliverAt', () {
      final store = NotificationStore();
      store.add(Notification(id: 'no-time', title: 'Hello', body: 'world'));
      store.add(Notification(
        id: 'with-time',
        title: 'Hello',
        body: 'world',
        deliverAt: base,
      ));

      final results = store.search(after: base.subtract(Duration(hours: 1)));
      expect(results, hasLength(1));
      expect(results.first.id, equals('with-time'));
    });
  });

  group('LoggingDeliveryBackend', () {
    test('sink fires before inner.deliver is called', () async {
      final inner = MemoryDeliveryBackend();
      final logged = <String>[];
      final backend = LoggingDeliveryBackend(
        inner: inner,
        sink: (n) => logged.add(n.id),
      );

      await backend.deliver(Notification(id: 'a', title: 'A', body: 'a'));

      expect(logged, equals(['a']));
      expect(inner.deliveries, hasLength(1));
      expect(inner.deliveries.first.id, equals('a'));
    });

    test('forwards multiple notifications in order', () async {
      final inner = MemoryDeliveryBackend();
      final logged = <String>[];
      final backend = LoggingDeliveryBackend(
        inner: inner,
        sink: (n) => logged.add(n.id),
      );

      await backend.deliver(Notification(id: 'a', title: 'A', body: 'a'));
      await backend.deliver(Notification(id: 'b', title: 'B', body: 'b'));
      await backend.deliver(Notification(id: 'c', title: 'C', body: 'c'));

      expect(logged, equals(['a', 'b', 'c']));
      expect(inner.deliveries.map((n) => n.id), equals(['a', 'b', 'c']));
    });

    test('integrates with NotificationManager', () async {
      final inner = MemoryDeliveryBackend();
      final logged = <Notification>[];
      final backend = LoggingDeliveryBackend(
        inner: inner,
        sink: logged.add,
      );
      final manager = NotificationManager(backend: backend);

      final past = DateTime.now().subtract(Duration(hours: 1));
      manager.schedule(Notification(
        id: 'm1',
        title: 'Test',
        body: 'B',
        deliverAt: past,
      ));

      await manager.deliverDue();

      expect(logged, hasLength(1));
      expect(logged.first.id, equals('m1'));
      expect(inner.deliveries, hasLength(1));
    });
  });
}
