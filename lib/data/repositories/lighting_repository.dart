import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../services/api_service.dart';

class LightingRepository {
  LightingRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<bool> getLightState(String tankId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      return MockData.lightState(tankId);
    }
    return _api.getLightState(tankId);
  }

  Future<void> setLightState(String tankId, bool state) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      return;
    }
    await _api.setLightState(tankId, state);
  }
}
