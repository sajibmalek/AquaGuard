import '../models/aquarium_models.dart';
import '../enums/app_enums.dart';

/// Singleton mock data provider – replaces real Cubits/repositories
/// while keeping the UI fully functional.
class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  AquariumModel get primaryTank => AquariumModel(
        id: 'tank-01',
        name: 'Reef Tank 01',
        deviceStatus: DeviceStatus.online,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
        waterQuality: const WaterQualityModel(
          temperature: 26.4,
          ph: 7.2,
          ammonia: 0.01,
          nitrite: 0.0,
          nitrate: 8.5,
          dissolvedOxygen: 7.8,
          co2Level: 22.0,
          turbidity: 1.2,
        ),
        fishHealth: const FishHealthModel(
          score: 88,
          summary: 'Fish are active and feeding normally.',
          status: StatusLevel.normal,
          observations: [
            'No visible stress indicators',
            'Normal fin condition',
            'Good appetite observed',
          ],
        ),
        plantHealth: const PlantHealthModel(
          score: 74,
          summary: 'Plants growing steadily. CO₂ slightly low.',
          status: StatusLevel.warning,
          algaeRiskPercent: 32,
          algaeStatus: StatusLevel.warning,
        ),
        controls: const DeviceControlModel(
          lightOn: true,
          pumpOn: true,
          targetTemperature: 26.5,
          heaterActive: false,
        ),
        alerts: [
          AlertModel(
            id: 'a1',
            title: 'pH Fluctuation Detected',
            body: 'pH dropped to 6.8 at 14:30. Monitor closely.',
            severity: AlertSeverity.warning,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: false,
          ),
          AlertModel(
            id: 'a2',
            title: 'CO₂ Level Rising',
            body: 'CO₂ increased to 28 ppm. Check diffuser.',
            severity: AlertSeverity.warning,
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            isRead: false,
          ),
          AlertModel(
            id: 'a3',
            title: 'Light Schedule Updated',
            body: 'Photoperiod changed to 10 h by Admin.',
            severity: AlertSeverity.info,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
          ),
        ],
      );

  List<HistoryPoint> get last24hHistory {
    final now = DateTime.now();
    return List.generate(24, (i) {
      final t = now.subtract(Duration(hours: 23 - i));
      return HistoryPoint(
        time: t,
        temperature: 26.0 + (i % 5) * 0.3,
        ph: 7.1 + (i % 4) * 0.05,
        co2Level: 20.0 + (i % 6) * 1.5,
        dissolvedOxygen: 7.5 + (i % 3) * 0.2,
      );
    });
  }
}
