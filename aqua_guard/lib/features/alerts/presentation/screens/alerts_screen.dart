import 'package:flutter/material.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/models/aquarium_models.dart';
import '../../../../core/models/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final state = notifier.state;
    final alerts = state.aquarium.alerts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          if (alerts.any((a) => !a.isRead))
            TextButton(
              onPressed: notifier.markAllAlertsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: alerts.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: 'No alerts',
              subtitle: 'All parameters are within safe ranges.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (ctx, i) {
                final alert = alerts[i];
                return _AlertTile(
                  alert: alert,
                  onTap: () => notifier.markAlertRead(alert.id),
                );
              },
            ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;

  const _AlertTile({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _severityColor(alert.severity);
    final icon = _severityIcon(alert.severity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: alert.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                fontSize: 14,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (!alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(alert.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _severityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.critical:
        return AquaColors.statusRed;
      case AlertSeverity.warning:
        return AquaColors.statusAmber;
      case AlertSeverity.info:
        return const Color(0xFF1565C0);
    }
  }

  IconData _severityIcon(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.critical:
        return Icons.error_outline_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }
}
