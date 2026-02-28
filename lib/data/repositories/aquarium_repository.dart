import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../models/aquarium_model.dart';
import '../services/api_service.dart';

class AquariumRepository {
  AquariumRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<AquariumModel>> getAquariums() async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.aquariums;
    }
    return _api.getAquariums();
  }
}
