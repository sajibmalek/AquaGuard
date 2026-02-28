import '../models/auth_response_model.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';

class AuthRepository {
  AuthRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _api = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final ApiService _api;
  final TokenStorageService _tokenStorage;

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _api.login(email, password);
    await _tokenStorage.saveToken(response.accessToken);
    await _tokenStorage.saveRefreshToken(response.refreshToken);
    return response;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  Future<String?> getStoredToken() => _tokenStorage.getToken();

  Future<void> clearToken() => _tokenStorage.clearAll();
}
