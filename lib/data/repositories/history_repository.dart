import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../models/history_point_model.dart';
import '../services/api_service.dart';

class HistoryRepository {
  HistoryRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<HistoryPointModel>> getHistory(
    String tankId,
    String metric, {
    String range = '24h',
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.history(metric, range);
    }
    return _api.getHistory(tankId, metric, range: range);
  }
}
