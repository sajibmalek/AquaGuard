import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/history_point_model.dart';
import '../../../data/repositories/history_repository.dart';

enum HistoryStatus { initial, loading, success, error }

class HistoryState {
  final HistoryStatus status;
  final String metric;
  final String range;
  final List<HistoryPointModel> data;
  final String? error;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.metric = 'temperature',
    this.range = '24h',
    this.data = const [],
    this.error,
  });

  bool get isLoading => status == HistoryStatus.loading;
  bool get isSuccess => status == HistoryStatus.success;
  bool get isError => status == HistoryStatus.error;
}

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repo;

  HistoryCubit([HistoryRepository? repository])
      : _repo = repository ?? HistoryRepository(),
        super(const HistoryState());

  Future<void> loadHistory(
    String tankId, {
    String? metric,
    String? range,
  }) async {
    final m = metric ?? state.metric;
    final r = range ?? state.range;
    emit(HistoryState(
      status: HistoryStatus.loading,
      metric: m,
      range: r,
      data: state.data,
    ));

    try {
      final data = await _repo.getHistory(tankId, m, range: r);
      emit(HistoryState(
        status: HistoryStatus.success,
        metric: m,
        range: r,
        data: data,
      ));
    } catch (e) {
      emit(HistoryState(
        status: HistoryStatus.error,
        metric: m,
        range: r,
        data: state.data,
        error: e.toString(),
      ));
    }
  }
}
