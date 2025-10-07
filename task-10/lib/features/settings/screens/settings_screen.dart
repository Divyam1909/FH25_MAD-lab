import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/database/database_helper.dart';
import '../../notes/models/note_model.dart';
import '../../deadlines/models/deadline_model.dart';
import '../../split/models/expense_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'customize_navigation_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Customize Navigation'),
            subtitle: const Text('Choose which features appear in bottom bar'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomizeNavigationScreen(),
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(),

          // Data Management Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Data Management',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your data'),
            onTap: () => _backupData(context),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Restore Data'),
            subtitle: const Text('Import data from backup'),
            onTap: () => _restoreData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all notes, deadlines, and groups'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showClearDataDialog(context),
          ),
          const Divider(),

          // Notifications Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Deadline Notifications'),
            subtitle: const Text('Configure deadline reminder settings'),
            onTap: () => _showNotificationSettings(context),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const Divider(),

          // About Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About StudyHub'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: () {
              Share.share(
                'Check out StudyHub - Your all-in-one student companion app!',
                subject: 'StudyHub App',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'StudyHub',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: [
        const Text(
          'StudyHub is your all-in-one student companion app that helps you:',
        ),
        const SizedBox(height: 12),
        const Text('📝 Manage and share peer notes'),
        const Text('📅 Track deadlines with visual radar'),
        const Text('💬 Share anonymous class feedback'),
        const Text('💸 Split expenses with classmates'),
        const SizedBox(height: 12),
        const Text(
          'Built with Flutter for students, by students.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      // Get all data
      final notes = await DatabaseHelper.instance.readAllNotes();
      final deadlines = await DatabaseHelper.instance.readAllDeadlines();
      final groups = await DatabaseHelper.instance.readAllGroups();

      // Create backup JSON
      final backup = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'notes': notes.map((n) => n.toJson()).toList(),
        'deadlines': deadlines.map((d) => d.toMap()).toList(),
        'groups': groups.map((g) => g.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/studyhub_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'StudyHub Backup',
        text: 'StudyHub data backup - ${DateTime.now()}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating backup: $e')),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup
      if (!backup.containsKey('notes') ||
          !backup.containsKey('deadlines') ||
          !backup.containsKey('groups')) {
        throw Exception('Invalid backup file format');
      }

      // Confirm restore
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Data'),
          content: Text(
            'This will replace all current data with the backup from:\n\n'
            '${backup['timestamp']}\n\n'
            'Notes: ${(backup['notes'] as List).length}\n'
            'Deadlines: ${(backup['deadlines'] as List).length}\n'
            'Groups: ${(backup['groups'] as List).length}\n\n'
            'Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Import notes
      final notes = (backup['notes'] as List)
          .map((n) => Note.fromJson(n as Map<String, dynamic>))
          .toList();
      for (final note in notes) {
        await DatabaseHelper.instance.createNote(note);
      }

      // Import deadlines
      final deadlines = (backup['deadlines'] as List)
          .map((d) => Deadline.fromMap(d as Map<String, dynamic>))
          .toList();
      for (final deadline in deadlines) {
        await DatabaseHelper.instance.createDeadline(deadline);
      }

      // Import groups
      final groups = (backup['groups'] as List)
          .map((g) => Group.fromMap(g as Map<String, dynamic>))
          .toList();
      for (final group in groups) {
        await DatabaseHelper.instance.createGroup(group);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data restored successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring data: $e')),
        );
      }
    }
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deadline reminders are automatically scheduled when you create or edit deadlines.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'You will receive notifications:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNotificationItem('📅', '1 day before the deadline'),
            _buildNotificationItem('⏰', '1 hour before the deadline'),
            const SizedBox(height: 16),
            const Text(
              'Make sure notifications are enabled in your device settings.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your notes, deadlines, groups, and expenses. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Delete all notes
              final notes = await DatabaseHelper.instance.readAllNotes();
              for (final note in notes) {
                await DatabaseHelper.instance.deleteNote(note.id);
              }

              // Delete all deadlines
              final deadlines = await DatabaseHelper.instance.readAllDeadlines();
              for (final deadline in deadlines) {
                await DatabaseHelper.instance.deleteDeadline(deadline.id);
              }

              // Delete all groups
              final groups = await DatabaseHelper.instance.readAllGroups();
              for (final group in groups) {
                await DatabaseHelper.instance.deleteGroup(group.id);
              }

              Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
