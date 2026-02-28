import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../models/alert_model.dart';
import '../services/api_service.dart';

class AlertRepository {
  AlertRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<AlertModel>> getAlerts(String tankId, {int? limit}) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final list = MockData.alerts(tankId);
      return limit != null ? list.take(limit).toList() : list;
    }
    return _api.getAlerts(tankId, limit: limit);
  }

  Future<void> acknowledgeAlert(String tankId, String alertId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      return;
    }
    await _api.acknowledgeAlert(tankId, alertId);
  }
}
