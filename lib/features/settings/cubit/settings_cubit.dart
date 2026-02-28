import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState {
  final SettingsStatus status;
  final String themeMode;
  final int refreshIntervalSeconds;
  final String? error;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.themeMode = 'system',
    this.refreshIntervalSeconds = 30,
    this.error,
  });

  bool get isLoading => status == SettingsStatus.loading;
  bool get isSuccess => status == SettingsStatus.success;
  bool get isError => status == SettingsStatus.error;
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _themeKey = 'theme_mode';
  static const _refreshKey = 'refresh_interval_seconds';

  Future<void> loadSettings() async {
    emit(const SettingsState(status: SettingsStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString(_themeKey) ?? 'system';
      final refresh = prefs.getInt(_refreshKey) ?? 30;
      emit(SettingsState(
        status: SettingsStatus.success,
        themeMode: theme,
        refreshIntervalSeconds: refresh,
      ));
    } catch (e) {
      emit(SettingsState(
        status: SettingsStatus.error,
        themeMode: state.themeMode,
        refreshIntervalSeconds: state.refreshIntervalSeconds,
        error: e.toString(),
      ));
    }
  }

  Future<void> setThemeMode(String mode) async {
    emit(const SettingsState(status: SettingsStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode);
      emit(SettingsState(
        status: SettingsStatus.success,
        themeMode: mode,
        refreshIntervalSeconds: state.refreshIntervalSeconds,
      ));
    } catch (e) {
      emit(SettingsState(
        status: SettingsStatus.error,
        themeMode: state.themeMode,
        refreshIntervalSeconds: state.refreshIntervalSeconds,
        error: e.toString(),
      ));
    }
  }

  Future<void> setRefreshInterval(int seconds) async {
    emit(const SettingsState(status: SettingsStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_refreshKey, seconds);
      emit(SettingsState(
        status: SettingsStatus.success,
        themeMode: state.themeMode,
        refreshIntervalSeconds: seconds,
      ));
    } catch (e) {
      emit(SettingsState(
        status: SettingsStatus.error,
        themeMode: state.themeMode,
        refreshIntervalSeconds: state.refreshIntervalSeconds,
        error: e.toString(),
      ));
    }
  }
}
