import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../deadlines/models/deadline_model.dart';

class DeadlineRadarWidget extends StatelessWidget {
  final List<Deadline> deadlines;

  const DeadlineRadarWidget({super.key, required this.deadlines});

  @override
  Widget build(BuildContext context) {
    // Filter out completed deadlines and sort by due date
    final activeDeadlines = deadlines
        .where((d) => !d.completed)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: activeDeadlines.isEmpty
          ? const Center(
              child: Text(
                'No active deadlines',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : CustomPaint(
              painter: RadarPainter(
                deadlines: activeDeadlines.take(8).toList(),
              ),
              child: Container(),
            ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final List<Deadline> deadlines;

  RadarPainter({required this.deadlines});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 40;

    // Draw concentric circles (radar rings)
    _drawRadarRings(canvas, center, maxRadius);

    // Draw deadline points
    _drawDeadlinePoints(canvas, center, maxRadius);
  }

  void _drawRadarRings(Canvas canvas, Offset center, double maxRadius) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 4 concentric circles
    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * (i / 4);
      canvas.drawCircle(center, radius, paint);
    }

    // Draw radial lines (8 directions)
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8 - math.pi / 2;
      final end = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, end, paint);
    }
  }

  void _drawDeadlinePoints(Canvas canvas, Offset center, double maxRadius) {
    final now = DateTime.now();

    for (int i = 0; i < deadlines.length && i < 8; i++) {
      final deadline = deadlines[i];
      final daysUntil = deadline.dueDate.difference(now).inDays;

      // Calculate position on radar
      final angle = (i * math.pi * 2) / 8 - math.pi / 2;
      
      // Map days to radius (closer date = farther from center)
      // 0 days = maxRadius, 30+ days = near center
      final normalizedDays = (daysUntil / 30).clamp(0.0, 1.0);
      final radius = maxRadius * (1 - normalizedDays);

      final position = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      // Choose color based on priority and urgency
      Color color;
      if (daysUntil < 0) {
        color = Colors.red.shade700; // Overdue
      } else if (deadline.priority == Priority.high) {
        color = Colors.red.shade400;
      } else if (deadline.priority == Priority.medium) {
        color = Colors.orange.shade400;
      } else {
        color = Colors.green.shade400;
      }

      // Draw point
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, 8, pointPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(position, 8, borderPaint);

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: deadline.subject.substring(0, math.min(3, deadline.subject.length)),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy + 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
