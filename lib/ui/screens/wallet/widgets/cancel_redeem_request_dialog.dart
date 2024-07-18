import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/cancel_payment_request_cubit.dart';
import 'package:flutterquiz/features/wallet/walletRepository.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

Future<bool?> showCancelRequestDialog({
  required BuildContext context,
  required String paymentId,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => BlocProvider(
      lazy: false,
      create: (_) => CancelPaymentRequestCubit(WalletRepository()),
      child: _CancelRedeemRequestDialog(paymentId: paymentId),
    ),
  );
}

class _CancelRedeemRequestDialog extends StatelessWidget {
  const _CancelRedeemRequestDialog({required this.paymentId});

  final String paymentId;

  void listener(
    BuildContext context,
    CancelPaymentRequestState state,
  ) {
    if (state.status == CancelPaymentStatus.success) {
      context.read<UserDetailsCubit>().fetchUserDetails().then((_) {
        Navigator.pop(context, true);
      });
    }

    if (state.status == CancelPaymentStatus.failure) {
      Navigator.pop(context, false);
      UiUtils.showSnackBar(
        '${state.error}',
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void onTapCancel() {
      context
          .read<CancelPaymentRequestCubit>()
          .cancelPaymentRequest(paymentId: paymentId);
    }

    return BlocConsumer<CancelPaymentRequestCubit, CancelPaymentRequestState>(
      listener: listener,
      builder: (context, state) {
        return AlertDialog(
          title: state.status == CancelPaymentStatus.initial
              ? Text(
                  context.tr('cancelPaymentConfirmation')!,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onTertiary,
                  ),
                )
              : const CircularProgressContainer(),
          actions: state.status == CancelPaymentStatus.initial
              ? [
                  TextButton(
                    onPressed: context.shouldPop,
                    child: Text(
                      context.tr('close')!,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onTertiary,
                      ),
                    ),
                  ),

                  ///
                  TextButton(
                    onPressed: onTapCancel,
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${context.tr('yesBtn')!}, ${context.tr('cancel')!}',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.surface,
                      ),
                    ),
                  ),
                ]
              : null,
        );
      },
    );
  }
}
