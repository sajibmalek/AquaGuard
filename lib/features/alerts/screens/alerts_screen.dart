import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/models/alert_model.dart';
import '../cubit/alerts_cubit.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.tankId});

  final String tankId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlertsCubit()..loadAlerts(tankId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Alerts')),
        body: BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            if (state.isLoading && state.alerts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.bellOff, size: 48, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('No alerts', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.alerts.length,
              itemBuilder: (context, i) {
                final alert = state.alerts[i];
                return _AlertTile(alert: alert, tankId: tankId);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.tankId});

  final AlertModel alert;
  final String tankId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _severityIcon(alert.severity),
          color: _severityColor(alert.severity),
        ),
        title: Text(alert.message),
        subtitle: Text(alert.timestamp.toString()),
        trailing: alert.acknowledged
            ? null
            : TextButton(
                onPressed: () {
                  context.read<AlertsCubit>().acknowledgeAlert(tankId, alert.id);
                },
                child: const Text('Ack'),
              ),
      ),
    );
  }

  IconData _severityIcon(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return LucideIcons.alertTriangle;
      case 'warning':
        return LucideIcons.alertCircle;
      default:
        return LucideIcons.info;
    }
  }

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return const Color(0xFFC62828);
      case 'warning':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF1565C0);
    }
  }
}
