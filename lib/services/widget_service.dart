import 'package:home_widget/home_widget.dart';

class WidgetService {

  static Future<void> update(String text) async {
    await HomeWidget.saveWidgetData('event', text);
    await HomeWidget.updateWidget(
      name: 'MyWidgetProvider',
      androidName: 'MyWidgetProvider',
    );
  }

  static Future<void> updateList(List<String> events) async {
    await HomeWidget.saveWidgetData('events', events.join('|'));
    await HomeWidget.updateWidget(
      name: 'MyWidgetProvider',
      androidName: 'MyWidgetProvider',
    );
  }
}

 