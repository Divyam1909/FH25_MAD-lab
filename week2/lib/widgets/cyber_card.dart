import 'package:flutter/material.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool glowEffect;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.glowEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FF41).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: glowEffect
            ? [
                BoxShadow(
                  color: const Color(0xFF00FF41).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}