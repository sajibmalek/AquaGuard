import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../services/api_service.dart';

class WaterQualityRepository {
  WaterQualityRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<Map<String, dynamic>> getWaterQuality(String tankId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.waterQuality(tankId);
    }
    return _api.getWaterQuality(tankId);
  }
}
