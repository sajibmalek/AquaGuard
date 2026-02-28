import '../enums/app_enums.dart';

// ─────────────────────────────────────────────
// Aquarium / Tank
// ─────────────────────────────────────────────
class AquariumModel {
  final String id;
  final String name;
  final DeviceStatus deviceStatus;
  final DateTime lastUpdated;
  final WaterQualityModel waterQuality;
  final FishHealthModel fishHealth;
  final PlantHealthModel plantHealth;
  final DeviceControlModel controls;
  final List<AlertModel> alerts;

  const AquariumModel({
    required this.id,
    required this.name,
    required this.deviceStatus,
    required this.lastUpdated,
    required this.waterQuality,
    required this.fishHealth,
    required this.plantHealth,
    required this.controls,
    required this.alerts,
  });

  bool get isOnline => deviceStatus == DeviceStatus.online;
  int get unreadAlerts => alerts.where((a) => !a.isRead).length;
}

// ─────────────────────────────────────────────
// Water Quality
// ─────────────────────────────────────────────
class WaterQualityModel {
  final double temperature; // °C
  final double ph;
  final double ammonia; // ppm
  final double nitrite; // ppm
  final double nitrate; // ppm
  final double dissolvedOxygen; // mg/L
  final double co2Level; // ppm
  final double turbidity; // NTU

  const WaterQualityModel({
    required this.temperature,
    required this.ph,
    required this.ammonia,
    required this.nitrite,
    required this.nitrate,
    required this.dissolvedOxygen,
    required this.co2Level,
    required this.turbidity,
  });

  StatusLevel get temperatureStatus {
    if (temperature < 22 || temperature > 30) return StatusLevel.critical;
    if (temperature < 24 || temperature > 28) return StatusLevel.warning;
    return StatusLevel.normal;
  }

  StatusLevel get phStatus {
    if (ph < 6.0 || ph > 8.5) return StatusLevel.critical;
    if (ph < 6.5 || ph > 7.8) return StatusLevel.warning;
    return StatusLevel.normal;
  }

  StatusLevel get co2Status {
    if (co2Level > 35) return StatusLevel.critical;
    if (co2Level > 25) return StatusLevel.warning;
    return StatusLevel.normal;
  }

  StatusLevel get overallStatus {
    final statuses = [temperatureStatus, phStatus, co2Status];
    if (statuses.any((s) => s == StatusLevel.critical)) return StatusLevel.critical;
    if (statuses.any((s) => s == StatusLevel.warning)) return StatusLevel.warning;
    return StatusLevel.normal;
  }
}

// ─────────────────────────────────────────────
// Fish Health
// ─────────────────────────────────────────────
class FishHealthModel {
  final double score; // 0–100
  final String summary;
  final StatusLevel status;
  final List<String> observations;

  const FishHealthModel({
    required this.score,
    required this.summary,
    required this.status,
    required this.observations,
  });
}

// ─────────────────────────────────────────────
// Plant Health
// ─────────────────────────────────────────────
class PlantHealthModel {
  final double score; // 0–100
  final String summary;
  final StatusLevel status;
  final double algaeRiskPercent; // 0–100
  final StatusLevel algaeStatus;

  const PlantHealthModel({
    required this.score,
    required this.summary,
    required this.status,
    required this.algaeRiskPercent,
    required this.algaeStatus,
  });
}

// ─────────────────────────────────────────────
// Device Controls
// ─────────────────────────────────────────────
class DeviceControlModel {
  final bool lightOn;
  final bool pumpOn;
  final double targetTemperature;
  final bool heaterActive;

  const DeviceControlModel({
    required this.lightOn,
    required this.pumpOn,
    required this.targetTemperature,
    required this.heaterActive,
  });

  DeviceControlModel copyWith({
    bool? lightOn,
    bool? pumpOn,
    double? targetTemperature,
    bool? heaterActive,
  }) {
    return DeviceControlModel(
      lightOn: lightOn ?? this.lightOn,
      pumpOn: pumpOn ?? this.pumpOn,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      heaterActive: heaterActive ?? this.heaterActive,
    );
  }
}

// ─────────────────────────────────────────────
// Alert
// ─────────────────────────────────────────────
class AlertModel {
  final String id;
  final String title;
  final String body;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  AlertModel copyWith({bool? isRead}) =>
      AlertModel(
        id: id,
        title: title,
        body: body,
        severity: severity,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
      );
}

// ─────────────────────────────────────────────
// History data point
// ─────────────────────────────────────────────
class HistoryPoint {
  final DateTime time;
  final double temperature;
  final double ph;
  final double co2Level;
  final double dissolvedOxygen;

  const HistoryPoint({
    required this.time,
    required this.temperature,
    required this.ph,
    required this.co2Level,
    required this.dissolvedOxygen,
  });
}
