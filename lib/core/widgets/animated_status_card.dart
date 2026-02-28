import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/status_color_helper.dart';

/// Animated status card with status-based color transitions
class AnimatedStatusCard extends StatefulWidget {
  const AnimatedStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    this.icon,
    this.subtitle,
    this.isOffline = false,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final String status;
  final IconData? icon;
  final String? subtitle;
  final bool isOffline;
  final VoidCallback? onTap;

  @override
  State<AnimatedStatusCard> createState() => _AnimatedStatusCardState();
}

class _AnimatedStatusCardState extends State<AnimatedStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOffline
        ? AppTheme.statusOffline
        : getStatusColor(widget.status);
    final opacity = widget.isOffline ? 0.6 : 1.0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Opacity(
        opacity: opacity,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (widget.icon != null)
                        Icon(
                          widget.icon,
                          size: 24,
                          color: color,
                        ),
                      if (widget.icon != null) const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.status.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.unit,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
