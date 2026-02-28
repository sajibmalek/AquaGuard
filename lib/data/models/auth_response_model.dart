import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final int? expiresIn;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: json['expires_in'] as int?,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user, expiresIn];
}
