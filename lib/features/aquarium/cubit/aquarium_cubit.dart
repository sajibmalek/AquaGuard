import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/aquarium_model.dart';
import '../../../data/repositories/aquarium_repository.dart';

enum AquariumStatus { initial, loading, success, error }

class AquariumState {
  final AquariumStatus status;
  final List<AquariumModel> aquariums;
  final AquariumModel? selectedAquarium;
  final String? error;

  const AquariumState({
    this.status = AquariumStatus.initial,
    this.aquariums = const [],
    this.selectedAquarium,
    this.error,
  });

  bool get isLoading => status == AquariumStatus.loading;
  bool get isSuccess => status == AquariumStatus.success;
  bool get isError => status == AquariumStatus.error;
}

class AquariumCubit extends Cubit<AquariumState> {
  final AquariumRepository _repo;

  AquariumCubit([AquariumRepository? repository])
      : _repo = repository ?? AquariumRepository(),
        super(const AquariumState());

  Future<void> loadAquariums() async {
    emit(const AquariumState(status: AquariumStatus.loading));

    try {
      final aquariums = await _repo.getAquariums();
      emit(AquariumState(
        status: AquariumStatus.success,
        aquariums: aquariums,
        selectedAquarium: state.selectedAquarium,
      ));
    } catch (e) {
      emit(AquariumState(
        status: AquariumStatus.error,
        aquariums: state.aquariums,
        selectedAquarium: state.selectedAquarium,
        error: e.toString(),
      ));
    }
  }

  void selectAquarium(AquariumModel? aquarium) {
    emit(AquariumState(
      status: state.status,
      aquariums: state.aquariums,
      selectedAquarium: aquarium,
      error: state.error,
    ));
  }
}
