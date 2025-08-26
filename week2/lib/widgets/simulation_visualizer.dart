import 'package:flutter/material.dart';
// no additional imports

enum NodeType { source, agent, destination }

class NetworkNode {
  final String label;
  final Offset position;
  final NodeType type;

  NetworkNode(this.label, this.position, this.type);
}

class Connection {
  final int from;
  final int to;

  Connection(this.from, this.to);
}

class SimulationVisualizer extends StatefulWidget {
  final bool isRunning;

  const SimulationVisualizer({super.key, this.isRunning = false});

  @override
  State<SimulationVisualizer> createState() => _SimulationVisualizerState();
}

class _SimulationVisualizerState extends State<SimulationVisualizer>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _dataFlowController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _dataFlowAnimation;

  final List<NetworkNode> _nodes = [
    NetworkNode('Source', const Offset(50, 150), NodeType.source),
    NetworkNode('Agent A', const Offset(150, 100), NodeType.agent),
    NetworkNode('Agent B', const Offset(250, 150), NodeType.agent),
    NetworkNode('Agent C', const Offset(150, 200), NodeType.agent),
    NetworkNode('Destination', const Offset(350, 150), NodeType.destination),
  ];

  final List<Connection> _connections = [
    Connection(0, 1),
    Connection(1, 2),
    Connection(1, 3),
    Connection(2, 4),
    Connection(3, 4),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _dataFlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
    _dataFlowAnimation = CurvedAnimation(parent: _dataFlowController, curve: Curves.linear);
  }

  @override
  void didUpdateWidget(covariant SimulationVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _dataFlowController.repeat();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _dataFlowController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dataFlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Stack(
        children: [
          CustomPaint(size: const Size(400, 300), painter: GridPainter()),
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _dataFlowAnimation]),
            builder: (context, _) => CustomPaint(
              size: const Size(400, 300),
              painter: NetworkPainter(
                nodes: _nodes,
                connections: _connections,
                pulseValue: _pulseAnimation.value,
                dataFlowValue: _dataFlowAnimation.value,
                isRunning: widget.isRunning,
              ),
            ),
          ),

          // Status and legend
          Positioned(
            top: 8,
            right: 8,
            child: Row(children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: widget.isRunning ? const Color(0xFF00FF41) : Colors.grey,
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(widget.isRunning ? 'ACTIVE' : 'IDLE', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.06)
      ..strokeWidth = 1;

    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NetworkPainter extends CustomPainter {
  final List<NetworkNode> nodes;
  final List<Connection> connections;
  final double pulseValue;
  final double dataFlowValue;
  final bool isRunning;

  NetworkPainter({
    required this.nodes,
    required this.connections,
    required this.pulseValue,
    required this.dataFlowValue,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final connectionPaint = Paint()..color = const Color(0xFF333333);
    final nodePaint = Paint()..color = const Color(0xFF00AEEF);
    final labelStyle = TextStyle(color: Colors.grey.shade300, fontSize: 12);

    for (final connection in connections) {
      final a = nodes[connection.from].position;
      final b = nodes[connection.to].position;
      canvas.drawLine(a, b, connectionPaint);

      if (isRunning) {
        final t = (dataFlowValue + connection.from * 0.15) % 1.0;
        final pos = Offset.lerp(a, b, t.clamp(0.0, 1.0))!;
        final dotPaint = Paint()..color = const Color(0xFF00FF41);
        canvas.drawCircle(pos, 4, dotPaint);
      }
    }

    for (final node in nodes) {
      final baseRadius = node.type == NodeType.source || node.type == NodeType.destination ? 16.0 : 12.0;
      final radius = baseRadius + (node.type == NodeType.source ? pulseValue * 4 : 0);

      final paint = Paint()..color = node.type == NodeType.destination ? const Color(0xFF00FF41) : nodePaint.color;
      canvas.drawCircle(node.position, radius, paint);

      final tp = TextPainter(
        text: TextSpan(text: node.label, style: labelStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, node.position + Offset(-tp.width / 2, radius + 6));
    }
  }

  @override
  bool shouldRepaint(covariant NetworkPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.dataFlowValue != dataFlowValue || oldDelegate.isRunning != isRunning;
  }
}