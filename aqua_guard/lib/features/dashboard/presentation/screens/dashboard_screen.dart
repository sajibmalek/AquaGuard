import 'package:flutter/material.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/models/aquarium_models.dart';
import '../../../../core/models/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.stateOf(context);
    final aquarium = state.aquarium;
    final wq = aquarium.waterQuality;
    final isOnline = aquarium.isOnline;

    return CustomScrollView(
      slivers: [
        // ── Offline Banner ─────────────────────────────
        if (!isOnline)
          SliverToBoxAdapter(
            child: OfflineBanner(lastSynced: aquarium.lastUpdated),
          ),

        // ── Device Status Row ──────────────────────────
        SliverToBoxAdapter(
          child: _DeviceStatusBar(aquarium: aquarium),
        ),

        // ── Section: Water Parameters ──────────────────
        const SliverToBoxAdapter(child: SectionLabel('Water Parameters')),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _MetricCard(
                icon: Icons.thermostat_rounded,
                label: 'Temperature',
                value: '${wq.temperature.toStringAsFixed(1)}°C',
                status: wq.temperatureStatus,
                detail: 'Target 24–28 °C',
              ),
              _MetricCard(
                icon: Icons.science_outlined,
                label: 'pH Level',
                value: wq.ph.toStringAsFixed(1),
                status: wq.phStatus,
                detail: 'Optimal 6.5–7.5',
              ),
              _MetricCard(
                icon: Icons.bubble_chart_outlined,
                label: 'CO₂',
                value: '${wq.co2Level.toStringAsFixed(0)} ppm',
                status: wq.co2Status,
                detail: 'Safe below 25 ppm',
              ),
              _MetricCard(
                icon: Icons.water_drop_outlined,
                label: 'Dissolved O₂',
                value: '${wq.dissolvedOxygen.toStringAsFixed(1)} mg/L',
                status: StatusLevel.normal,
                detail: 'Optimal > 6 mg/L',
              ),
            ],
          ),
        ),

        // ── Section: Biological Health ─────────────────
        const SliverToBoxAdapter(child: SectionLabel('Biological Health')),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _HealthSummaryCard(
                icon: Icons.set_meal_outlined,
                label: 'Fish Health',
                score: aquarium.fishHealth.score,
                summary: aquarium.fishHealth.summary,
                status: aquarium.fishHealth.status,
              ),
              const SizedBox(height: 12),
              _HealthSummaryCard(
                icon: Icons.grass_outlined,
                label: 'Plant Health',
                score: aquarium.plantHealth.score,
                summary: aquarium.plantHealth.summary,
                status: aquarium.plantHealth.status,
              ),
              const SizedBox(height: 12),
              _RiskCard(
                label: 'Algae Risk',
                icon: Icons.eco_outlined,
                riskPercent: aquarium.plantHealth.algaeRiskPercent,
                status: aquarium.plantHealth.algaeStatus,
              ),
              const SizedBox(height: 12),
              _RiskCard(
                label: 'CO₂ Risk',
                icon: Icons.air_outlined,
                riskPercent: (wq.co2Level / 40 * 100).clamp(0, 100),
                status: wq.co2Status,
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Device Status Bar
// ─────────────────────────────────────────────
class _DeviceStatusBar extends StatelessWidget {
  final AquariumModel aquarium;
  const _DeviceStatusBar({required this.aquarium});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = deviceStatusColor(aquarium.deviceStatus);
    final statusLabel = aquarium.isOnline ? 'Online' : 'Offline';
    final timeAgo = _formatAgo(aquarium.lastUpdated);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Pulsing status dot
              _StatusDot(color: statusColor, animate: aquarium.isOnline),
              const SizedBox(width: 10),
              Text(
                statusLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Updated $timeAgo',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} h ago';
  }
}

class _StatusDot extends StatefulWidget {
  final Color color;
  final bool animate;
  const _StatusDot({required this.color, required this.animate});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: widget.animate
              ? [BoxShadow(color: widget.color.withValues(alpha: 0.4), blurRadius: _scale.value * 4)]
              : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Metric Card
// ─────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final StatusLevel status;
  final String detail;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = statusColor(context, status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Text(
                value,
                key: ValueKey(value),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                StatusChip(level: status),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Health Summary Card
// ─────────────────────────────────────────────
class _HealthSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double score;
  final String summary;
  final StatusLevel status;

  const _HealthSummaryCard({
    required this.icon,
    required this.label,
    required this.score,
    required this.summary,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = statusColor(context, status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                StatusChip(level: status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricProgressBar(
                    value: score / 100,
                    status: status,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Risk Card
// ─────────────────────────────────────────────
class _RiskCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double riskPercent;
  final StatusLevel status;

  const _RiskCard({
    required this.label,
    required this.icon,
    required this.riskPercent,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = statusColor(context, status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MetricProgressBar(value: riskPercent / 100, status: status),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              children: [
                Text(
                  '${riskPercent.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                StatusChip(level: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
