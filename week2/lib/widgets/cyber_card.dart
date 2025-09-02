import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool glowEffect;
  final bool isInteractive;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double? elevation;
  final bool enableAnimations;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.glowEffect = true,
    this.isInteractive = false,
    this.onTap,
    this.borderColor,
    this.elevation,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppTheme.primaryGreen;
    final effectiveElevation = elevation ?? (glowEffect ? 8.0 : 4.0);
    
    Widget cardWidget = Container(
      padding: padding ?? AppConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: AppConfig.defaultBorderRadius,
        border: Border.all(
          color: effectiveBorderColor.withOpacity(glowEffect ? 0.5 : 0.3),
          width: glowEffect ? 1.5 : 1,
        ),
        boxShadow: glowEffect
            ? [
                BoxShadow(
                  color: effectiveBorderColor.withOpacity(0.2),
                  blurRadius: effectiveElevation * 2,
                  spreadRadius: effectiveElevation / 4,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: effectiveBorderColor.withOpacity(0.1),
                  blurRadius: effectiveElevation * 4,
                  spreadRadius: effectiveElevation / 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: effectiveElevation,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    // Add interactivity if needed
    if (isInteractive || onTap != null) {
      cardWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppConfig.defaultBorderRadius,
          onTap: onTap,
          hoverColor: effectiveBorderColor.withOpacity(0.05),
          splashColor: effectiveBorderColor.withOpacity(0.1),
          child: cardWidget,
        ),
      );
    }

    // Add animations if enabled
    if (enableAnimations) {
      cardWidget = cardWidget
          .animate()
          .fadeIn(duration: AppConfig.animationDuration)
          .slideY(
            begin: 0.1,
            end: 0,
            duration: AppConfig.animationDuration,
            curve: Curves.easeOutCubic,
          );
    }

    return cardWidget;
  }
}

// Specialized cyber card variants
class GlowingCyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final double intensity;

  const GlowingCyberCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? AppTheme.primaryGreen;
    
    return Container(
      padding: padding ?? AppConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: AppConfig.defaultBorderRadius,
        border: Border.all(
          color: effectiveGlowColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveGlowColor.withOpacity(0.4 * intensity),
            blurRadius: 30 * intensity,
            spreadRadius: 4 * intensity,
          ),
          BoxShadow(
            color: effectiveGlowColor.withOpacity(0.2 * intensity),
            blurRadius: 60 * intensity,
            spreadRadius: 8 * intensity,
          ),
        ],
      ),
      child: child,
    );
  }
}

class InteractiveCyberCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHoverEffects;

  const InteractiveCyberCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.enableHoverEffects = true,
  });

  @override
  State<InteractiveCyberCard> createState() => _InteractiveCyberCardState();
}

class _InteractiveCyberCardState extends State<InteractiveCyberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enableHoverEffects ? (_) => _onHover(true) : null,
      onExit: widget.enableHoverEffects ? (_) => _onHover(false) : null,
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          final hoverValue = _hoverAnimation.value;
          
          return Transform.scale(
            scale: 1.0 + (hoverValue * 0.02),
            child: Container(
              padding: widget.padding ?? AppConfig.cardPadding,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: AppConfig.defaultBorderRadius,
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(
                    0.3 + (hoverValue * 0.3),
                  ),
                  width: 1 + (hoverValue * 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(
                      0.1 + (hoverValue * 0.2),
                    ),
                    blurRadius: 20 + (hoverValue * 10),
                    spreadRadius: hoverValue * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppConfig.defaultBorderRadius,
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }
}