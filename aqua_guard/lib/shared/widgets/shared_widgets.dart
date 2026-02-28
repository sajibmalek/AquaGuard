import 'package:flutter/material.dart';
import '../../core/enums/app_enums.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// Status Chip
// ─────────────────────────────────────────────
class StatusChip extends StatelessWidget {
  final StatusLevel level;
  final String? label;

  const StatusChip({super.key, required this.level, this.label});

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(level);
    final fg = _fgColor(level);
    final text = label ?? level.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(level), size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color _bgColor(StatusLevel level) {
    switch (level) {
      case StatusLevel.normal:
        return AquaColors.statusGreenLight;
      case StatusLevel.warning:
        return AquaColors.statusAmberLight;
      case StatusLevel.critical:
        return AquaColors.statusRedLight;
      case StatusLevel.unknown:
        return Colors.grey.shade100;
    }
  }

  Color _fgColor(StatusLevel level) {
    switch (level) {
      case StatusLevel.normal:
        return AquaColors.statusGreen;
      case StatusLevel.warning:
        return AquaColors.statusAmber;
      case StatusLevel.critical:
        return AquaColors.statusRed;
      case StatusLevel.unknown:
        return Colors.grey.shade700;
    }
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Metric Value Text (animated)
// ─────────────────────────────────────────────
class AnimatedMetricValue extends StatelessWidget {
  final String value;
  final String unit;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;

  const AnimatedMetricValue({
    super.key,
    required this.value,
    required this.unit,
    this.valueStyle,
    this.unitStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Row(
        key: ValueKey(value),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: valueStyle ??
                tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
          ),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              unit,
              style: unitStyle ??
                  tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Offline Banner
// ─────────────────────────────────────────────
class OfflineBanner extends StatelessWidget {
  final DateTime? lastSynced;

  const OfflineBanner({super.key, this.lastSynced});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeAgo = lastSynced != null ? _formatAgo(lastSynced!) : 'Unknown';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AquaColors.statusRed,
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Device offline · Last synced $timeAgo',
              style: cs.brightness == Brightness.dark
                  ? const TextStyle(color: Colors.white, fontSize: 13)
                  : const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }
}

// ─────────────────────────────────────────────
// Info Row (label : value)
// ─────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State Widget
// ─────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Metric Progress Bar
// ─────────────────────────────────────────────
class MetricProgressBar extends StatelessWidget {
  final double value; // 0.0–1.0
  final StatusLevel status;
  final Color? overrideColor;

  const MetricProgressBar({
    super.key,
    required this.value,
    required this.status,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = overrideColor ?? _color(status);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  Color _color(StatusLevel level) {
    switch (level) {
      case StatusLevel.normal:
        return AquaColors.statusGreen;
      case StatusLevel.warning:
        return AquaColors.statusAmber;
      case StatusLevel.critical:
        return AquaColors.statusRed;
      case StatusLevel.unknown:
        return Colors.grey;
    }
  }
}
