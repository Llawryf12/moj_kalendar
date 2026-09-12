import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  
  // 🚩 Dodajemo zastavicu da pratimo stanje
  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      print("🔔 Inicijalizacija notifikacija započeta...");
      tz.initializeTimeZones();
      
      const android = AndroidInitializationSettings('app_icon'); 
      const settings = InitializationSettings(android: android);
      
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          print("Notifikacija kliknuta!");
        },
      );

      _isInitialized = true; // ✅ Označavamo da je spremno
      print("🔔 Plugin uspješno inicijaliziran!");
    } catch (e) {
      _isInitialized = false;
      print("❌ KRITIČNA GREŠKA U INIT: $e");
    }
  }

  static Future<void> scheduleEventNotification({
    required String id,
    required String title,
    required String body,
    required DateTime eventDate,
    int? colorValue,
  }) async {
    if (!_isInitialized) {
      print("⚠️ Ne mogu zakazati: Servis nije inicijaliziran.");
      return;
    }

    final scheduledDate = eventDate.subtract(const Duration(days: 1));
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'events_channel',
      'Events',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await _notifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      tzDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    // 🛡️ Safe check koristeći našu varijablu
    if (!_isInitialized) {
      print("⚠️ Preskačem cancel: Plugin nije inicijaliziran.");
      return;
    }

    try {
      await _notifications.cancel(id);
      print("✅ Notifikacija $id uspješno otkazana.");
    } catch (e) {
      print("⚠️ Greška pri otkazivanju: $e");
    }
  }
}