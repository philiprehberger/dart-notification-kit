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
  });
}
