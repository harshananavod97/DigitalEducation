import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/statistic/models/statisticModel.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';

@immutable
abstract class StatisticState {}

class StatisticInitial extends StatisticState {}

class StatisticFetchInProgress extends StatisticState {}

class StatisticFetchSuccess extends StatisticState {
  StatisticFetchSuccess(this.statisticModel);

  final StatisticModel statisticModel;
}

class StatisticFetchFailure extends StatisticState {
  StatisticFetchFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class StatisticCubit extends Cubit<StatisticState> {
  StatisticCubit(this._statisticRepository) : super(StatisticInitial());
  final StatisticRepository _statisticRepository;

  Future<void> getStatistic() async {
    emit(StatisticFetchInProgress());
    try {
      final result =
          await _statisticRepository.getStatistic(getBattleStatistics: false);

      emit(StatisticFetchSuccess(result));
    } catch (e) {
      emit(StatisticFetchFailure(e.toString()));
    }
  }

  Future<void> getStatisticWithBattle() async {
    emit(StatisticFetchInProgress());
    try {
      final result = await _statisticRepository.getStatistic(
        getBattleStatistics: true,
      );
      emit(StatisticFetchSuccess(result));
    } catch (e) {
      emit(StatisticFetchFailure(e.toString()));
    }
  }

  StatisticModel getStatisticsDetails() {
    if (state is StatisticFetchSuccess) {
      return (state as StatisticFetchSuccess).statisticModel;
    }
    return StatisticModel.fromJson({}, {});
  }
}
