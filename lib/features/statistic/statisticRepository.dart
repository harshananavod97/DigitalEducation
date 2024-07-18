import 'package:flutterquiz/features/statistic/models/statisticModel.dart';
import 'package:flutterquiz/features/statistic/statisticException.dart';
import 'package:flutterquiz/features/statistic/statisticRemoteDataSource.dart';

class StatisticRepository {
  factory StatisticRepository() {
    _statisticRepository._statisticRemoteDataSource =
        StatisticRemoteDataSource();

    return _statisticRepository;
  }

  StatisticRepository._internal();

  static final StatisticRepository _statisticRepository =
      StatisticRepository._internal();
  late StatisticRemoteDataSource _statisticRemoteDataSource;

  Future<StatisticModel> getStatistic({
    required bool getBattleStatistics,
  }) async {
    try {
      final result = await _statisticRemoteDataSource.getStatistic();
      if (getBattleStatistics) {
        final battleResult =
            await _statisticRemoteDataSource.getBattleStatistic();
        final battleStatistics = <String, dynamic>{};
        final myReports = (battleResult['myreport'] as List)
            .cast<Map<String, dynamic>>()
            .first;

        for (final element in myReports.keys) {
          battleStatistics.addAll({element: myReports[element]});
        }

        battleStatistics['playedBattles'] =
            (battleResult['data'] as List? ?? []).cast<Map<String, dynamic>>();

        return StatisticModel.fromJson(result, battleStatistics);
      }
      return StatisticModel.fromJson(result, {});
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateStatistic({
    int? answeredQuestion,
    int? correctAnswers,
    double? winPercentage,
    String? categoryId,
  }) async {
    try {
      await _statisticRemoteDataSource.updateStatistic(
        answeredQuestion: answeredQuestion.toString(),
        categoryId: categoryId,
        correctAnswers: correctAnswers.toString(),
        winPercentage: winPercentage!.toInt().toString(),
      );
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateBattleStatistic({
    required String userId1,
    required String userId2,
    required String winnerId,
  }) async {
    try {
      await _statisticRemoteDataSource.updateBattleStatistic(
        userId1: userId1,
        userId2: userId2,
        isDrawn: winnerId.isEmpty ? '1' : '0',
        winnerId: winnerId.isEmpty ? '0' : winnerId,
      );
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }
}
