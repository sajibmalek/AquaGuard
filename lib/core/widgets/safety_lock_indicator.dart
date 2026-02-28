import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

/// Safety lock indicator with subtle red pulse when locked
class SafetyLockIndicator extends StatefulWidget {
  const SafetyLockIndicator({
    super.key,
    required this.isLocked,
    this.size = 24,
  });

  final bool isLocked;
  final double size;

  @override
  State<SafetyLockIndicator> createState() => _SafetyLockIndicatorState();
}

class _SafetyLockIndicatorState extends State<SafetyLockIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isLocked) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SafetyLockIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLocked && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLocked) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLocked ? AppTheme.statusCritical : AppTheme.statusNormal;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLocked ? _pulseAnimation.value : 1.0,
          child: Icon(
            widget.isLocked ? LucideIcons.lock : LucideIcons.unlock,
            size: widget.size,
            color: color,
          ),
        );
      },
    );
  }
}
