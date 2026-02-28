import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/history_point_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/history_repository.dart';

enum HealthStatus { initial, loading, success, error }

class HealthState {
  final HealthStatus status;
  final double fishHealthScore;
  final double plantHealthScore;
  final String algaeRiskLevel;
  final String co2RiskIndicator;
  final List<HistoryPointModel> fishHistory;
  final List<HistoryPointModel> plantHistory;
  final String range;
  final String? error;

  const HealthState({
    this.status = HealthStatus.initial,
    this.fishHealthScore = 0.0,
    this.plantHealthScore = 0.0,
    this.algaeRiskLevel = 'unknown',
    this.co2RiskIndicator = 'unknown',
    this.fishHistory = const [],
    this.plantHistory = const [],
    this.range = '24h',
    this.error,
  });

  bool get isLoading => status == HealthStatus.loading;
  bool get isSuccess => status == HealthStatus.success;
  bool get isError => status == HealthStatus.error;
}

class HealthCubit extends Cubit<HealthState> {
  final DashboardRepository _dashboardRepo;
  final HistoryRepository _historyRepo;

  HealthCubit({
    DashboardRepository? dashboardRepo,
    HistoryRepository? historyRepo,
  })  : _dashboardRepo = dashboardRepo ?? DashboardRepository(),
        _historyRepo = historyRepo ?? HistoryRepository(),
        super(const HealthState());

  Future<void> loadHealth(String tankId) async {
    emit(const HealthState(status: HealthStatus.loading));

    try {
      final dashboard = await _dashboardRepo.getDashboard(tankId);
      emit(HealthState(
        status: HealthStatus.success,
        fishHealthScore: dashboard.fishHealthScore,
        plantHealthScore: dashboard.plantHealthScore,
        algaeRiskLevel: dashboard.algaeRiskLevel,
        co2RiskIndicator: dashboard.co2RiskIndicator,
        range: state.range,
      ));
    } catch (e) {
      emit(HealthState(
        status: HealthStatus.error,
        fishHistory: state.fishHistory,
        plantHistory: state.plantHistory,
        range: state.range,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadHistory(String tankId, {String? range}) async {
    final r = range ?? state.range;
    emit(HealthState(
      status: HealthStatus.loading,
      fishHealthScore: state.fishHealthScore,
      plantHealthScore: state.plantHealthScore,
      algaeRiskLevel: state.algaeRiskLevel,
      co2RiskIndicator: state.co2RiskIndicator,
      range: r,
    ));

    try {
      final fish =
          await _historyRepo.getHistory(tankId, 'fish_health', range: r);
      final plant =
          await _historyRepo.getHistory(tankId, 'plant_health', range: r);
      emit(HealthState(
        status: HealthStatus.success,
        fishHealthScore: state.fishHealthScore,
        plantHealthScore: state.plantHealthScore,
        algaeRiskLevel: state.algaeRiskLevel,
        co2RiskIndicator: state.co2RiskIndicator,
        fishHistory: fish,
        plantHistory: plant,
        range: r,
      ));
    } catch (e) {
      emit(HealthState(
        status: HealthStatus.error,
        fishHealthScore: state.fishHealthScore,
        plantHealthScore: state.plantHealthScore,
        algaeRiskLevel: state.algaeRiskLevel,
        co2RiskIndicator: state.co2RiskIndicator,
        fishHistory: state.fishHistory,
        plantHistory: state.plantHistory,
        range: r,
        error: e.toString(),
      ));
    }
  }
}
