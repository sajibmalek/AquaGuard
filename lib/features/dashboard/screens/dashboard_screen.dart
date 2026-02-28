import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/status_color_helper.dart';
import '../../../core/widgets/animated_status_card.dart';
import '../../../core/widgets/safety_lock_indicator.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../health/screens/health_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../lighting/screens/lighting_screen.dart';
import '../../pump/screens/pump_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../temperature/screens/temperature_screen.dart';
import '../../water_quality/screens/water_quality_screen.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.tankId});

  final String tankId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..loadDashboard(widget.tankId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state.dashboard == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SafetyLockIndicator(
                    isLocked: state.dashboard!.safetyLockStatus,
                    size: 22,
                  ),
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardContent(tankId: widget.tankId),
            TemperatureScreen(tankId: widget.tankId),
            WaterQualityScreen(tankId: widget.tankId),
            HealthScreen(tankId: widget.tankId),
            LightingScreen(tankId: widget.tankId),
            PumpScreen(tankId: widget.tankId),
            AlertsScreen(tankId: widget.tankId),
            HistoryScreen(tankId: widget.tankId),
            BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: const SettingsScreen(),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.thermometer),
              label: 'Temp',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.droplets),
              label: 'Water',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.heart),
              label: 'Health',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.lightbulb),
              label: 'Light',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.gauge),
              label: 'Pump',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.bell),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({this.tankId});

  final String? tankId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading && state.dashboard == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.isError && state.dashboard == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.alertCircle, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(state.error ?? 'Failed to load'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (tankId != null) {
                      context.read<DashboardCubit>().loadDashboard(tankId!);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final d = state.dashboard!;
        final tempStatus = _tempStatus(d.temperature);
        final phStatus = _phStatus(d.waterQuality.ph);
        final fishStatus = _scoreStatus(d.fishHealthScore);
        final plantStatus = _scoreStatus(d.plantHealthScore);

        return RefreshIndicator(
          onRefresh: () async {
            if (tankId != null) {
              context.read<DashboardCubit>().loadDashboard(tankId!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      d.deviceOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
                      size: 20,
                      color: d.deviceOnline ? AppTheme.statusNormal : AppTheme.statusOffline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      d.deviceOnline ? 'Device Online' : 'Device Offline',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: d.deviceOnline
                                ? AppTheme.statusNormal
                                : AppTheme.statusOffline,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'Updated ${_formatTime(d.lastUpdated)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: width,
                          child: AnimatedStatusCard(
                            title: 'Temperature',
                            value: d.temperature.toStringAsFixed(1),
                            unit: '°C',
                            status: tempStatus,
                            icon: LucideIcons.thermometer,
                            subtitle: d.heaterState ? 'Heater ON' : 'Heater OFF',
                            isOffline: !d.deviceOnline,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: AnimatedStatusCard(
                            title: 'pH',
                            value: d.waterQuality.ph.toStringAsFixed(1),
                            unit: '',
                            status: phStatus,
                            icon: LucideIcons.droplets,
                            isOffline: !d.deviceOnline,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: AnimatedStatusCard(
                            title: 'Fish Health',
                            value: (d.fishHealthScore * 100).toStringAsFixed(0),
                            unit: '%',
                            status: fishStatus,
                            icon: LucideIcons.fish,
                            isOffline: !d.deviceOnline,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: AnimatedStatusCard(
                            title: 'Plant Health',
                            value: (d.plantHealthScore * 100).toStringAsFixed(0),
                            unit: '%',
                            status: plantStatus,
                            icon: LucideIcons.leaf,
                            isOffline: !d.deviceOnline,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ControlChip(
                      icon: LucideIcons.lightbulb,
                      label: 'Light',
                      isOn: d.lightState,
                      disabled: !d.deviceOnline || d.safetyLockStatus,
                    ),
                    const SizedBox(width: 12),
                    _ControlChip(
                      icon: LucideIcons.gauge,
                      label: 'Pump',
                      isOn: d.pumpState,
                      disabled: !d.deviceOnline || d.safetyLockStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(
                      label: 'Algae Risk',
                      value: d.algaeRiskLevel,
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      label: 'CO₂ Risk',
                      value: d.co2RiskIndicator,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _tempStatus(double t) {
    if (t < 22 || t > 28) return 'critical';
    if (t < 24 || t > 26) return 'warning';
    return 'normal';
  }

  String _phStatus(double ph) {
    if (ph < 6.0 || ph > 8.0) return 'critical';
    if (ph < 6.5 || ph > 7.5) return 'warning';
    return 'normal';
  }

  String _scoreStatus(double s) {
    if (s < 0.5) return 'critical';
    if (s < 0.8) return 'warning';
    return 'normal';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.isOn,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final bool isOn;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (disabled ? AppTheme.statusOffline : (isOn ? AppTheme.statusNormal : Colors.grey))
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: disabled ? AppTheme.statusOffline : (isOn ? AppTheme.statusNormal : Colors.grey)),
          const SizedBox(width: 8),
          Text('$label: ${isOn ? "ON" : "OFF"}'),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

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

