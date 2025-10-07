import 'dart:convert';
import 'package:uuid/uuid.dart';

class AttendanceRecord {
  final String id;
  final String subject;
  final DateTime date;
  final AttendanceStatus status;
  final String? notes;

  AttendanceRecord({
    String? id,
    required this.subject,
    required this.date,
    required this.status,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'date': date.toIso8601String(),
      'status': status.index,
      'notes': notes ?? '',
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      subject: map['subject'],
      date: DateTime.parse(map['date']),
      status: AttendanceStatus.values[map['status']],
      notes: map['notes'].isEmpty ? null : map['notes'],
    );
  }
}

enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  String get emoji {
    switch (this) {
      case AttendanceStatus.present:
        return '✅';
      case AttendanceStatus.absent:
        return '❌';
      case AttendanceStatus.late:
        return '⏰';
      case AttendanceStatus.excused:
        return '📝';
    }
  }
}

class SubjectAttendance {
  final String subject;
  final List<AttendanceRecord> records;

  SubjectAttendance({
    required this.subject,
    required this.records,
  });

  int get totalClasses => records.length;
  
  int get presentCount => records
      .where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late)
      .length;
  
  int get absentCount => records
      .where((r) => r.status == AttendanceStatus.absent)
      .length;

  int get excusedCount => records
      .where((r) => r.status == AttendanceStatus.excused)
      .length;

  double get attendancePercentage {
    if (totalClasses == 0) return 0.0;
    // Present and Late count as attended for percentage
    final attended = presentCount;
    return (attended / totalClasses) * 100;
  }

  bool get isAtRisk => attendancePercentage < 75.0;
  
  bool get isGood => attendancePercentage >= 85.0;
}

