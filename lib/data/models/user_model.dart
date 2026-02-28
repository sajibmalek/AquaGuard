import 'package:equatable/equatable.dart';

enum UserRole { admin, operator, viewer }

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _roleFromString(json['role'] as String?),
    );
  }

  static UserRole _roleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer;
    }
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isOperator => role == UserRole.operator || role == UserRole.admin;
  bool get isViewer => role == UserRole.viewer;

  @override
  List<Object?> get props => [id, email, name, role];
}
