import 'package:equatable/equatable.dart';

class DashboardModel extends Equatable {
  const DashboardModel({
    required this.temperature,
    required this.heaterState,
    required this.pumpState,
    required this.lightState,
    required this.waterQuality,
    required this.fishHealthScore,
    required this.plantHealthScore,
    required this.algaeRiskLevel,
    required this.co2RiskIndicator,
    required this.safetyLockStatus,
    required this.deviceOnline,
    required this.lastUpdated,
  });

  final double temperature;
  final bool heaterState;
  final bool pumpState;
  final bool lightState;
  final WaterQualityModel waterQuality;
  final double fishHealthScore;
  final double plantHealthScore;
  final String algaeRiskLevel;
  final String co2RiskIndicator;
  final bool safetyLockStatus;
  final bool deviceOnline;
  final DateTime lastUpdated;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      heaterState: json['heater_state'] as bool? ?? false,
      pumpState: json['pump_state'] as bool? ?? false,
      lightState: json['light_state'] as bool? ?? false,
      waterQuality: WaterQualityModel.fromJson(
        json['water_quality'] as Map<String, dynamic>? ?? {},
      ),
      fishHealthScore: (json['fish_health_score'] as num?)?.toDouble() ?? 0.0,
      plantHealthScore:
          (json['plant_health_score'] as num?)?.toDouble() ?? 0.0,
      algaeRiskLevel: json['algae_risk_level'] as String? ?? 'unknown',
      co2RiskIndicator: json['co2_risk_indicator'] as String? ?? 'unknown',
      safetyLockStatus: json['safety_lock_status'] as bool? ?? false,
      deviceOnline: json['device_online'] as bool? ?? false,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        temperature,
        heaterState,
        pumpState,
        lightState,
        waterQuality,
        fishHealthScore,
        plantHealthScore,
        algaeRiskLevel,
        co2RiskIndicator,
        safetyLockStatus,
        deviceOnline,
        lastUpdated,
      ];
}

class WaterQualityModel extends Equatable {
  const WaterQualityModel({
    this.ph = 0.0,
    this.orp = 0.0,
    this.tds = 0.0,
    this.turbidity = 0.0,
  });

  final double ph;
  final double orp;
  final double tds;
  final double turbidity;

  factory WaterQualityModel.fromJson(Map<String, dynamic> json) {
    return WaterQualityModel(
      ph: (json['ph'] as num?)?.toDouble() ?? 0.0,
      orp: (json['orp'] as num?)?.toDouble() ?? 0.0,
      tds: (json['tds'] as num?)?.toDouble() ?? 0.0,
      turbidity: (json['turbidity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [ph, orp, tds, turbidity];
}
