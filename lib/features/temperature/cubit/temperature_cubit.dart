import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/history_point_model.dart';
import '../../../data/repositories/temperature_repository.dart';
import '../../../data/repositories/history_repository.dart';

enum TemperatureStatus { initial, loading, success, error }

class TemperatureState {
  final TemperatureStatus status;
  final double currentValue;
  final double? targetValue;
  final List<HistoryPointModel> history;
  final String range;
  final String? error;

  const TemperatureState({
    this.status = TemperatureStatus.initial,
    this.currentValue = 0.0,
    this.targetValue,
    this.history = const [],
    this.range = '24h',
    this.error,
  });

  bool get isLoading => status == TemperatureStatus.loading;
  bool get isSuccess => status == TemperatureStatus.success;
  bool get isError => status == TemperatureStatus.error;
}

class TemperatureCubit extends Cubit<TemperatureState> {
  final TemperatureRepository _tempRepo;
  final HistoryRepository _historyRepo;

  TemperatureCubit({
    TemperatureRepository? tempRepo,
    HistoryRepository? historyRepo,
  })  : _tempRepo = tempRepo ?? TemperatureRepository(),
        _historyRepo = historyRepo ?? HistoryRepository(),
        super(const TemperatureState());

  Future<void> loadTemperature(String tankId) async {
    emit(const TemperatureState(status: TemperatureStatus.loading));

    try {
      final value = await _tempRepo.getTemperature(tankId);
      emit(TemperatureState(
        status: TemperatureStatus.success,
        currentValue: value,
        targetValue: state.targetValue,
        history: state.history,
        range: state.range,
      ));
    } catch (e) {
      emit(TemperatureState(
        status: TemperatureStatus.error,
        currentValue: state.currentValue,
        targetValue: state.targetValue,
        history: state.history,
        range: state.range,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadHistory(String tankId, {String? range}) async {
    final r = range ?? state.range;
    emit(TemperatureState(
      status: TemperatureStatus.loading,
      currentValue: state.currentValue,
      targetValue: state.targetValue,
      history: state.history,
      range: r,
    ));

    try {
      final history = await _historyRepo.getHistory(tankId, 'temperature', range: r);
      emit(TemperatureState(
        status: TemperatureStatus.success,
        currentValue: state.currentValue,
        targetValue: state.targetValue,
        history: history,
        range: r,
      ));
    } catch (e) {
      emit(TemperatureState(
        status: TemperatureStatus.error,
        currentValue: state.currentValue,
        targetValue: state.targetValue,
        history: state.history,
        range: r,
        error: e.toString(),
      ));
    }
  }

  Future<void> setTarget(String tankId, double target) async {
    emit(const TemperatureState(status: TemperatureStatus.loading));

    try {
      await _tempRepo.setTemperatureTarget(tankId, target);
      emit(TemperatureState(
        status: TemperatureStatus.success,
        currentValue: state.currentValue,
        targetValue: target,
        history: state.history,
        range: state.range,
      ));
    } catch (e) {
      emit(TemperatureState(
        status: TemperatureStatus.error,
        currentValue: state.currentValue,
        targetValue: state.targetValue,
        history: state.history,
        range: state.range,
        error: e.toString(),
      ));
    }
  }
}
