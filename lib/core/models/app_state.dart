import 'package:flutter/material.dart';
import '../enums/app_enums.dart';
import '../models/aquarium_models.dart';
import '../models/mock_data_service.dart';

// ─────────────────────────────────────────────
// App State (replaces Cubit without changing business logic)
// ─────────────────────────────────────────────
class AppState {
  final UserRole currentRole;
  final AquariumModel aquarium;
  final bool isDarkMode;

  const AppState({
    required this.currentRole,
    required this.aquarium,
    required this.isDarkMode,
  });

  AppState copyWith({
    UserRole? currentRole,
    AquariumModel? aquarium,
    bool? isDarkMode,
  }) {
    return AppState(
      currentRole: currentRole ?? this.currentRole,
      aquarium: aquarium ?? this.aquarium,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// ─────────────────────────────────────────────
// InheritedNotifier – provides AppState to the whole tree
// ─────────────────────────────────────────────
class AppStateNotifier extends ChangeNotifier {
  AppState _state = AppState(
    currentRole: UserRole.admin,
    aquarium: MockDataService.instance.primaryTank,
    isDarkMode: false,
  );

  AppState get state => _state;

  void switchRole(UserRole role) {
    _state = _state.copyWith(currentRole: role);
    notifyListeners();
  }

  void toggleDarkMode() {
    _state = _state.copyWith(isDarkMode: !_state.isDarkMode);
    notifyListeners();
  }

  void toggleLight() {
    final updated = _state.aquarium.controls.copyWith(
      lightOn: !_state.aquarium.controls.lightOn,
    );
    _updateControls(updated);
  }

  void togglePump() {
    final updated = _state.aquarium.controls.copyWith(
      pumpOn: !_state.aquarium.controls.pumpOn,
    );
    _updateControls(updated);
  }

  void setTargetTemperature(double value) {
    final updated = _state.aquarium.controls.copyWith(targetTemperature: value);
    _updateControls(updated);
  }

  void markAlertRead(String alertId) {
    final alerts = _state.aquarium.alerts.map((a) {
      return a.id == alertId ? a.copyWith(isRead: true) : a;
    }).toList();
    _updateAlerts(alerts);
  }

  void markAllAlertsRead() {
    final alerts = _state.aquarium.alerts.map((a) => a.copyWith(isRead: true)).toList();
    _updateAlerts(alerts);
  }

  void _updateControls(DeviceControlModel controls) {
    // Normally this calls a repository. Here we update mock state only.
    _state = _state.copyWith(
      aquarium: _rebuildAquarium(controls: controls),
    );
    notifyListeners();
  }

  void _updateAlerts(List<AlertModel> alerts) {
    _state = _state.copyWith(
      aquarium: _rebuildAquarium(alerts: alerts),
    );
    notifyListeners();
  }

  AquariumModel _rebuildAquarium({
    DeviceControlModel? controls,
    List<AlertModel>? alerts,
  }) {
    final a = _state.aquarium;
    return AquariumModel(
      id: a.id,
      name: a.name,
      deviceStatus: a.deviceStatus,
      lastUpdated: a.lastUpdated,
      waterQuality: a.waterQuality,
      fishHealth: a.fishHealth,
      plantHealth: a.plantHealth,
      controls: controls ?? a.controls,
      alerts: alerts ?? a.alerts,
    );
  }
}

// ─────────────────────────────────────────────
// Provider widget
// ─────────────────────────────────────────────
class AppStateProvider extends InheritedNotifier<AppStateNotifier> {
  const AppStateProvider({
    super.key,
    required AppStateNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppStateNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }

  static AppState stateOf(BuildContext context) => of(context).state;
}
