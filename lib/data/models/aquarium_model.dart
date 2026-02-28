import 'package:equatable/equatable.dart';

class AquariumModel extends Equatable {
  const AquariumModel({
    required this.id,
    required this.tankNumber,
    required this.name,
    this.deviceOnline = false,
    this.lastUpdated,
  });

  final String id;
  final int tankNumber;
  final String name;
  final bool deviceOnline;
  final DateTime? lastUpdated;

  factory AquariumModel.fromJson(Map<String, dynamic> json) {
    return AquariumModel(
      id: json['id'] as String,
      tankNumber: json['tank_number'] as int,
      name: json['name'] as String,
      deviceOnline: json['device_online'] as bool? ?? false,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tank_number': tankNumber,
        'name': name,
        'device_online': deviceOnline,
        'last_updated': lastUpdated?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, tankNumber, name, deviceOnline, lastUpdated];
}
