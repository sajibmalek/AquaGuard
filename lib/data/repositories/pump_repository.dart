import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../services/api_service.dart';

class PumpRepository {
  PumpRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<bool> getPumpState(String tankId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      return MockData.pumpState(tankId);
    }
    return _api.getPumpState(tankId);
  }

  Future<void> setPumpState(String tankId, bool state) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      return;
    }
    await _api.setPumpState(tankId, state);
  }
}
