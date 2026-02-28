/// Application-wide constants for AquaGuard
class AppConstants {
  AppConstants._();

  static const String appName = 'AquaGuard';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.aquaguard.example.com',
  );

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String selectedTankKey = 'selected_tank_id';
}
