import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/models/aquarium_model.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../cubit/aquarium_cubit.dart';

class AquariumSelectionScreen extends StatefulWidget {
  const AquariumSelectionScreen({super.key});

  @override
  State<AquariumSelectionScreen> createState() => _AquariumSelectionScreenState();
}

class _AquariumSelectionScreenState extends State<AquariumSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AquariumCubit>().loadAquariums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Aquarium'),
      ),
      body: BlocConsumer<AquariumCubit, AquariumState>(
        listener: (context, state) {
          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Failed to load aquariums')),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.aquariums.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError && state.aquariums.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.alertCircle, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.error ?? 'Failed to load'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<AquariumCubit>().loadAquariums(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.aquariums.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fish, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No aquariums found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<AquariumCubit>().loadAquariums(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.aquariums.length,
              itemBuilder: (context, index) {
                final aquarium = state.aquariums[index];
                return _AquariumTile(
                  aquarium: aquarium,
                  onTap: () {
                    context.read<AquariumCubit>().selectAquarium(aquarium);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AuthCubit>(),
                          child: DashboardScreen(tankId: aquarium.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AquariumTile extends StatelessWidget {
  const _AquariumTile({
    required this.aquarium,
    required this.onTap,
  });

  final AquariumModel aquarium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            LucideIcons.fish,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text('Tank ${aquarium.tankNumber} - ${aquarium.name}'),
        subtitle: Row(
          children: [
            Icon(
              aquarium.deviceOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
              size: 16,
              color: aquarium.deviceOnline ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(aquarium.deviceOnline ? 'Online' : 'Offline'),
          ],
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: onTap,
      ),
    );
  }
}
