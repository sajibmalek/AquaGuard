import '../models/alert_model.dart';
import '../models/aquarium_model.dart';
import '../models/dashboard_model.dart';
import '../models/history_point_model.dart';

/// Mock data for full UI demo - no API/DB calls
class MockData {
  MockData._();

  static List<AquariumModel> get aquariums => [
        const AquariumModel(
          id: 'tank-1',
          tankNumber: 1,
          name: 'Reef Tank',
          deviceOnline: true,
          lastUpdated: null,
        ),
        const AquariumModel(
          id: 'tank-2',
          tankNumber: 2,
          name: 'Freshwater Community',
          deviceOnline: true,
          lastUpdated: null,
        ),
        const AquariumModel(
          id: 'tank-3',
          tankNumber: 3,
          name: 'Plant Aquarium',
          deviceOnline: false,
          lastUpdated: null,
        ),
      ];

  static DashboardModel dashboard(String tankId) {
    final now = DateTime.now();
    return DashboardModel(
      temperature: 25.2,
      heaterState: true,
      pumpState: true,
      lightState: true,
      waterQuality: const WaterQualityModel(ph: 7.2, orp: 350, tds: 180, turbidity: 2.1),
      fishHealthScore: 0.92,
      plantHealthScore: 0.85,
      algaeRiskLevel: 'low',
      co2RiskIndicator: 'normal',
      safetyLockStatus: false,
      deviceOnline: tankId != 'tank-3',
      lastUpdated: now.subtract(const Duration(minutes: 5)),
    );
  }

  static double temperature(String tankId) => 25.2;

  static Map<String, dynamic> waterQuality(String tankId) => {
        'ph': 7.2,
        'orp': 350.0,
        'tds': 180.0,
        'turbidity': 2.1,
      };

  static bool lightState(String tankId) => true;
  static bool pumpState(String tankId) => true;

  static List<AlertModel> alerts(String tankId) => [
        AlertModel(
          id: 'a1',
          type: 'temperature',
          message: 'Temperature slightly high - consider cooling',
          severity: 'warning',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          acknowledged: false,
          tankId: tankId,
        ),
        AlertModel(
          id: 'a2',
          type: 'ph',
          message: 'pH within normal range',
          severity: 'info',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          acknowledged: true,
          tankId: tankId,
        ),
      ];

  static List<HistoryPointModel> history(String metric, String range) {
    final now = DateTime.now();
    final count = range == '24h' ? 24 : range == '7d' ? 7 : 30;
    final interval = range == '24h'
        ? const Duration(hours: 1)
        : range == '7d'
            ? const Duration(days: 1)
            : const Duration(days: 1);

    final base = switch (metric) {
      'temperature' => 24.0,
      'ph' => 7.0,
      'orp' => 320.0,
      'tds' => 150.0,
      'turbidity' => 2.0,
      'fish_health' => 0.9,
      'plant_health' => 0.85,
      _ => 25.0,
    };

    return List.generate(count, (i) {
      final t = now.subtract(interval * (count - i));
      final variation = (i % 5 - 2) * 0.5;
      return HistoryPointModel(timestamp: t, value: base + variation);
    });
  }
}
