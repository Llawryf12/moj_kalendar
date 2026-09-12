import 'package:flutter/material.dart';
import 'package:moj_kalendar/services/notification_service.dart';
import 'package:moj_kalendar/services/widget_service.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/models/event_model.dart';
import 'package:home_widget/home_widget.dart';

class CalendarController extends ChangeNotifier {
  final HiveService _db = HiveService();

  List<Event> events = [];
  DateTime selectedDay = DateTime.now();

  // 📥 Učitavanje evenata
  Future<void> loadEvents() async {
    events = await _db.getEvents();
    notifyListeners();
  }

  // ➕ Dodavanje novog eventa
  Future<void> addEvent(Event event) async {
    await _db.saveEvent(event);
    await loadEvents();

    // Zakazivanje notifikacije za novi event
    await NotificationService.scheduleEventNotification(
      id: event.id,
      title: event.title,
      body: event.description,
      eventDate: event.dateTime,
      colorValue: event.colorValue, // Proslijedi boju ako je definirana
    );

    await _updateWidget();
    await updateHomeWidget();
  }

  // ✏️ Ažuriranje postojećeg eventa
  Future<void> updateEvent(Event event) async {
    // 1. Obriši staru notifikaciju (koristeći hashCode od String ID-a)
    await NotificationService.cancelNotification(event.id.hashCode);

    // 2. Spremi izmjene u Hive bazu
    await _db.saveEvent(event);
    await loadEvents();

    // 3. Zakaži novu notifikaciju s novim podacima
    await NotificationService.scheduleEventNotification(
      id: event.id,
      title: event.title,
      body: event.description,
      eventDate: event.dateTime,
      colorValue: event.colorValue, // Proslijedi boju ako je definirana
    );

    await _updateWidget();
    await updateHomeWidget();
  }

  // 🗑️ Brisanje eventa
  Future<void> deleteEvent(String id) async {
    // 1. Cancel notification pomoću hashCode-a ID-a
    await NotificationService.cancelNotification(id.hashCode);

    // 2. Brisanje iz baze i ponovno učitavanje liste
    await _db.deleteEvent(id);
    await loadEvents();

    // 3. Osvježi widget
    await _updateWidget();
    await updateHomeWidget();
  }

  // 📅 Postavljanje selektiranog dana
  void setSelectedDay(DateTime day) {
    selectedDay = day;
    notifyListeners();
  }

  // 🔍 Dohvaćanje evenata za određeni dan
  List<Event> getEventsForDay(DateTime day) {
    return events.where((e) =>
        e.dateTime.year == day.year &&
        e.dateTime.month == day.month &&
        e.dateTime.day == day.day).toList();
  }

  // 🛠️ Privatna pomoćna funkcija za ažuriranje Home Screen Widgeta
  Future<void> _updateWidget() async {
    await WidgetService.updateList(
      events.map((e) =>
        "${e.title} ${e.dateTime.hour.toString().padLeft(2, '0')}:${e.dateTime.minute.toString().padLeft(2, '0')}"
      ).toList(),
    );
  }

  Future<void> updateHomeWidget() async {
  final today = DateTime.now();

  final monthEvents = events.where((e) =>
    e.dateTime.year == today.year &&
    e.dateTime.month == today.month
  ).toList();

  final data = monthEvents.map((e) {
    return "${e.dateTime.year},${e.dateTime.month},${e.dateTime.day}|"
           "${e.dateTime.hour}:${e.dateTime.minute}|"
           "${e.title}|"
           "${e.colorValue ?? 0xFF2196F3}";
  }).toList();

  await HomeWidget.saveWidgetData('events', data.join(';;'));

  await HomeWidget.saveWidgetData('month', "${today.year},${today.month}");

  await HomeWidget.updateWidget(
    name: 'CalendarWidget',
    androidName: 'CalendarWidget',
  );
}
}