import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';

class HiveService {
  static const String boxName = "events";

  Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  Future<void> saveEvent(Event event) async {
    final box = await _openBox();
    await box.put(event.id, {
      'title': event.title,
      'description': event.description,
      'dateTime': event.dateTime.toIso8601String(),
      'colorValue': event.colorValue, // SPREMANJE BOJE
    });
  }

  Future<List<Event>> getEvents() async {
    final box = await _openBox();

    return box.keys.map((key) {
      final e = box.get(key);

      return Event(
        id: key,
        title: e['title'],
        description: e['description'],
        dateTime: DateTime.parse(e['dateTime']),
        colorValue: e['colorValue'], // UČITAVANJE BOJE
      );
    }).toList();
  }

  Future<void> deleteEvent(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}