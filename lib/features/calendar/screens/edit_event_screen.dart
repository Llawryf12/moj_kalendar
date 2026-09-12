import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/calendar_controller.dart';
import '../../../core/models/event_model.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  EditEventScreen({required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late Color selectedColor; // Novo polje za boju

  // Lista ponuđenih boja
  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    descController = TextEditingController(text: widget.event.description);
    selectedDate = widget.event.dateTime;
    selectedTime = TimeOfDay(
      hour: widget.event.dateTime.hour,
      minute: widget.event.dateTime.minute,
    );
    // Ako model ima colorValue, koristi ga, inače default na plavu
    selectedColor = Color(widget.event.colorValue ?? Colors.blue.value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalendarController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Uredi event"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, controller),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Naslov", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Opis", border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            
            Text("Odaberi boju:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text("${selectedDate.day}.${selectedDate.month}."),
                    onPressed: _pickDate,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.access_time),
                    label: Text(selectedTime.format(context)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: () => _saveChanges(controller),
                child: Text("SPREMI IZMJENE", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _saveChanges(CalendarController controller) async {
    final updatedDateTime = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day,
      selectedTime.hour, selectedTime.minute,
    );

    final updatedEvent = Event(
      id: widget.event.id,
      title: titleController.text,
      description: descController.text,
      dateTime: updatedDateTime,
      colorValue: selectedColor.value, // Spremi odabranu boju
    );

    await controller.updateEvent(updatedEvent);
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context, CalendarController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Brisanje"),
        content: Text("Jeste li sigurni da želite obrisati ovaj događaj?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Odustani")),
          TextButton(
            onPressed: () async {
              await controller.deleteEvent(widget.event.id);
              Navigator.pop(ctx); // zatvori dialog
              Navigator.pop(context); // vrati se na kalendar
            },
            child: Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}