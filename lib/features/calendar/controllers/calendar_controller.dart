import 'package:flutter/material.dart';
import 'package:moj_kalendar/services/notification_service.dart';
import 'package:moj_kalendar/services/widget_service.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/models/event_model.dart';


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

 Future<void> _updateWidget() async {
  await WidgetService.updateCalendarWidget(events);
}

 
}