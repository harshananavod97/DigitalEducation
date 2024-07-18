import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/wallet/models/paymentRequest.dart';
import 'package:flutterquiz/features/wallet/walletRepository.dart';

abstract class TransactionsState {}

class TransactionsFetchInitial extends TransactionsState {}

class TransactionsFetchInProgress extends TransactionsState {}

class TransactionsFetchSuccess extends TransactionsState {
  TransactionsFetchSuccess({
    required this.paymentRequests,
    required this.totalTransactionsCount,
    required this.hasMoreFetchError,
    required this.hasMore,
  });

  final List<PaymentRequest> paymentRequests;
  final int totalTransactionsCount;
  final bool hasMoreFetchError;
  final bool hasMore;
}

class TransactionsFetchFailure extends TransactionsState {
  TransactionsFetchFailure(this.errorMessage);

  final String errorMessage;
}

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(this._walletRepository) : super(TransactionsFetchInitial());
  final WalletRepository _walletRepository;

  final int limit = 15;

  Future<void> getTransactions() async {
    try {
      final (:total, :data) = await _walletRepository.getTransactions(
        limit: limit.toString(),
        offset: '0',
      );

      if (isClosed) return;

      emit(
        TransactionsFetchSuccess(
          paymentRequests: data,
          totalTransactionsCount: total,
          hasMoreFetchError: false,
          hasMore: data.length < total,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(TransactionsFetchFailure(e.toString()));
    }
  }

  // ignore: avoid_bool_literals_in_conditional_expressions
  bool hasMoreTransactions() => (state is TransactionsFetchSuccess)
      ? (state as TransactionsFetchSuccess).hasMore
      : false;

  Future<void> getMoreTransactions() async {
    if (state is TransactionsFetchSuccess) {
      final successState = state as TransactionsFetchSuccess;

      try {
        //
        final (:total, :data) = await _walletRepository.getTransactions(
          limit: limit.toString(),
          offset: successState.paymentRequests.length.toString(),
        );

        final updatedResults = successState.paymentRequests..addAll(data);

        emit(
          TransactionsFetchSuccess(
            paymentRequests: updatedResults,
            totalTransactionsCount: total,
            hasMoreFetchError: false,
            hasMore: updatedResults.length < total,
          ),
        );
        //
      } catch (e) {
        //in case of any error
        emit(
          TransactionsFetchSuccess(
            paymentRequests: successState.paymentRequests,
            hasMoreFetchError: true,
            totalTransactionsCount: successState.totalTransactionsCount,
            hasMore: successState.hasMore,
          ),
        );
      }
    }
  }

  double calculateTotalEarnings() {
    if (state is TransactionsFetchSuccess) {
      final successfulRequests = (state as TransactionsFetchSuccess)
          .paymentRequests
          .where((element) => element.status == '1');
      var totalEarnings = 0.0;

      for (final element in successfulRequests) {
        totalEarnings = totalEarnings + double.parse(element.paymentAmount);
      }
      return totalEarnings;
    }
    return 0;
  }
}
