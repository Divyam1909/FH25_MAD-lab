import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../models/study_session_model.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> with SingleTickerProviderStateMixin {
  List<StudySession> _sessions = [];
  bool _isTimerRunning = false;
  int _secondsElapsed = 0;
  String _currentSubject = '';
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _loadSessions();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final sessions = await DatabaseHelper.instance.readAllStudySessions();
    setState(() {
      _sessions = sessions;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startTimer(String subject) async {
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject')),
      );
      return;
    }

    setState(() {
      _isTimerRunning = true;
      _currentSubject = subject;
      _secondsElapsed = 0;
    });

    // Simple timer implementation
    while (_isTimerRunning && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isTimerRunning) {
        setState(() => _secondsElapsed++);
      }
    }
  }

  void _stopTimer() async {
    if (!_isTimerRunning) return;

    setState(() => _isTimerRunning = false);

    final minutes = _secondsElapsed ~/ 60;
    if (minutes > 0) {
      final session = StudySession(
        subject: _currentSubject,
        durationMinutes: minutes,
        startTime: DateTime.now().subtract(Duration(seconds: _secondsElapsed)),
        endTime: DateTime.now(),
        completed: true,
      );

      await DatabaseHelper.instance.createStudySession(session);
      _loadSessions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Great work! Studied $_currentSubject for $minutes minutes'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    setState(() {
      _secondsElapsed = 0;
      _currentSubject = '';
    });
  }

  void _showStartDialog() {
    final subjectController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Study Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g., Mathematics, Physics',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Focus for 25 minutes, then take a 5 minute break!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer(subjectController.text.trim());
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = StudyStats.fromSessions(_sessions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(),
            tooltip: 'History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Timer Display
              Card(
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(32),
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
                      if (_isTimerRunning) ...[
                        Text(
                          _currentSubject,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isTimerRunning ? 1.0 + (_pulseController.value * 0.05) : 1.0,
                            child: Text(
                              _formatDuration(_secondsElapsed),
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 64,
                                color: _isTimerRunning ? theme.colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_isTimerRunning)
                        FilledButton.icon(
                          onPressed: _stopTimer,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Session'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _showStartDialog,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Studying'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              Text(
                'Your Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _StatCard(
                    icon: Icons.today,
                    label: 'Today',
                    value: '${stats.totalMinutesToday} min',
                    color: Colors.blue,
                  ),
                  _StatCard(
                    icon: Icons.date_range,
                    label: 'This Week',
                    value: '${stats.totalMinutesThisWeek} min',
                    color: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.assignment_turned_in,
                    label: 'Total Sessions',
                    value: '${stats.totalSessions}',
                    color: Colors.orange,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '${stats.currentStreak} days',
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subject Breakdown
              if (stats.subjectBreakdown.isNotEmpty) ...[
                Text(
                  'Subject Breakdown',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: stats.subjectBreakdown.entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Text(
                                      '${entry.value} min',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    const Text(
                      'Study History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _sessions.isEmpty
                    ? const Center(child: Text('No study sessions yet'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: session.completed
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                child: Icon(
                                  session.completed ? Icons.check : Icons.timer,
                                  color: session.completed ? Colors.green : Colors.grey,
                                ),
                              ),
                              title: Text(session.subject),
                              subtitle: Text(
                                DateFormat('MMM dd, yyyy • HH:mm').format(session.startTime),
                              ),
                              trailing: Text(
                                '${session.durationMinutes} min',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

