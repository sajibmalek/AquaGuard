import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/widgets/trend_line_chart.dart';
import '../cubit/history_cubit.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.tankId});

  final String tankId;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit()..loadHistory(widget.tankId),
      child: Scaffold(
        appBar: AppBar(title: const Text('History & Reports')),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state.isLoading && state.data.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metric',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'temperature', label: Text('Temp')),
                      ButtonSegment(value: 'ph', label: Text('pH')),
                      ButtonSegment(value: 'fish_health', label: Text('Fish')),
                      ButtonSegment(value: 'plant_health', label: Text('Plant')),
                    ],
                    selected: {state.metric},
                    onSelectionChanged: (s) {
                      context.read<HistoryCubit>().loadHistory(
                            widget.tankId,
                            metric: s.first,
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Range',
                    style: Theme.of(context).textTheme.titleSmall,
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
                      context.read<HistoryCubit>().loadHistory(
                            widget.tankId,
                            range: s.first,
                          );
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(LucideIcons.barChart2, size: 32, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${state.metric} (${state.range})', style: Theme.of(context).textTheme.titleMedium),
                              Text('${state.data.length} data points', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    data: state.data,
                    unit: state.metric == 'temperature' ? '°C' : state.metric == 'ph' ? '' : '%',
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
