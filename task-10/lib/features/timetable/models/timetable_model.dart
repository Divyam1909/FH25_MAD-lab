import 'dart:convert';
import 'package:uuid/uuid.dart';

class TimetableEntry {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeSlot timeSlot;
  final String? notes;

  TimetableEntry({
    String? id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.dayOfWeek,
    required this.timeSlot,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'timeSlot': jsonEncode(timeSlot.toMap()),
      'notes': notes ?? '',
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      subject: map['subject'],
      teacher: map['teacher'],
      room: map['room'],
      dayOfWeek: map['dayOfWeek'],
      timeSlot: TimeSlot.fromMap(jsonDecode(map['timeSlot'])),
      notes: map['notes'],
    );
  }

  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }
}

class TimeSlot {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  TimeSlot({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  String get startTime => '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTime => '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  String get timeRange => '$startTime - $endTime';

  Map<String, dynamic> toMap() {
    return {
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startHour: map['startHour'],
      startMinute: map['startMinute'],
      endHour: map['endHour'],
      endMinute: map['endMinute'],
    );
  }

  bool isNow() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, startHour, startMinute);
    final end = DateTime(now.year, now.month, now.day, endHour, endMinute);
    return now.isAfter(start) && now.isBefore(end);
  }

  bool isUpcoming() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, startHour, startMinute);
    return now.isBefore(start);
  }
}

