import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/calendar_controller.dart';
import '../../../core/models/event_model.dart';
import 'package:uuid/uuid.dart';
import '../../../services/notification_service.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Color selectedColor = Colors.blue; // Početna boja

  final List<Color> colors = [
    Colors.blue, Colors.red, Colors.green, 
    Colors.orange, Colors.purple, Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalendarController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Dodaj event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Naslov")),
            TextField(controller: descController, decoration: InputDecoration(labelText: "Opis")),
            SizedBox(height: 20),
            
            Text("Odaberi boju:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // --- RED ZA ODABIR BOJE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(backgroundColor: color, radius: 15),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Text("Datum: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}"),
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedTime = await showTimePicker(context: context, initialTime: selectedTime);
                if (pickedTime != null) setState(() => selectedTime = pickedTime);
              },
              child: Text("Vrijeme: ${selectedTime.format(context)}"),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () async {
                final eventDateTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  selectedTime.hour, selectedTime.minute,
                );

                final event = Event(
                  id: Uuid().v4(),
                  title: titleController.text,
                  description: descController.text,
                  dateTime: eventDateTime,
                  colorValue: selectedColor.value, // SPREMANJE BOJE
                );

                await controller.addEvent(event);
                Navigator.pop(context);
              },
              child: Text("Spremi"),
            )
          ],
        ),
      ),
    );
  }
}