import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/token_storage_service.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  bool get isLoading => status == AuthStatus.loading;
  bool get isSuccess => status == AuthStatus.success;
  bool get isError => status == AuthStatus.error;
  bool get isAuthenticated => user != null;
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;
  final ApiService _api;
  final TokenStorageService _tokenStorage;

  AuthCubit({
    AuthRepository? authRepository,
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _authRepo = authRepository ?? AuthRepository(),
        _api = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        super(const AuthState()) {
    _api.setOnTokenExpired(_handleTokenExpired);
  }

  void _handleTokenExpired() {
    logout();
  }

  Future<void> dummyLogin() async {
    emit(const AuthState(status: AuthStatus.loading));

    await Future.delayed(const Duration(milliseconds: 300));

    const dummyUser = UserModel(
      id: 'dummy-1',
      email: 'demo@aquaguard.local',
      name: 'Demo User',
      role: UserRole.operator,
    );

    _api.setToken('dummy-jwt-token');
    emit(const AuthState(status: AuthStatus.success, user: dummyUser));
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      final response = await _authRepo.login(email, password);
      _api.setToken(response.accessToken);
      emit(AuthState(status: AuthStatus.success, user: response.user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      await _authRepo.logout();
      _api.setToken(null);
      emit(const AuthState(status: AuthStatus.initial));
    } catch (e) {
      await _tokenStorage.clearAll();
      _api.setToken(null);
      emit(const AuthState(status: AuthStatus.initial));
    }
  }

  Future<void> checkAuth() async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      final token = await _authRepo.getStoredToken();
      if (token == null) {
        emit(const AuthState(status: AuthStatus.initial));
        return;
      }
      _api.setToken(token);
      emit(const AuthState(status: AuthStatus.initial));
    } catch (e) {
      await _tokenStorage.clearAll();
      emit(const AuthState(status: AuthStatus.initial));
    }
  }
}
