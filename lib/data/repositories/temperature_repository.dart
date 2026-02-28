import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../services/api_service.dart';

class TemperatureRepository {
  TemperatureRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<double> getTemperature(String tankId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.temperature(tankId);
    }
    return _api.getTemperature(tankId);
  }

  Future<void> setTemperatureTarget(String tankId, double target) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    await _api.setTemperatureTarget(tankId, target);
  }
}
