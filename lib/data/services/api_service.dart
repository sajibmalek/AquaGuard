import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/alert_model.dart';
import '../models/aquarium_model.dart';
import '../models/auth_response_model.dart';
import '../models/dashboard_model.dart';
import '../models/history_point_model.dart';

/// REST API service for AquaGuard backend
/// Handles all HTTP communication with FastAPI
class ApiService {
  ApiService({
    Dio? dio,
    String? baseUrl,
    String? token,
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
        _token = token {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(_AuthInterceptor(() => _token, _onTokenExpired));
  }

  final Dio _dio;
  final String _baseUrl;
  String? _token;
  void Function()? _onTokenExpired;

  void setToken(String? token) {
    _token = token;
  }

  void setOnTokenExpired(void Function() callback) {
    _onTokenExpired = callback;
  }

  // ─────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  // ─────────────────────────────────────────────────────────────────
  // AQUARIUMS
  // ─────────────────────────────────────────────────────────────────

  Future<List<AquariumModel>> getAquariums() async {
    final response = await _dio.get<List<dynamic>>('/aquariums');
    return (response.data ?? [])
        .map((e) => AquariumModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────
  // DASHBOARD
  // ─────────────────────────────────────────────────────────────────

  Future<DashboardModel> getDashboard(String tankId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/aquariums/$tankId/dashboard',
    );
    return DashboardModel.fromJson(response.data!);
  }

  // ─────────────────────────────────────────────────────────────────
  // TEMPERATURE
  // ─────────────────────────────────────────────────────────────────

  Future<double> getTemperature(String tankId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/aquariums/$tankId/temperature',
    );
    return (response.data?['value'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> setTemperatureTarget(String tankId, double target) async {
    await _dio.put(
      '/aquariums/$tankId/temperature/target',
      data: {'target': target},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // WATER QUALITY
  // ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWaterQuality(String tankId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/aquariums/$tankId/water-quality',
    );
    return response.data ?? {};
  }

  // ─────────────────────────────────────────────────────────────────
  // LIGHTING
  // ─────────────────────────────────────────────────────────────────

  Future<bool> getLightState(String tankId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/aquariums/$tankId/lighting',
    );
    return response.data?['state'] as bool? ?? false;
  }

  Future<void> setLightState(String tankId, bool state) async {
    await _dio.put(
      '/aquariums/$tankId/lighting',
      data: {'state': state},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PUMP
  // ─────────────────────────────────────────────────────────────────

  Future<bool> getPumpState(String tankId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/aquariums/$tankId/pump',
    );
    return response.data?['state'] as bool? ?? false;
  }

  Future<void> setPumpState(String tankId, bool state) async {
    await _dio.put(
      '/aquariums/$tankId/pump',
      data: {'state': state},
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ALERTS
  // ─────────────────────────────────────────────────────────────────

  Future<List<AlertModel>> getAlerts(String tankId, {int? limit}) async {
    final response = await _dio.get<List<dynamic>>(
      '/aquariums/$tankId/alerts',
      queryParameters: limit != null ? {'limit': limit} : null,
    );
    return (response.data ?? [])
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> acknowledgeAlert(String tankId, String alertId) async {
    await _dio.post('/aquariums/$tankId/alerts/$alertId/acknowledge');
  }

  // ─────────────────────────────────────────────────────────────────
  // HISTORY
  // ─────────────────────────────────────────────────────────────────

  Future<List<HistoryPointModel>> getHistory(
    String tankId,
    String metric, {
    String range = '24h',
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/aquariums/$tankId/history/$metric',
      queryParameters: {'range': range},
    );
    return (response.data ?? [])
        .map((e) => HistoryPointModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._getToken, this._onTokenExpired);

  final String? Function() _getToken;
  final void Function()? _onTokenExpired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _onTokenExpired?.call();
    }
    handler.next(err);
  }
}
