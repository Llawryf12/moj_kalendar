import 'package:home_widget/home_widget.dart';
import '../core/models/event_model.dart';

class WidgetService {
  static Future<void> updateCalendarWidget(List<Event> events) async {
    final now = DateTime.now();

    // Uzimamo samo događaje iz trenutnog mjeseca
    final monthEvents = events.where((event) {
      return event.dateTime.year == now.year &&
          event.dateTime.month == now.month;
    }).toList();

    // Format:
    // godina,mjesec,dan|sat:minuta|naslov|boja
    final widgetEvents = monthEvents.map((event) {
      final hour = event.dateTime.hour.toString().padLeft(2, '0');
      final minute = event.dateTime.minute.toString().padLeft(2, '0');

      return '${event.dateTime.year},'
          '${event.dateTime.month},'
          '${event.dateTime.day}|'
          '$hour:$minute|'
          '${event.title}|'
          '${event.colorValue ?? 0xFF2196F3}';
    }).toList();

    await HomeWidget.saveWidgetData(
      'events',
      widgetEvents.join(';;'),
    );

    await HomeWidget.saveWidgetData(
      'year',
      now.year,
    );

    await HomeWidget.saveWidgetData(
      'month',
      now.month,
    );

    await HomeWidget.updateWidget(
      androidName: 'CalendarWidget',
    );
  }
}