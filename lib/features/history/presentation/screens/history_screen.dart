import 'package:flutter/material.dart';
import '../../../../core/models/mock_data_service.dart';
import '../../../../core/models/aquarium_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedRange = '24h';
  static const _ranges = ['6h', '24h', '7d', '30d'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final history = MockDataService.instance.last24hHistory;

    return CustomScrollView(
      slivers: [
        // ── Range Selector ───────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Time Range',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          fontSize: 14),
                    ),
                    const Spacer(),
                    ..._ranges.map((r) {
                      final sel = r == _selectedRange;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRange = r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? cs.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? cs.onPrimary : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Summary Stats ────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Parameter Summary')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _SummaryCard(history: history),
          ),
        ),

        // ── History List ─────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Event Log')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final point = history[history.length - 1 - i];
                return _HistoryRow(point: point, index: i);
              },
              childCount: history.length.clamp(0, 12),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final List<HistoryPoint> history;
  const _SummaryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    double avgTemp = history.map((h) => h.temperature).reduce((a, b) => a + b) /
        history.length;
    double avgPh =
        history.map((h) => h.ph).reduce((a, b) => a + b) / history.length;
    double avgCo2 =
        history.map((h) => h.co2Level).reduce((a, b) => a + b) / history.length;
    double avgDo = history
            .map((h) => h.dissolvedOxygen)
            .reduce((a, b) => a + b) /
        history.length;

    double maxTemp = history.map((h) => h.temperature).reduce((a, b) => a > b ? a : b);
    double minTemp = history.map((h) => h.temperature).reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _StatChip(
                  label: 'Avg Temp',
                  value: '${avgTemp.toStringAsFixed(1)}°C',
                  icon: Icons.thermostat_rounded,
                  color: const Color(0xFFE53935),
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Avg pH',
                  value: avgPh.toStringAsFixed(2),
                  icon: Icons.science_outlined,
                  color: const Color(0xFF1E88E5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  label: 'Avg CO₂',
                  value: '${avgCo2.toStringAsFixed(0)} ppm',
                  icon: Icons.air_outlined,
                  color: const Color(0xFF43A047),
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Avg O₂',
                  value: '${avgDo.toStringAsFixed(1)} mg/L',
                  icon: Icons.water_drop_outlined,
                  color: const Color(0xFF7B1FA2),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature Range',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${minTemp.toStringAsFixed(1)}°C – ${maxTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// History Row
// ─────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final HistoryPoint point;
  final int index;

  const _HistoryRow({required this.point, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hour = point.time.hour.toString().padLeft(2, '0');
    final min = point.time.minute.toString().padLeft(2, '0');
    final isRecent = index == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Time
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      '$hour:$min',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isRecent ? cs.primary : cs.onSurface,
                      ),
                    ),
                    if (isRecent)
                      Text(
                        'Now',
                        style: TextStyle(
                            fontSize: 10,
                            color: cs.primary,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              Container(
                  width: 1, height: 30, color: cs.outlineVariant, margin: const EdgeInsets.symmetric(horizontal: 12)),
              // Metrics
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _MiniMetric(
                      label: 'T',
                      value: '${point.temperature.toStringAsFixed(1)}°',
                      color: const Color(0xFFE53935),
                    ),
                    _MiniMetric(
                      label: 'pH',
                      value: point.ph.toStringAsFixed(1),
                      color: const Color(0xFF1E88E5),
                    ),
                    _MiniMetric(
                      label: 'CO₂',
                      value: '${point.co2Level.toStringAsFixed(0)}ppm',
                      color: const Color(0xFF43A047),
                    ),
                    _MiniMetric(
                      label: 'O₂',
                      value: point.dissolvedOxygen.toStringAsFixed(1),
                      color: const Color(0xFF7B1FA2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
