import 'dart:convert';
import 'package:uuid/uuid.dart';

class StudySession {
  final String id;
  final String subject;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final String? notes;

  StudySession({
    String? id,
    required this.subject,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    this.completed = false,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completed': completed ? 1 : 0,
      'notes': notes ?? '',
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      subject: map['subject'],
      durationMinutes: map['durationMinutes'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      completed: map['completed'] == 1,
      notes: map['notes'],
    );
  }
}

class StudyStats {
  final int totalMinutesThisWeek;
  final int totalMinutesToday;
  final int totalSessions;
  final Map<String, int> subjectBreakdown;
  final int currentStreak;

  StudyStats({
    required this.totalMinutesThisWeek,
    required this.totalMinutesToday,
    required this.totalSessions,
    required this.subjectBreakdown,
    required this.currentStreak,
  });

  static StudyStats fromSessions(List<StudySession> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    int totalToday = 0;
    int totalWeek = 0;
    final Map<String, int> breakdown = {};

    for (final session in sessions) {
      if (session.completed) {
        final sessionDate = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );

        if (sessionDate.isAtSameMomentAs(today)) {
          totalToday += session.durationMinutes;
        }

        if (session.startTime.isAfter(weekAgo)) {
          totalWeek += session.durationMinutes;
        }

        breakdown[session.subject] = 
            (breakdown[session.subject] ?? 0) + session.durationMinutes;
      }
    }

    return StudyStats(
      totalMinutesThisWeek: totalWeek,
      totalMinutesToday: totalToday,
      totalSessions: sessions.where((s) => s.completed).length,
      subjectBreakdown: breakdown,
      currentStreak: _calculateStreak(sessions),
    );
  }

  static int _calculateStreak(List<StudySession> sessions) {
    final completedSessions = sessions
        .where((s) => s.completed)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (completedSessions.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final session in completedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        lastDate = sessionDate;
        streak = 1;
      } else {
        final diff = lastDate.difference(sessionDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = sessionDate;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return streak;
  }
}

