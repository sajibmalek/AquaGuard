import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/repositories/alert_repository.dart';

enum AlertsStatus { initial, loading, success, error }

class AlertsState {
  final AlertsStatus status;
  final List<AlertModel> alerts;
  final String? error;

  const AlertsState({
    this.status = AlertsStatus.initial,
    this.alerts = const [],
    this.error,
  });

  bool get isLoading => status == AlertsStatus.loading;
  bool get isSuccess => status == AlertsStatus.success;
  bool get isError => status == AlertsStatus.error;
  int get unacknowledgedCount =>
      alerts.where((a) => !a.acknowledged).length;
}

class AlertsCubit extends Cubit<AlertsState> {
  final AlertRepository _repo;

  AlertsCubit([AlertRepository? repository])
      : _repo = repository ?? AlertRepository(),
        super(const AlertsState());

  Future<void> loadAlerts(String tankId, {int? limit}) async {
    emit(const AlertsState(status: AlertsStatus.loading));

    try {
      final alerts = await _repo.getAlerts(tankId, limit: limit);
      emit(AlertsState(status: AlertsStatus.success, alerts: alerts));
    } catch (e) {
      emit(AlertsState(
        status: AlertsStatus.error,
        alerts: state.alerts,
        error: e.toString(),
      ));
    }
  }

  Future<void> acknowledgeAlert(String tankId, String alertId) async {
    emit(const AlertsState(status: AlertsStatus.loading));

    try {
      await _repo.acknowledgeAlert(tankId, alertId);
      final updated = state.alerts
          .map((a) => a.id == alertId
              ? AlertModel(
                  id: a.id,
                  type: a.type,
                  message: a.message,
                  severity: a.severity,
                  timestamp: a.timestamp,
                  acknowledged: true,
                  tankId: a.tankId,
                )
              : a)
          .toList();
      emit(AlertsState(status: AlertsStatus.success, alerts: updated));
    } catch (e) {
      emit(AlertsState(
        status: AlertsStatus.error,
        alerts: state.alerts,
        error: e.toString(),
      ));
    }
  }
}
