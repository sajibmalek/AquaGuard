import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/status_color_helper.dart';
import '../../../core/widgets/trend_line_chart.dart';
import '../cubit/health_cubit.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key, required this.tankId});

  final String tankId;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = HealthCubit();
        c.loadHealth(widget.tankId).then((_) => c.loadHistory(widget.tankId));
        return c;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Fish & Plant Health')),
        body: BlocBuilder<HealthCubit, HealthState>(
          builder: (context, state) {
            if (state.isLoading && state.fishHealthScore == 0) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _HealthCard(
                          icon: LucideIcons.fish,
                          label: 'Fish Health',
                          value: (state.fishHealthScore * 100).toStringAsFixed(0),
                          unit: '%',
                          color: getStatusColor(_scoreStatus(state.fishHealthScore)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HealthCard(
                          icon: LucideIcons.leaf,
                          label: 'Plant Health',
                          value: (state.plantHealthScore * 100).toStringAsFixed(0),
                          unit: '%',
                          color: getStatusColor(_scoreStatus(state.plantHealthScore)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _RiskChip(label: 'Algae Risk', value: state.algaeRiskLevel),
                      const SizedBox(width: 12),
                      _RiskChip(label: 'CO₂ Risk', value: state.co2RiskIndicator),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Health Trends',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '24h', label: Text('24h')),
                      ButtonSegment(value: '7d', label: Text('7d')),
                      ButtonSegment(value: '30d', label: Text('30d')),
                    ],
                    selected: {state.range},
                    onSelectionChanged: (s) {
                      context.read<HealthCubit>().loadHistory(widget.tankId, range: s.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    data: state.fishHistory,
                    unit: '%',
                    minY: 0,
                    maxY: 1,
                    color: AppTheme.statusNormal,
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    data: state.plantHistory,
                    unit: '%',
                    minY: 0,
                    maxY: 1,
                    color: AppTheme.statusWarning,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _scoreStatus(double s) {
    if (s < 0.5) return 'critical';
    if (s < 0.8) return 'warning';
    return 'normal';
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              '$value$unit',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value'),
    );
  }
}
