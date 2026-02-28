import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/lighting_repository.dart';

enum LightingStatus { initial, loading, success, error }

class LightingState {
  final LightingStatus status;
  final bool isOn;
  final String? error;

  const LightingState({
    this.status = LightingStatus.initial,
    this.isOn = false,
    this.error,
  });

  bool get isLoading => status == LightingStatus.loading;
  bool get isSuccess => status == LightingStatus.success;
  bool get isError => status == LightingStatus.error;
}

class LightingCubit extends Cubit<LightingState> {
  final LightingRepository _repo;

  LightingCubit([LightingRepository? repository])
      : _repo = repository ?? LightingRepository(),
        super(const LightingState());

  Future<void> loadState(String tankId) async {
    emit(const LightingState(status: LightingStatus.loading));

    try {
      final isOn = await _repo.getLightState(tankId);
      emit(LightingState(status: LightingStatus.success, isOn: isOn));
    } catch (e) {
      emit(LightingState(
        status: LightingStatus.error,
        isOn: state.isOn,
        error: e.toString(),
      ));
    }
  }

  Future<void> setState(String tankId, bool isOn) async {
    emit(const LightingState(status: LightingStatus.loading));

    try {
      await _repo.setLightState(tankId, isOn);
      emit(LightingState(status: LightingStatus.success, isOn: isOn));
    } catch (e) {
      emit(LightingState(
        status: LightingStatus.error,
        isOn: state.isOn,
        error: e.toString(),
      ));
    }
  }
}
