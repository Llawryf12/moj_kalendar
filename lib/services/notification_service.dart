import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      print("🔔 Inicijalizacija notifikacija započeta...");
      
      // 1. Inicijalizacija vremenskih zona
      tz.initializeTimeZones();
      
      // Postavljamo lokalnu vremensku zonu na Hrvatsku/Europu
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Zagreb'));
      } catch (e) {
        print("⚠️ Nije moguće postaviti zadanu vremensku zonu: $e");
      }

      // 2. Postavljanje ikone (koristi standardnu ic_launcher ikonu aplikacije)
      const android = AndroidInitializationSettings('@mipmap/ic_launcher'); 
      const settings = InitializationSettings(android: android);
      
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          print("Notifikacija kliknuta!");
        },
      );

      // 3. Traženje dozvola za Android 13+ (API 33+) i točne alarme
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      _isInitialized = true;
      print("🔔 NotificationService uspješno inicijaliziran!");
    } catch (e) {
      _isInitialized = false;
      print("❌ KRITIČNA GREŠKA U INIT: $e");
    }
  }

  /// Zakazuje notifikaciju 30 MINUTA prije samog događaja
  static Future<void> scheduleEventNotification({
    required String id,
    required String title,
    required String body,
    required DateTime eventDate, // Vrijeme i datum kada događaj počinje
  }) async {
    if (!_isInitialized) {
      print("⚠️ Ne mogu zakazati: Servis nije inicijaliziran.");
      return;
    }

    // 🎯 Izračunavamo vrijeme: točno 30 MINUTA prije događaja
    final scheduledDate = eventDate.subtract(const Duration(minutes: 30));

    // Ako je to vrijeme već prošlo (npr. događaj je za 10 minuta), preskačemo
    if (scheduledDate.isBefore(DateTime.now())) {
      print("⚠️ Vrijeme za podsjetnik (30 min prije) je već prošlo!");
      return;
    }

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'events_channel',
      'Podsjetnici događaja',
      channelDescription: 'Kanal za obavijesti 30 minuta prije događaja',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    final notificationId = id.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      tzDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Notifikacija zakazana za: $tzDate (ID: $notificationId)");
  }

  static Future<void> cancelNotification(String id) async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancel(id.hashCode);
      print("✅ Notifikacija otkazana za ID: $id");
    } catch (e) {
      print("⚠️ Greška pri otkazivanju: $e");
    }
  }
}