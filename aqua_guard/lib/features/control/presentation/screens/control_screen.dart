import 'package:flutter/material.dart';
import '../../../../core/models/app_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final state = notifier.state;
    final aquarium = state.aquarium;
    final controls = aquarium.controls;
    final canControl = state.currentRole.canControl;
    final isOnline = aquarium.isOnline;
    // Effective controllability: must be online AND have role permission
    final canAct = canControl && isOnline;

    return CustomScrollView(
      slivers: [
        if (!isOnline)
          SliverToBoxAdapter(child: OfflineBanner(lastSynced: aquarium.lastUpdated)),

        if (!canControl)
          const SliverToBoxAdapter(child: _ViewerBanner()),

        // ── Section: Lighting ────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Lighting')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _ControlCard(
              icon: controls.lightOn
                  ? Icons.light_mode_rounded
                  : Icons.light_mode_outlined,
              title: 'Aquarium Light',
              subtitle: controls.lightOn
                  ? 'Light is currently ON'
                  : 'Light is currently OFF',
              iconColor: controls.lightOn
                  ? const Color(0xFFF9A825)
                  : null,
              trailing: _RoleAwareSwitch(
                value: controls.lightOn,
                canAct: canAct,
                onChanged: (_) => notifier.toggleLight(),
                viewerTooltip: canControl
                    ? 'Device is offline'
                    : 'Viewer role – read-only',
              ),
            ),
          ),
        ),

        // ── Section: Water Circulation ───────────────
        const SliverToBoxAdapter(child: SectionLabel('Water Circulation')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _ControlCard(
              icon: controls.pumpOn
                  ? Icons.water_rounded
                  : Icons.water_outlined,
              title: 'Circulation Pump',
              subtitle: controls.pumpOn
                  ? 'Pump running normally'
                  : 'Pump is stopped',
              iconColor: controls.pumpOn
                  ? const Color(0xFF0277BD)
                  : null,
              trailing: _RoleAwareSwitch(
                value: controls.pumpOn,
                canAct: canAct,
                onChanged: (_) => notifier.togglePump(),
                viewerTooltip: canControl
                    ? 'Device is offline'
                    : 'Viewer role – read-only',
              ),
            ),
          ),
        ),

        // ── Section: Temperature ─────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Temperature Control')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _TemperatureCard(
              currentTemp: aquarium.waterQuality.temperature,
              targetTemp: controls.targetTemperature,
              heaterActive: controls.heaterActive,
              canAct: canAct,
              onTargetChanged: notifier.setTargetTemperature,
              viewerTooltip: canControl
                  ? 'Device is offline'
                  : 'Viewer role – read-only',
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Viewer Banner
// ─────────────────────────────────────────────
class _ViewerBanner extends StatelessWidget {
  const _ViewerBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 18, color: cs.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Viewer mode – controls are read-only',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Generic Control Card
// ─────────────────────────────────────────────
class _ControlCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Widget trailing;

  const _ControlCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = iconColor ?? cs.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(icon, key: ValueKey(icon), color: effectiveColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Role-Aware Switch
// ─────────────────────────────────────────────
class _RoleAwareSwitch extends StatelessWidget {
  final bool value;
  final bool canAct;
  final ValueChanged<bool> onChanged;
  final String viewerTooltip;

  const _RoleAwareSwitch({
    required this.value,
    required this.canAct,
    required this.onChanged,
    required this.viewerTooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (canAct) {
      return Switch(value: value, onChanged: onChanged);
    }
    return Tooltip(
      message: viewerTooltip,
      child: Switch(
        value: value,
        onChanged: null, // visually disabled
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Temperature Control Card
// ─────────────────────────────────────────────
class _TemperatureCard extends StatefulWidget {
  final double currentTemp;
  final double targetTemp;
  final bool heaterActive;
  final bool canAct;
  final ValueChanged<double> onTargetChanged;
  final String viewerTooltip;

  const _TemperatureCard({
    required this.currentTemp,
    required this.targetTemp,
    required this.heaterActive,
    required this.canAct,
    required this.onTargetChanged,
    required this.viewerTooltip,
  });

  @override
  State<_TemperatureCard> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<_TemperatureCard> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.targetTemp;
  }

  @override
  void didUpdateWidget(_TemperatureCard old) {
    super.didUpdateWidget(old);
    if (old.targetTemp != widget.targetTemp) {
      _sliderValue = widget.targetTemp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tempColor = const Color(0xFFE53935);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tempColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.thermostat_rounded, color: tempColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heater / Chiller',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        widget.heaterActive ? 'Heating active' : 'Maintaining temperature',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Current vs Target
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TempDisplay(
                  label: 'Current',
                  value: '${widget.currentTemp.toStringAsFixed(1)}°C',
                  color: cs.onSurface,
                ),
                Container(width: 1, height: 40, color: cs.outlineVariant),
                _TempDisplay(
                  label: 'Target',
                  value: '${_sliderValue.toStringAsFixed(1)}°C',
                  color: tempColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Slider
            if (widget.canAct) ...[
              Tooltip(
                message: widget.canAct ? '' : widget.viewerTooltip,
                child: Slider(
                  value: _sliderValue,
                  min: 18.0,
                  max: 32.0,
                  divisions: 28,
                  label: '${_sliderValue.toStringAsFixed(1)}°C',
                  onChanged: widget.canAct
                      ? (v) => setState(() => _sliderValue = v)
                      : null,
                  onChangeEnd: widget.canAct ? widget.onTargetChanged : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('18°C', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    Text('32°C', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ] else ...[
              Tooltip(
                message: widget.viewerTooltip,
                child: Slider(
                  value: _sliderValue,
                  min: 18.0,
                  max: 32.0,
                  onChanged: null, // disabled
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('18°C', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    Text('32°C', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TempDisplay extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TempDisplay({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
