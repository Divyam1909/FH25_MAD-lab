import 'dart:convert';
import 'package:uuid/uuid.dart';

class GradeEntry {
  final String id;
  final String subject;
  final String assessmentName;
  final double marksObtained;
  final double totalMarks;
  final double weightage; // Percentage weightage
  final DateTime date;
  final String? notes;

  GradeEntry({
    String? id,
    required this.subject,
    required this.assessmentName,
    required this.marksObtained,
    required this.totalMarks,
    required this.weightage,
    required this.date,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  double get percentage => (marksObtained / totalMarks) * 100;
  
  double get weightedScore => percentage * (weightage / 100);

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'assessmentName': assessmentName,
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'weightage': weightage,
      'date': date.toIso8601String(),
      'notes': notes ?? '',
    };
  }

  factory GradeEntry.fromMap(Map<String, dynamic> map) {
    return GradeEntry(
      id: map['id'],
      subject: map['subject'],
      assessmentName: map['assessmentName'],
      marksObtained: map['marksObtained'].toDouble(),
      totalMarks: map['totalMarks'].toDouble(),
      weightage: map['weightage'].toDouble(),
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}

class SubjectGrade {
  final String subject;
  final List<GradeEntry> entries;

  SubjectGrade({
    required this.subject,
    required this.entries,
  });

  double get overallPercentage {
    if (entries.isEmpty) return 0;
    final totalWeightage = entries.fold(0.0, (sum, e) => sum + e.weightage);
    if (totalWeightage == 0) {
      // Simple average if no weightage specified
      return entries.fold(0.0, (sum, e) => sum + e.percentage) / entries.length;
    }
    return entries.fold(0.0, (sum, e) => sum + e.weightedScore);
  }

  String get overallGrade {
    final pct = overallPercentage;
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C';
    if (pct >= 40) return 'D';
    return 'F';
  }

  double get gpa {
    final pct = overallPercentage;
    if (pct >= 90) return 10.0;
    if (pct >= 80) return 9.0;
    if (pct >= 70) return 8.0;
    if (pct >= 60) return 7.0;
    if (pct >= 50) return 6.0;
    if (pct >= 40) return 5.0;
    return 0.0;
  }
}

