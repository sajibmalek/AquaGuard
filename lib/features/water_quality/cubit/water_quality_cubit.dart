import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/history_point_model.dart';
import '../../../data/repositories/water_quality_repository.dart';
import '../../../data/repositories/history_repository.dart';

enum WaterQualityStatus { initial, loading, success, error }

class WaterQualityState {
  final WaterQualityStatus status;
  final WaterQualityModel waterQuality;
  final List<HistoryPointModel> phHistory;
  final List<HistoryPointModel> orpHistory;
  final List<HistoryPointModel> tdsHistory;
  final List<HistoryPointModel> turbidityHistory;
  final String range;
  final String? error;

  const WaterQualityState({
    this.status = WaterQualityStatus.initial,
    this.waterQuality = const WaterQualityModel(),
    this.phHistory = const [],
    this.orpHistory = const [],
    this.tdsHistory = const [],
    this.turbidityHistory = const [],
    this.range = '24h',
    this.error,
  });

  bool get isLoading => status == WaterQualityStatus.loading;
  bool get isSuccess => status == WaterQualityStatus.success;
  bool get isError => status == WaterQualityStatus.error;
}

class WaterQualityCubit extends Cubit<WaterQualityState> {
  final WaterQualityRepository _qualityRepo;
  final HistoryRepository _historyRepo;

  WaterQualityCubit({
    WaterQualityRepository? qualityRepo,
    HistoryRepository? historyRepo,
  })  : _qualityRepo = qualityRepo ?? WaterQualityRepository(),
        _historyRepo = historyRepo ?? HistoryRepository(),
        super(const WaterQualityState());

  Future<void> loadWaterQuality(String tankId) async {
    emit(const WaterQualityState(status: WaterQualityStatus.loading));

    try {
      final data = await _qualityRepo.getWaterQuality(tankId);
      final quality = WaterQualityModel.fromJson(
        Map<String, dynamic>.from(data),
      );
      emit(WaterQualityState(
        status: WaterQualityStatus.success,
        waterQuality: quality,
        range: state.range,
      ));
    } catch (e) {
      emit(WaterQualityState(
        status: WaterQualityStatus.error,
        waterQuality: state.waterQuality,
        range: state.range,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadHistory(String tankId, {String? range}) async {
    final r = range ?? state.range;
    emit(WaterQualityState(
      status: WaterQualityStatus.loading,
      waterQuality: state.waterQuality,
      range: r,
    ));

    try {
      final ph = await _historyRepo.getHistory(tankId, 'ph', range: r);
      final orp = await _historyRepo.getHistory(tankId, 'orp', range: r);
      final tds = await _historyRepo.getHistory(tankId, 'tds', range: r);
      final turbidity =
          await _historyRepo.getHistory(tankId, 'turbidity', range: r);
      emit(WaterQualityState(
        status: WaterQualityStatus.success,
        waterQuality: state.waterQuality,
        phHistory: ph,
        orpHistory: orp,
        tdsHistory: tds,
        turbidityHistory: turbidity,
        range: r,
      ));
    } catch (e) {
      emit(WaterQualityState(
        status: WaterQualityStatus.error,
        waterQuality: state.waterQuality,
        phHistory: state.phHistory,
        orpHistory: state.orpHistory,
        tdsHistory: state.tdsHistory,
        turbidityHistory: state.turbidityHistory,
        range: r,
        error: e.toString(),
      ));
    }
  }
}
