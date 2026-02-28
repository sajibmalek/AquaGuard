import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/trend_line_chart.dart';
import '../cubit/water_quality_cubit.dart';

class WaterQualityScreen extends StatefulWidget {
  const WaterQualityScreen({super.key, required this.tankId});

  final String tankId;

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = WaterQualityCubit();
        c.loadWaterQuality(widget.tankId).then((_) => c.loadHistory(widget.tankId));
        return c;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Water Quality')),
        body: BlocBuilder<WaterQualityCubit, WaterQualityState>(
          builder: (context, state) {
            if (state.isLoading && state.waterQuality.ph == 0) {
              return const Center(child: CircularProgressIndicator());
            }
            final q = state.waterQuality;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(icon: LucideIcons.droplets, label: 'pH', value: q.ph.toStringAsFixed(1), unit: ''),
                      _MetricCard(icon: LucideIcons.activity, label: 'ORP', value: q.orp.toStringAsFixed(0), unit: ' mV'),
                      _MetricCard(icon: LucideIcons.gauge, label: 'TDS', value: q.tds.toStringAsFixed(0), unit: ' ppm'),
                      _MetricCard(icon: LucideIcons.waves, label: 'Turbidity', value: q.turbidity.toStringAsFixed(1), unit: ' NTU'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'pH Trend',
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
                      context.read<WaterQualityCubit>().loadHistory(widget.tankId, range: s.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    data: state.phHistory,
                    unit: '',
                    minY: 6,
                    maxY: 8,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: AppTheme.statusNormal),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                '$value$unit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
