import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/coinHistory/coinHistoryRepository.dart';
import 'package:flutterquiz/features/coinHistory/models/coinHistory.dart';

abstract class CoinHistoryState {}

class CoinHistoryInitial extends CoinHistoryState {}

class CoinHistoryFetchInProgress extends CoinHistoryState {}

class CoinHistoryFetchSuccess extends CoinHistoryState {
  CoinHistoryFetchSuccess({
    required this.coinHistory,
    required this.totalCoinHistoryCount,
    required this.hasMoreFetchError,
    required this.hasMore,
  });

  final List<CoinHistory> coinHistory;
  final int totalCoinHistoryCount;
  final bool hasMoreFetchError;
  final bool hasMore;
}

class CoinHistoryFetchFailure extends CoinHistoryState {
  CoinHistoryFetchFailure(this.errorMessage);

  final String errorMessage;
}

class CoinHistoryCubit extends Cubit<CoinHistoryState> {
  CoinHistoryCubit(this._coinHistoryRepository) : super(CoinHistoryInitial());
  final CoinHistoryRepository _coinHistoryRepository;

  final int limit = 15;

  Future<void> getCoinHistory() async {
    try {
      final (:total, :data) = await _coinHistoryRepository.getCoinHistory(
        limit: limit.toString(),
        offset: '0',
      );
      emit(
        CoinHistoryFetchSuccess(
          coinHistory: data,
          totalCoinHistoryCount: total,
          hasMoreFetchError: false,
          hasMore: data.length < total,
        ),
      );
    } catch (e) {
      emit(CoinHistoryFetchFailure(e.toString()));
    }
  }

  // ignore: avoid_bool_literals_in_conditional_expressions
  bool hasMoreCoinHistory() => state is CoinHistoryFetchSuccess
      ? (state as CoinHistoryFetchSuccess).hasMore
      : false;

  Future<void> getMoreCoinHistory({required String userId}) async {
    if (state is CoinHistoryFetchSuccess) {
      try {
        final (:total, :data) = await _coinHistoryRepository.getCoinHistory(
          limit: limit.toString(),
          offset:
              (state as CoinHistoryFetchSuccess).coinHistory.length.toString(),
        );

        final updatedResults = (state as CoinHistoryFetchSuccess).coinHistory
          ..addAll(data);
        emit(
          CoinHistoryFetchSuccess(
            coinHistory: updatedResults,
            totalCoinHistoryCount: total,
            hasMoreFetchError: false,
            hasMore: updatedResults.length < total,
          ),
        );
        //
      } catch (e) {
        emit(
          CoinHistoryFetchSuccess(
            coinHistory: (state as CoinHistoryFetchSuccess).coinHistory,
            hasMoreFetchError: true,
            totalCoinHistoryCount:
                (state as CoinHistoryFetchSuccess).totalCoinHistoryCount,
            hasMore: (state as CoinHistoryFetchSuccess).hasMore,
          ),
        );
      }
    }
  }
}
