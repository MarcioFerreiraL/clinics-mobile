import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notificações locais: alerta de queda de preço e lembrete de preparo.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'clinics_alerts',
      'Alertas do Clinics',
      channelDescription: 'Queda de preço e lembretes de preparo de exames',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> _init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> showPriceDrop({
    required int id,
    required String examName,
    required String newPrice,
  }) async {
    await _init();
    await _plugin.show(
      id: id,
      title: 'Preço caiu: $examName',
      body: 'Agora a partir de $newPrice. Toque para comparar.',
      notificationDetails: _details,
    );
  }

  /// Agenda o lembrete de preparo (ex.: jejum) para [when].
  Future<void> scheduleReminder({
    required int id,
    required String examName,
    required String preparation,
    required DateTime when,
  }) async {
    await _init();
    await _plugin.zonedSchedule(
      id: id,
      title: 'Preparo para $examName',
      body: preparation,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService());
