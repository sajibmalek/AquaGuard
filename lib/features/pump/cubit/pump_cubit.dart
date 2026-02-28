import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/pump_repository.dart';

enum PumpStatus { initial, loading, success, error }

class PumpState {
  final PumpStatus status;
  final bool isOn;
  final String? error;

  const PumpState({
    this.status = PumpStatus.initial,
    this.isOn = false,
    this.error,
  });

  bool get isLoading => status == PumpStatus.loading;
  bool get isSuccess => status == PumpStatus.success;
  bool get isError => status == PumpStatus.error;
}

class PumpCubit extends Cubit<PumpState> {
  final PumpRepository _repo;

  PumpCubit([PumpRepository? repository])
      : _repo = repository ?? PumpRepository(),
        super(const PumpState());

  Future<void> loadState(String tankId) async {
    emit(const PumpState(status: PumpStatus.loading));

    try {
      final isOn = await _repo.getPumpState(tankId);
      emit(PumpState(status: PumpStatus.success, isOn: isOn));
    } catch (e) {
      emit(PumpState(
        status: PumpStatus.error,
        isOn: state.isOn,
        error: e.toString(),
      ));
    }
  }

  Future<void> setState(String tankId, bool isOn) async {
    emit(const PumpState(status: PumpStatus.loading));

    try {
      await _repo.setPumpState(tankId, isOn);
      emit(PumpState(status: PumpStatus.success, isOn: isOn));
    } catch (e) {
      emit(PumpState(
        status: PumpStatus.error,
        isOn: state.isOn,
        error: e.toString(),
      ));
    }
  }
}
