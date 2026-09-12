import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final TimeOfDay? time;
  final int? colorValue;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.time,
    this.colorValue,
  });
}