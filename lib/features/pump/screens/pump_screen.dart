import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/pump_cubit.dart';

class PumpScreen extends StatelessWidget {
  const PumpScreen({super.key, required this.tankId});

  final String tankId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PumpCubit()..loadState(tankId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Pump')),
        body: BlocBuilder<PumpCubit, PumpState>(
          builder: (context, state) {
            if (state.isLoading && !state.isError) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: state.isOn
                            ? AppTheme.statusNormal.withValues(alpha: 0.15)
                            : AppTheme.statusOffline.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.gauge,
                        size: 80,
                        color: state.isOn ? AppTheme.statusNormal : AppTheme.statusOffline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.isOn ? 'Pump is ON' : 'Pump is OFF',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 32),
                    SwitchListTile(
                      title: const Text('Toggle Pump'),
                      subtitle: Text(state.isOn ? 'Tap to turn off' : 'Tap to turn on'),
                      value: state.isOn,
                      onChanged: state.isLoading
                          ? null
                          : (v) {
                              context.read<PumpCubit>().setState(tankId, v);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
