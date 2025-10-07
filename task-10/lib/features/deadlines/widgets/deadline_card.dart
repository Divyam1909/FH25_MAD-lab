import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline_model.dart';

class DeadlineCard extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeadlineCard({
    super.key,
    required this.deadline,
    required this.onTap,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (deadline.priority) {
      case Priority.high: return Colors.red.shade300;
      case Priority.medium: return Colors.orange.shade300;
      case Priority.low: return Colors.green.shade300;
    }
  }

  String _getRemainingTime() {
    final now = DateTime.now();
    final difference = deadline.dueDate.difference(now);

    if (difference.isNegative) return "Overdue";
    if (difference.inDays > 1) return "${difference.inDays} days left";
    if (difference.inHours > 1) return "${difference.inHours} hours left";
    return "${difference.inMinutes} minutes left";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 10,
          decoration: BoxDecoration(
            color: deadline.completed 
                ? Colors.grey 
                : _getPriorityColor(),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          deadline.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: deadline.completed 
                ? TextDecoration.lineThrough 
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(deadline.subject),
            const SizedBox(height: 4),
            Text(
              "Due: ${DateFormat.yMMMd().add_jm().format(deadline.dueDate)}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (!deadline.completed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _getRemainingTime(),
                  style: TextStyle(
                    color: deadline.isOverdue ? Colors.red : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (deadline.completed)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else
              Icon(
                Icons.alarm,
                color: deadline.isOverdue ? Colors.red : Colors.orange,
                size: 24,
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}