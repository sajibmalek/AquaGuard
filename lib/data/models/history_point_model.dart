import 'package:equatable/equatable.dart';

class HistoryPointModel extends Equatable {
  const HistoryPointModel({
    required this.timestamp,
    required this.value,
  });

  final DateTime timestamp;
  final double value;

  factory HistoryPointModel.fromJson(Map<String, dynamic> json) {
    return HistoryPointModel(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [timestamp, value];
}
