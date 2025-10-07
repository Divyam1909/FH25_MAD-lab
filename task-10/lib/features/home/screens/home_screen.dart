import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../deadlines/models/deadline_model.dart';
import '../../notes/models/note_model.dart';
import '../../split/models/expense_model.dart';
import '../widgets/deadline_radar_widget.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Deadline> _deadlines = [];
  List<Note> _notes = [];
  List<Group> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final deadlines = await DatabaseHelper.instance.readAllDeadlines();
    final notes = await DatabaseHelper.instance.readAllNotes();
    final groups = await DatabaseHelper.instance.readAllGroups();
    setState(() {
      _deadlines = deadlines;
      _notes = notes;
      _groups = groups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeDeadlines = _deadlines.where((d) => !d.completed).length;
    final overdueDeadlines = _deadlines.where((d) => d.isOverdue).length;
    final completedDeadlines = _deadlines.where((d) => d.completed).length;
    final totalExpenses = _groups.fold<double>(
      0.0,
      (sum, group) => sum + group.totalExpenses,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyHub'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to StudyHub',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your all-in-one student companion',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    icon: Icons.assignment,
                    label: 'Active Deadlines',
                    value: '$activeDeadlines',
                    color: Colors.blue,
                  ),
                  _StatCard(
                    icon: Icons.warning,
                    label: 'Overdue',
                    value: '$overdueDeadlines',
                    color: Colors.red,
                  ),
                  _StatCard(
                    icon: Icons.note_alt,
                    label: 'Total Notes',
                    value: '${_notes.length}',
                    color: Colors.teal,
                  ),
                  _StatCard(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: '$completedDeadlines',
                    color: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.group,
                    label: 'Split Groups',
                    value: '${_groups.length}',
                    color: Colors.amber,
                  ),
                  _StatCard(
                    icon: Icons.currency_rupee,
                    label: 'Total Expenses',
                    value: '₹${totalExpenses.toStringAsFixed(0)}',
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upcoming Deadlines Section
              if (_deadlines.where((d) => !d.completed).isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Deadlines',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to deadlines tab would be handled by parent
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._deadlines
                    .where((d) => !d.completed)
                    .take(3)
                    .map((deadline) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: deadline.isOverdue
                                  ? Colors.red.shade100
                                  : theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.calendar_today,
                                color: deadline.isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              deadline.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              deadline.subject,
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Text(
                              '${deadline.daysUntil} days',
                              style: TextStyle(
                                color: deadline.isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 24),
              ],

              // Deadline Radar
              Text(
                'Deadline Radar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: _isLoading
                    ? const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DeadlineRadarWidget(deadlines: _deadlines),
              ),
              const SizedBox(height: 24),

              // Quick Access Modules
              Text(
                'Quick Access',
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
                children: [
                  _ModuleCard(
                    icon: Icons.note_alt,
                    title: 'Peer Notes',
                    color: Colors.teal,
                    onTap: () => widget.onNavigate?.call(1),
                  ),
                  _ModuleCard(
                    icon: Icons.radar,
                    title: 'Deadlines',
                    color: Colors.indigo,
                    onTap: () => widget.onNavigate?.call(2),
                  ),
                  _ModuleCard(
                    icon: Icons.forum,
                    title: 'Class Whisper',
                    color: Colors.purple,
                    onTap: () => widget.onNavigate?.call(3),
                  ),
                  _ModuleCard(
                    icon: Icons.payments,
                    title: 'ClassSplit',
                    color: Colors.amber,
                    onTap: () => widget.onNavigate?.call(4),
                  ),
                  _ModuleCard(
                    icon: Icons.timer,
                    title: 'Study Timer',
                    color: Colors.red,
                    onTap: () => widget.onNavigate?.call(5),
                  ),
                  _ModuleCard(
                    icon: Icons.grade,
                    title: 'Grades',
                    color: Colors.green,
                    onTap: () => widget.onNavigate?.call(6),
                  ),
                  _ModuleCard(
                    icon: Icons.schedule,
                    title: 'Timetable',
                    color: Colors.blue,
                    onTap: () => widget.onNavigate?.call(7),
                  ),
                  _ModuleCard(
                    icon: Icons.how_to_reg,
                    title: 'Attendance',
                    color: Colors.deepPurple,
                    onTap: () => widget.onNavigate?.call(8),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
