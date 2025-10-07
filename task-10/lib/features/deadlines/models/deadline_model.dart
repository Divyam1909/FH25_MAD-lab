import 'package:uuid/uuid.dart';

enum Priority { low, medium, high }

class Deadline {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final Priority priority;
  final bool completed;

  Deadline({
    String? id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.completed = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index,
      'completed': completed ? 1 : 0,
    };
  }

  factory Deadline.fromMap(Map<String, dynamic> map) {
    return Deadline(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: Priority.values[map['priority']],
      completed: map['completed'] == 1,
    );
  }

  Deadline copyWith({
    String? title,
    String? subject,
    DateTime? dueDate,
    Priority? priority,
    bool? completed,
  }) {
    return Deadline(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
    );
  }

  // Get days until deadline
  int get daysUntil {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // Check if deadline is overdue
  bool get isOverdue {
    return !completed && DateTime.now().isAfter(dueDate);
  }
}