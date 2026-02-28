import 'package:flutter/material.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/models/aquarium_models.dart';
import '../../../../core/models/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.stateOf(context);
    final aquarium = state.aquarium;
    final wq = aquarium.waterQuality;

    return CustomScrollView(
      slivers: [
        // ── Water Quality ────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Water Quality')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _WaterQualityCard(waterQuality: wq),
              const SizedBox(height: 12),
              _NutrientsCard(waterQuality: wq),
            ]),
          ),
        ),

        // ── Fish Health ──────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Fish Health')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _FishHealthCard(fishHealth: aquarium.fishHealth),
          ),
        ),

        // ── Plant Health ─────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Plant Health')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _PlantHealthCard(plantHealth: aquarium.plantHealth),
          ),
        ),

        // ── Trend Chart ──────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('24-Hour Trend')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverToBoxAdapter(
            child: _TrendChartCard(aquarium: aquarium),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Water Quality Card
// ─────────────────────────────────────────────
class _WaterQualityCard extends StatelessWidget {
  final WaterQualityModel waterQuality;
  const _WaterQualityCard({required this.waterQuality});

  @override
  Widget build(BuildContext context) {
    final wq = waterQuality;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(context, Icons.water_drop_outlined, 'Temperature & pH',
                wq.overallStatus),
            const SizedBox(height: 16),
            _ParameterRow(
              label: 'Temperature',
              value: '${wq.temperature.toStringAsFixed(1)} °C',
              progress: ((wq.temperature - 18) / (32 - 18)).clamp(0, 1),
              status: wq.temperatureStatus,
              hint: 'Optimal: 24–28 °C',
            ),
            const SizedBox(height: 14),
            _ParameterRow(
              label: 'pH Level',
              value: wq.ph.toStringAsFixed(2),
              progress: ((wq.ph - 5) / (10 - 5)).clamp(0, 1),
              status: wq.phStatus,
              hint: 'Optimal: 6.5–7.5',
            ),
            const SizedBox(height: 14),
            _ParameterRow(
              label: 'CO₂',
              value: '${wq.co2Level.toStringAsFixed(0)} ppm',
              progress: (wq.co2Level / 40).clamp(0, 1),
              status: wq.co2Status,
              hint: 'Safe: < 25 ppm',
            ),
            const SizedBox(height: 14),
            _ParameterRow(
              label: 'Dissolved O₂',
              value: '${wq.dissolvedOxygen.toStringAsFixed(1)} mg/L',
              progress: (wq.dissolvedOxygen / 12).clamp(0, 1),
              status: StatusLevel.normal,
              hint: 'Optimal: > 6 mg/L',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nutrients Card
// ─────────────────────────────────────────────
class _NutrientsCard extends StatelessWidget {
  final WaterQualityModel waterQuality;
  const _NutrientsCard({required this.waterQuality});

  @override
  Widget build(BuildContext context) {
    final wq = waterQuality;
    StatusLevel ammoniaStatus = wq.ammonia > 0.5
        ? StatusLevel.critical
        : wq.ammonia > 0.1
            ? StatusLevel.warning
            : StatusLevel.normal;
    StatusLevel nitriteStatus = wq.nitrite > 0.5
        ? StatusLevel.critical
        : wq.nitrite > 0.1
            ? StatusLevel.warning
            : StatusLevel.normal;
    StatusLevel nitrateStatus = wq.nitrate > 40
        ? StatusLevel.critical
        : wq.nitrate > 20
            ? StatusLevel.warning
            : StatusLevel.normal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(context, Icons.science_outlined, 'Nutrients & Waste',
                ammoniaStatus),
            const SizedBox(height: 16),
            _ParameterRow(
              label: 'Ammonia (NH₃)',
              value: '${wq.ammonia.toStringAsFixed(2)} ppm',
              progress: (wq.ammonia / 2.0).clamp(0, 1),
              status: ammoniaStatus,
              hint: 'Safe: < 0.1 ppm',
            ),
            const SizedBox(height: 14),
            _ParameterRow(
              label: 'Nitrite (NO₂)',
              value: '${wq.nitrite.toStringAsFixed(2)} ppm',
              progress: (wq.nitrite / 2.0).clamp(0, 1),
              status: nitriteStatus,
              hint: 'Safe: < 0.1 ppm',
            ),
            const SizedBox(height: 14),
            _ParameterRow(
              label: 'Nitrate (NO₃)',
              value: '${wq.nitrate.toStringAsFixed(1)} ppm',
              progress: (wq.nitrate / 80).clamp(0, 1),
              status: nitrateStatus,
              hint: 'Safe: < 20 ppm',
            ),
            const SizedBox(height: 14),
            _ParameterRow(
              label: 'Turbidity',
              value: '${wq.turbidity.toStringAsFixed(1)} NTU',
              progress: (wq.turbidity / 10).clamp(0, 1),
              status: wq.turbidity < 3
                  ? StatusLevel.normal
                  : wq.turbidity < 6
                      ? StatusLevel.warning
                      : StatusLevel.critical,
              hint: 'Clear: < 3 NTU',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Fish Health Card
// ─────────────────────────────────────────────
class _FishHealthCard extends StatelessWidget {
  final FishHealthModel fishHealth;
  const _FishHealthCard({required this.fishHealth});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
                context, Icons.set_meal_outlined, 'Fish Health Score', fishHealth.status),
            const SizedBox(height: 16),
            // Score ring area
            Row(
              children: [
                _ScoreRing(score: fishHealth.score, status: fishHealth.status),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fishHealth.summary,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              'Observations',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...fishHealth.observations.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 16, color: AquaColors.statusGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(o,
                          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Plant Health Card
// ─────────────────────────────────────────────
class _PlantHealthCard extends StatelessWidget {
  final PlantHealthModel plantHealth;
  const _PlantHealthCard({required this.plantHealth});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
                context, Icons.grass_outlined, 'Plant Health Score', plantHealth.status),
            const SizedBox(height: 16),
            Row(
              children: [
                _ScoreRing(score: plantHealth.score, status: plantHealth.status),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plantHealth.summary,
                        style: TextStyle(
                            fontSize: 13, color: cs.onSurface, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Algae Risk',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                ),
                StatusChip(level: plantHealth.algaeStatus),
              ],
            ),
            const SizedBox(height: 10),
            MetricProgressBar(
              value: plantHealth.algaeRiskPercent / 100,
              status: plantHealth.algaeStatus,
            ),
            const SizedBox(height: 6),
            Text(
              '${plantHealth.algaeRiskPercent.toInt()}% risk – '
              '${plantHealth.algaeStatus == StatusLevel.normal ? 'Keep phosphate and light balanced.' : 'Reduce photoperiod and check nutrient levels.'}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Trend Chart Card (sparkline-style)
// ─────────────────────────────────────────────
class _TrendChartCard extends StatefulWidget {
  final AquariumModel aquarium;
  const _TrendChartCard({required this.aquarium});

  @override
  State<_TrendChartCard> createState() => _TrendChartCardState();
}

class _TrendChartCardState extends State<_TrendChartCard> {
  int _selectedMetric = 0; // 0=Temp, 1=pH, 2=CO2, 3=DO

  static const _metrics = ['Temperature', 'pH', 'CO₂', 'Dissolved O₂'];
  static const _units = ['°C', '', 'ppm', 'mg/L'];
  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFF7B1FA2),
  ];

  List<double> _getValues() {
    final history = [
      [26.0, 26.3, 26.4, 26.2, 26.5, 26.6, 26.4, 26.3],
      [7.1, 7.2, 7.15, 7.18, 7.2, 7.22, 7.19, 7.2],
      [20.0, 21.5, 22.0, 23.0, 22.5, 21.0, 22.0, 22.0],
      [7.5, 7.6, 7.8, 7.7, 7.8, 7.9, 7.8, 7.8],
    ];
    return history[_selectedMetric];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final values = _getValues();
    final color = _colors[_selectedMetric];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metric selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_metrics.length, (i) {
                  final selected = i == _selectedMetric;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: FilterChip(
                        label: Text(_metrics[i]),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedMetric = i),
                        selectedColor: _colors[i].withValues(alpha: 0.15),
                        checkmarkColor: _colors[i],
                        labelStyle: TextStyle(
                          color: selected ? _colors[i] : cs.onSurfaceVariant,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: selected ? _colors[i] : cs.outlineVariant,
                          width: selected ? 1.5 : 1,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Sparkline chart
            SizedBox(
              height: 120,
              child: _SparklineChart(values: values, color: color),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('8 hours ago',
                    style:
                        TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                Text(
                  'Min: ${values.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)} ${_units[_selectedMetric]}   '
                  'Max: ${values.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} ${_units[_selectedMetric]}',
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600),
                ),
                Text('Now',
                    style:
                        TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sparkline Chart (Custom Paint)
// ─────────────────────────────────────────────
class _SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const _SparklineChart({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs();
    final effectiveRange = range < 0.001 ? 1.0 : range * 1.2;
    final padding = effectiveRange * 0.1;

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height -
          ((values[i] - min + padding) / (effectiveRange + padding * 2)) *
              size.height;
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final cpX = (prev.dx + curr.dx) / 2;
        fillPath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
      }
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw last point dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.last, 5, dotPaint);
    canvas.drawCircle(
        points.last,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

// ─────────────────────────────────────────────
// Score Ring
// ─────────────────────────────────────────────
class _ScoreRing extends StatelessWidget {
  final double score;
  final StatusLevel status;

  const _ScoreRing({required this.score, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(context, status);
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 7,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '${score.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Parameter Row
// ─────────────────────────────────────────────
class _ParameterRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final StatusLevel status;
  final String hint;

  const _ParameterRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.status,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13, color: cs.onSurface),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: cs.onSurface),
            ),
            const SizedBox(width: 8),
            StatusChip(level: status),
          ],
        ),
        const SizedBox(height: 6),
        MetricProgressBar(value: progress, status: status),
        const SizedBox(height: 4),
        Text(hint,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Card header helper
// ─────────────────────────────────────────────
Widget _cardHeader(
    BuildContext context, IconData icon, String title, StatusLevel status) {
  final cs = Theme.of(context).colorScheme;
  final color = statusColor(context, status);
  return Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 8),
      Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface),
      ),
      const Spacer(),
      StatusChip(level: status),
    ],
  );
}
