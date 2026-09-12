import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'features/calendar/controllers/calendar_controller.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Hive.initFlutter();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarController()..loadEvents(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CalendarScreen(),
      ),
    );
  }
}