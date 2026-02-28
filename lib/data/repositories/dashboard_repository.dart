import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardRepository {
  DashboardRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<DashboardModel> getDashboard(String tankId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.dashboard(tankId);
    }
    return _api.getDashboard(tankId);
  }
}
