import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import 'add_event_screen.dart';
import 'edit_event_screen.dart';
import '../../../core/models/event_model.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalendarController>(context);

    final eventsForDay = controller.getEventsForDay(controller.selectedDay);

    return Scaffold(
      appBar: AppBar(title: Text("Kalendar")),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: controller.selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, controller.selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              controller.setSelectedDay(selectedDay);
            },
            eventLoader: (day) {
              return controller.getEventsForDay(day);
            },
            rowHeight: 52,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;

                return Wrap(
                  alignment: WrapAlignment.center,
                  children: events.map((event) {
                    return Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(event.colorValue ?? Colors.blue.value),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: eventsForDay.isEmpty
                ? const Center(child: Text("Nema događaja za ovaj dan."))
                : Column(
                    children: [
                      // 🔹 NASLOV SEKCIJE
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Moji eventi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // 🔹 LISTA
                      Expanded(
                        child: ListView.builder(
                          itemCount: eventsForDay.length,
                          itemBuilder: (context, index) {
                            final e = eventsForDay[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditEventScreen(event: e),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // 🟦 BOJA TRAKA
                                    Container(
                                      width: 4,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Color(e.colorValue ?? Colors.blue.value),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // 🕒 VRIJEME
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${e.dateTime.hour.toString().padLeft(2, '0')}:${e.dateTime.minute.toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${e.dateTime.day}.${e.dateTime.month}",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 12),

                                    // 📝 NASLOV + OPIS
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (e.description.isNotEmpty)
                                            Text(
                                              e.description,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEventScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}