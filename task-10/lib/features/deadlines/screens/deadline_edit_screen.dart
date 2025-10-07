import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/notification_service.dart';
import '../models/deadline_model.dart';

class DeadlineEditScreen extends StatefulWidget {
  final Deadline? deadline;
  const DeadlineEditScreen({super.key, this.deadline});

  @override
  State<DeadlineEditScreen> createState() => _DeadlineEditScreenState();
}

class _DeadlineEditScreenState extends State<DeadlineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late DateTime _dueDate;
  late Priority _priority;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.deadline?.title ?? '');
    _subjectController = TextEditingController(text: widget.deadline?.subject ?? '');
    _dueDate = widget.deadline?.dueDate ?? DateTime.now();
    _priority = widget.deadline?.priority ?? Priority.medium;
    _completed = widget.deadline?.completed ?? false;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveDeadline() async {
    if (_formKey.currentState!.validate()) {
      final isUpdating = widget.deadline != null;
      final deadline = Deadline(
        id: widget.deadline?.id,
        title: _titleController.text,
        subject: _subjectController.text,
        dueDate: _dueDate,
        priority: _priority,
        completed: _completed,
      );

      if (isUpdating) {
        await DatabaseHelper.instance.updateDeadline(deadline);
        // Cancel old notification and schedule new one if not completed
        await NotificationService().cancelNotification(deadline.id.hashCode);
      } else {
        await DatabaseHelper.instance.createDeadline(deadline);
      }

      // Schedule notification if deadline is not completed and is in the future
      if (!deadline.completed && deadline.dueDate.isAfter(DateTime.now())) {
        // Schedule notification 1 day before
        final oneDayBefore = deadline.dueDate.subtract(const Duration(days: 1));
        if (oneDayBefore.isAfter(DateTime.now())) {
          await NotificationService().scheduleDeadlineNotification(
            id: deadline.id.hashCode,
            title: '📅 Deadline Tomorrow!',
            body: '${deadline.subject}: ${deadline.title}',
            scheduledDate: oneDayBefore,
          );
        }

        // Schedule notification 1 hour before
        final oneHourBefore = deadline.dueDate.subtract(const Duration(hours: 1));
        if (oneHourBefore.isAfter(DateTime.now())) {
          await NotificationService().scheduleDeadlineNotification(
            id: deadline.id.hashCode + 1,
            title: '⏰ Deadline in 1 Hour!',
            body: '${deadline.subject}: ${deadline.title}',
            scheduledDate: oneHourBefore,
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deadline == null ? 'New Deadline' : 'Edit Deadline'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveDeadline)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
              validator: (v) => v!.trim().isEmpty ? 'Subject is required' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade400)),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date & Time'),
              subtitle: Text(DateFormat.yMMMd().add_jm().format(_dueDate)),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            if (widget.deadline != null) ...[
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _completed,
                onChanged: (value) => setState(() => _completed = value ?? false),
                title: const Text('Mark as Completed'),
                subtitle: const Text('Check when deadline is finished'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}