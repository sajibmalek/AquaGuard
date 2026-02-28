import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/lighting_cubit.dart';

class LightingScreen extends StatelessWidget {
  const LightingScreen({super.key, required this.tankId});

  final String tankId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LightingCubit()..loadState(tankId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Lighting')),
        body: BlocBuilder<LightingCubit, LightingState>(
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
                        LucideIcons.lightbulb,
                        size: 80,
                        color: state.isOn ? AppTheme.statusNormal : AppTheme.statusOffline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.isOn ? 'Light is ON' : 'Light is OFF',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 32),
                    SwitchListTile(
                      title: const Text('Toggle Light'),
                      subtitle: Text(state.isOn ? 'Tap to turn off' : 'Tap to turn on'),
                      value: state.isOn,
                      onChanged: state.isLoading
                          ? null
                          : (v) {
                              context.read<LightingCubit>().setState(tankId, v);
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
