import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/history_point_model.dart';

/// Reusable line chart for temperature, pH, ORP, TDS, health trends.
/// Supports 24h / 7d / 30d ranges with gradient and animation.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.data,
    required this.unit,
    this.minY,
    this.maxY,
    this.color,
  });

  final List<HistoryPointModel> data;
  final String unit;
  final double? minY;
  final double? maxY;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = color ?? theme.colorScheme.primary;

    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data')),
      );
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final yMin = minY ?? (data.map((d) => d.value).reduce((a, b) => a < b ? a : b) - 1);
    final yMax = maxY ?? (data.map((d) => d.value).reduce((a, b) => a > b ? a : b) + 1);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.2),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, meta) => Text(
                  v.toStringAsFixed(0),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
