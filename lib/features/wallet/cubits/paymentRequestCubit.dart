import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/wallet/walletRepository.dart';

abstract class PaymentRequestState {}

class PaymentRequestInitial extends PaymentRequestState {}

class PaymentRequestInProgress extends PaymentRequestState {}

class PaymentRequestSuccess extends PaymentRequestState {}

class PaymentRequestFailure extends PaymentRequestState {
  PaymentRequestFailure(this.errorMessage);

  final String errorMessage;
}

class PaymentRequestCubit extends Cubit<PaymentRequestState> {
  PaymentRequestCubit(this._walletRepository) : super(PaymentRequestInitial());
  final WalletRepository _walletRepository;

  Future<void> makePaymentRequest({
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      emit(PaymentRequestInProgress());
      await _walletRepository.makePaymentRequest(
        paymentType: paymentType,
        paymentAddress: paymentAddress,
        paymentAmount: paymentAmount,
        coinUsed: coinUsed,
        details: details,
      );
      emit(PaymentRequestSuccess());
      //
    } catch (e) {
      //
      emit(PaymentRequestFailure(e.toString()));
    }
  }

  void reset() => emit(PaymentRequestInitial());
}
