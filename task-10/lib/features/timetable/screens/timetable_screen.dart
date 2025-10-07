import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../models/timetable_model.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<TimetableEntry> _entries = [];
  bool _isLoading = true;
  int _selectedDay = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() => _isLoading = true);
    final entries = await DatabaseHelper.instance.readAllTimetableEntries();
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  List<TimetableEntry> _getEntriesForDay(int day) {
    return _entries
        .where((e) => e.dayOfWeek == day)
        .toList()
      ..sort((a, b) {
        final aStart = a.timeSlot.startHour * 60 + a.timeSlot.startMinute;
        final bStart = b.timeSlot.startHour * 60 + b.timeSlot.startMinute;
        return aStart.compareTo(bStart);
      });
  }

  void _addEntry() async {
    final result = await showDialog<TimetableEntry>(
      context: context,
      builder: (context) => _TimetableEntryDialog(selectedDay: _selectedDay),
    );

    if (result != null) {
      await DatabaseHelper.instance.createTimetableEntry(result);
      _loadTimetable();
    }
  }

  void _deleteEntry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Remove this class from your timetable?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteTimetableEntry(id);
      _loadTimetable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Timetable'),
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.surfaceVariant,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final isToday = day == DateTime.now().weekday;
                  final isSelected = day == _selectedDay;
                  final hasClasses = _entries.any((e) => e.dayOfWeek == day);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(days[index]),
                          if (hasClasses)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedDay = day);
                      },
                      backgroundColor: isToday ? theme.colorScheme.primaryContainer : null,
                    ),
                  );
                }),
              ),
            ),
          ),

          // Classes list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDaySchedule(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaySchedule() {
    final dayEntries = _getEntriesForDay(_selectedDay);
    final now = DateTime.now();
    final currentDay = now.weekday;

    if (dayEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No classes scheduled',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add a class',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEntries.length,
      itemBuilder: (context, index) {
        final entry = dayEntries[index];
        final isToday = _selectedDay == currentDay;
        final isCurrentClass = isToday && entry.timeSlot.isNow();
        final isUpcoming = isToday && entry.timeSlot.isUpcoming();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isCurrentClass
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCurrentClass
                      ? Icons.play_circle_filled
                      : isUpcoming
                          ? Icons.access_time
                          : Icons.schedule,
                  color: isCurrentClass
                      ? Theme.of(context).colorScheme.primary
                      : isUpcoming
                          ? Colors.orange
                          : Colors.grey,
                  size: 32,
                ),
                if (isCurrentClass)
                  Text(
                    'NOW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            title: Text(
              entry.subject,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isCurrentClass ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(entry.teacher),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.room, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(entry.room),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.timeSlot.timeRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => _deleteEntry(entry.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimetableEntryDialog extends StatefulWidget {
  final int selectedDay;

  const _TimetableEntryDialog({required this.selectedDay});

  @override
  State<_TimetableEntryDialog> createState() => _TimetableEntryDialogState();
}

class _TimetableEntryDialogState extends State<_TimetableEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();
  
  late int _selectedDay;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return AlertDialog(
      title: const Text('Add Class'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Teacher',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room/Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.room),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: List.generate(7, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(days[index]),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDay = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text(_startTime.format(context)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(false),
                      icon: const Icon(Icons.access_time),
                      label: Text(_endTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final entry = TimetableEntry(
                subject: _subjectController.text.trim(),
                teacher: _teacherController.text.trim(),
                room: _roomController.text.trim(),
                dayOfWeek: _selectedDay,
                timeSlot: TimeSlot(
                  startHour: _startTime.hour,
                  startMinute: _startTime.minute,
                  endHour: _endTime.hour,
                  endMinute: _endTime.minute,
                ),
                notes: _notesController.text.trim(),
              );
              Navigator.pop(context, entry);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

