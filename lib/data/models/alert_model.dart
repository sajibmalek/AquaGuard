import 'package:equatable/equatable.dart';

class AlertModel extends Equatable {
  const AlertModel({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.acknowledged = false,
    this.tankId,
  });

  final String id;
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final bool acknowledged;
  final String? tankId;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      acknowledged: json['acknowledged'] as bool? ?? false,
      tankId: json['tank_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, type, message, severity, timestamp, acknowledged, tankId];
}
