import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<AttendanceRecord> _records = [];
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.readAllAttendanceRecords();
    setState(() {
      _records = records;
    });
  }

  List<String> _getSubjects() {
    return _records.map((r) => r.subject).toSet().toList()..sort();
  }

  List<SubjectAttendance> _getSubjectAttendances() {
    final subjects = _getSubjects();
    return subjects.map((subject) {
      final subjectRecords = _records.where((r) => r.subject == subject).toList();
      return SubjectAttendance(subject: subject, records: subjectRecords);
    }).toList();
  }

  double _getOverallAttendance() {
    if (_records.isEmpty) return 0.0;
    final present = _records
        .where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late)
        .length;
    return (present / _records.length) * 100;
  }

  void _markAttendance() async {
    final result = await showDialog<AttendanceRecord>(
      context: context,
      builder: (context) => const _AttendanceDialog(),
    );

    if (result != null) {
      await DatabaseHelper.instance.createAttendanceRecord(result);
      _loadRecords();
    }
  }

  void _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Remove this attendance record?'),
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
      await DatabaseHelper.instance.deleteAttendanceRecord(id);
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = _getSubjects();
    final subjectAttendances = _getSubjectAttendances();
    final overallAttendance = _getOverallAttendance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
          if (subjects.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(_selectedSubject != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined),
              tooltip: 'Filter by Subject',
              onSelected: (subject) {
                setState(() {
                  _selectedSubject = _selectedSubject == subject ? null : subject;
                });
              },
              itemBuilder: (context) => [
                if (_selectedSubject != null)
                  const PopupMenuItem(
                    value: '',
                    child: Row(
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text('Clear Filter'),
                      ],
                    ),
                  ),
                ...subjects.map((subject) => PopupMenuItem(
                      value: subject,
                      child: Row(
                        children: [
                          if (_selectedSubject == subject)
                            const Icon(Icons.check, size: 18)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(subject),
                        ],
                      ),
                    )),
              ],
            ),
        ],
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_reg, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No attendance records yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start marking your attendance',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecords,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Overall Stats Card
                  Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Overall Attendance',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${overallAttendance.toStringAsFixed(1)}%',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: overallAttendance >= 75
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_records.length} total classes',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: overallAttendance / 100,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              overallAttendance >= 75 ? Colors.green : Colors.red,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subject-wise breakdown
                  Text(
                    'Subjects',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...subjectAttendances.map((sa) {
                    if (_selectedSubject != null && sa.subject != _selectedSubject) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: sa.isGood
                              ? Colors.green
                              : sa.isAtRisk
                                  ? Colors.red
                                  : Colors.orange,
                          child: Text(
                            '${sa.attendancePercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          sa.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${sa.presentCount}/${sa.totalClasses} classes attended',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatChip(
                                      label: 'Present',
                                      value: sa.presentCount,
                                      color: Colors.green,
                                      icon: Icons.check_circle,
                                    ),
                                    _StatChip(
                                      label: 'Absent',
                                      value: sa.absentCount,
                                      color: Colors.red,
                                      icon: Icons.cancel,
                                    ),
                                    _StatChip(
                                      label: 'Excused',
                                      value: sa.excusedCount,
                                      color: Colors.blue,
                                      icon: Icons.note_alt,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                ...sa.records.reversed.take(5).map((record) {
                                  return ListTile(
                                    dense: true,
                                    leading: Text(
                                      record.status.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    title: Text(record.status.displayName),
                                    subtitle: Text(
                                      DateFormat('MMM dd, yyyy').format(record.date),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      onPressed: () => _deleteRecord(record.id),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _markAttendance,
        icon: const Icon(Icons.add),
        label: const Text('Mark Attendance'),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _AttendanceDialog extends StatefulWidget {
  const _AttendanceDialog();

  @override
  State<_AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<_AttendanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  AttendanceStatus _status = AttendanceStatus.present;

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark Attendance'),
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
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AttendanceStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: AttendanceStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Text(status.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(status.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
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
              final record = AttendanceRecord(
                subject: _subjectController.text.trim(),
                date: _selectedDate,
                status: _status,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              );
              Navigator.pop(context, record);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

