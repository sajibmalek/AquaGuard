import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Secure token storage using flutter_secure_storage
/// Falls back to SharedPreferences for refresh token metadata if needed
class TokenStorageService {
  TokenStorageService({
    FlutterSecureStorage? secureStorage,
  }) : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  Future<void> saveToken(String token) async {
    await _secure.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secure.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secure.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secure.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearAll() async {
    await _secure.delete(key: AppConstants.tokenKey);
    await _secure.delete(key: AppConstants.refreshTokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.selectedTankKey);
  }
}
