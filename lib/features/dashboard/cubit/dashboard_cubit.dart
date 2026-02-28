import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardState {
  final DashboardStatus status;
  final DashboardModel? dashboard;
  final String? error;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboard,
    this.error,
  });

  bool get isLoading => status == DashboardStatus.loading;
  bool get isSuccess => status == DashboardStatus.success;
  bool get isError => status == DashboardStatus.error;
}

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;

  DashboardCubit([DashboardRepository? repository])
      : _repo = repository ?? DashboardRepository(),
        super(const DashboardState());

  Future<void> loadDashboard(String tankId) async {
    emit(const DashboardState(status: DashboardStatus.loading));

    try {
      final dashboard = await _repo.getDashboard(tankId);
      emit(DashboardState(status: DashboardStatus.success, dashboard: dashboard));
    } catch (e) {
      emit(DashboardState(status: DashboardStatus.error, error: e.toString()));
    }
  }
}
