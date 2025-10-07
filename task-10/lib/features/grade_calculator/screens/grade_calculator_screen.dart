import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../models/grade_model.dart';

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  List<GradeEntry> _grades = [];
  bool _isLoading = true;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    final grades = await DatabaseHelper.instance.readAllGradeEntries();
    setState(() {
      _grades = grades;
      _isLoading = false;
    });
  }

  List<String> _getSubjects() {
    return _grades.map((g) => g.subject).toSet().toList()..sort();
  }

  List<SubjectGrade> _getSubjectGrades() {
    final subjects = _getSubjects();
    return subjects.map((subject) {
      final entries = _grades.where((g) => g.subject == subject).toList();
      return SubjectGrade(subject: subject, entries: entries);
    }).toList();
  }

  double _calculateOverallGPA() {
    final subjectGrades = _getSubjectGrades();
    if (subjectGrades.isEmpty) return 0.0;
    final totalGPA = subjectGrades.fold(0.0, (sum, sg) => sum + sg.gpa);
    return totalGPA / subjectGrades.length;
  }

  void _addGrade() async {
    final result = await showDialog<GradeEntry>(
      context: context,
      builder: (context) => const _GradeEntryDialog(),
    );

    if (result != null) {
      await DatabaseHelper.instance.createGradeEntry(result);
      _loadGrades();
    }
  }

  void _deleteGrade(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: const Text('Are you sure you want to delete this grade entry?'),
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
      await DatabaseHelper.instance.deleteGradeEntry(id);
      _loadGrades();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = _getSubjects();
    final subjectGrades = _getSubjectGrades();
    final overallGPA = _calculateOverallGPA();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator'),
        actions: [
          if (subjects.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(_selectedSubject != null ? Icons.filter_alt : Icons.filter_alt_outlined),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grades.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grade, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No grades yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first grade to track your progress',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGrades,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overall GPA Card
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
                                  'Overall GPA',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  overallGPA.toStringAsFixed(2),
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${subjects.length} ${subjects.length == 1 ? 'Subject' : 'Subjects'}',
                                  style: theme.textTheme.bodySmall,
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

                        ...subjectGrades.map((sg) {
                          if (_selectedSubject != null && sg.subject != _selectedSubject) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getGradeColor(sg.overallGrade),
                                child: Text(
                                  sg.overallGrade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                sg.subject,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${sg.overallPercentage.toStringAsFixed(1)}% • GPA: ${sg.gpa.toStringAsFixed(1)}',
                              ),
                              children: [
                                const Divider(height: 1),
                                ...sg.entries.map((entry) => ListTile(
                                      title: Text(entry.assessmentName),
                                      subtitle: Text(
                                        '${entry.marksObtained}/${entry.totalMarks} • ${entry.weightage}% weight',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Chip(
                                            label: Text(entry.grade),
                                            backgroundColor: _getGradeColor(entry.grade),
                                            labelStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            color: Colors.red,
                                            onPressed: () => _deleteGrade(entry.id),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGrade,
        icon: const Icon(Icons.add),
        label: const Text('Add Grade'),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _GradeEntryDialog extends StatefulWidget {
  const _GradeEntryDialog();

  @override
  State<_GradeEntryDialog> createState() => _GradeEntryDialogState();
}

class _GradeEntryDialogState extends State<_GradeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _marksController = TextEditingController();
  final _totalController = TextEditingController();
  final _weightageController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _assessmentController.dispose();
    _marksController.dispose();
    _totalController.dispose();
    _weightageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _percentage {
    final marks = double.tryParse(_marksController.text) ?? 0;
    final total = double.tryParse(_totalController.text) ?? 1;
    return (marks / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Grade Entry'),
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
                controller: _assessmentController,
                decoration: const InputDecoration(
                  labelText: 'Assessment Name',
                  hintText: 'e.g., Midterm, Quiz 1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marksController,
                      decoration: const InputDecoration(
                        labelText: 'Marks Obtained',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('/'),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _totalController,
                      decoration: const InputDecoration(
                        labelText: 'Total Marks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_marksController.text.isNotEmpty && _totalController.text.isNotEmpty)
                Text(
                  'Percentage: ${_percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightageController,
                decoration: const InputDecoration(
                  labelText: 'Weightage (%)',
                  hintText: 'e.g., 30 for 30%',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
              final entry = GradeEntry(
                subject: _subjectController.text.trim(),
                assessmentName: _assessmentController.text.trim(),
                marksObtained: double.parse(_marksController.text),
                totalMarks: double.parse(_totalController.text),
                weightage: double.parse(_weightageController.text),
                date: DateTime.now(),
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

