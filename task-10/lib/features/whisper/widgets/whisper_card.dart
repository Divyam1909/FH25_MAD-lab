import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/whisper_model.dart';

class WhisperCard extends StatelessWidget {
  final WhisperPost whisper;
  final VoidCallback onToggleResolved;

  const WhisperCard({
    super.key,
    required this.whisper,
    required this.onToggleResolved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Anonymous',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (whisper.resolved)
                  Chip(
                    label: const Text('Resolved'),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              whisper.text,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(whisper.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onToggleResolved,
                  icon: Icon(
                    whisper.resolved
                        ? Icons.undo
                        : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    whisper.resolved ? 'Unresolve' : 'Mark Resolved',
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
