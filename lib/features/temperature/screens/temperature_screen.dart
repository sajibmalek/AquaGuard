import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/trend_line_chart.dart';
import '../cubit/temperature_cubit.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key, required this.tankId});

  final String tankId;

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = TemperatureCubit();
        c.loadTemperature(widget.tankId).then((_) => c.loadHistory(widget.tankId));
        return c;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Temperature')),
        body: BlocBuilder<TemperatureCubit, TemperatureState>(
          builder: (context, state) {
            if (state.isLoading && state.history.isEmpty && state.currentValue == 0) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(LucideIcons.thermometer, size: 48, color: AppTheme.statusNormal),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.currentValue.toStringAsFixed(1)} °C',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Current reading',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Trend',
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
                      final r = s.first;
                      context.read<TemperatureCubit>().loadHistory(widget.tankId, range: r);
                    },
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    data: state.history,
                    unit: '°C',
                    minY: 20,
                    maxY: 30,
                    color: AppTheme.statusNormal,
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
