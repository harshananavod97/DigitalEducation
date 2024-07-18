import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';

class RedeemAmountRequestBottomSheetContainer extends StatefulWidget {
  const RedeemAmountRequestBottomSheetContainer({
    required this.deductedCoins,
    required this.redeemableAmount,
    required this.paymentRequestCubit,
    super.key,
  });

  final double redeemableAmount;
  final int deductedCoins;

  final PaymentRequestCubit paymentRequestCubit;

  @override
  State<RedeemAmountRequestBottomSheetContainer> createState() =>
      _RedeemAmountRequestBottomSheetContainerState();
}

class _RedeemAmountRequestBottomSheetContainerState
    extends State<RedeemAmountRequestBottomSheetContainer>
    with TickerProviderStateMixin {
  late final List<TextEditingController> _inputDetailsControllers =
      payoutMethods[_selectedPaymentMethodIndex]
          .inputs
          .map((e) => TextEditingController())
          .toList();

  late double _selectPaymentMethodDx = 0;

  late int _selectedPaymentMethodIndex = 0;
  late int _enterPayoutMethodDx = 1;
  late String _errorMessage = '';

  @override
  void dispose() {
    for (final element in _inputDetailsControllers) {
      element.dispose();
    }
    super.dispose();
  }

  Widget _buildPaymentSelectMethodContainer({required int paymentMethodIndex}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = paymentMethodIndex;
          _inputDetailsControllers.clear();
          for (final _ in payoutMethods[_selectedPaymentMethodIndex].inputs) {
            _inputDetailsControllers.add(TextEditingController());
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.of(context).size.width * .175,
        height: MediaQuery.of(context).size.width * .175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedPaymentMethodIndex == paymentMethodIndex
                ? Colors.transparent
                : Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
          ),
          color: _selectedPaymentMethodIndex == paymentMethodIndex
              ? Theme.of(context).primaryColor
              : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SvgPicture.asset(payoutMethods[paymentMethodIndex].image),
      ),
    );
  }

  Widget _buildInputDetailsContainer(int inputDetailsIndex) {
    final input =
        payoutMethods[_selectedPaymentMethodIndex].inputs[inputDetailsIndex];

    final inputFormatters = input.isNumber
        ? [FilteringTextInputFormatter.digitsOnly]
        : <TextInputFormatter>[];
    if (input.maxLength > 0) {
      inputFormatters.add(
        LengthLimitingTextInputFormatter(input.maxLength),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: MediaQuery.of(context).size.width * .1,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      height: MediaQuery.of(context).size.height * (0.05),
      child: TextField(
        controller: _inputDetailsControllers[inputDetailsIndex],
        textAlign: TextAlign.center,
        keyboardType: input.isNumber ? TextInputType.phone : TextInputType.text,
        inputFormatters: inputFormatters,
        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        cursorColor: Theme.of(context).colorScheme.onTertiary,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: input.name,
          hintStyle: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
          ),
        ),
      ),
    );
  }

  Widget _buildEnterPayoutMethodDetailsContainer() {
    final mqSize = MediaQuery.of(context).size;
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(0, 3, mqSize.width * _enterPayoutMethodDx),
      duration: const Duration(milliseconds: 500),
      child: BlocConsumer<PaymentRequestCubit, PaymentRequestState>(
        listener: (context, state) {
          if (state is PaymentRequestFailure) {
            if (state.errorMessage == errorCodeUnauthorizedAccess) {
              showAlreadyLoggedInDialog(context);
              return;
            }
            setState(() {
              _errorMessage = context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!;
            });
          } else if (state is PaymentRequestSuccess) {
            context.read<UserDetailsCubit>().updateCoins(
                  addCoin: false,
                  coins: widget.deductedCoins,
                );
          }
        },
        bloc: widget.paymentRequestCubit,
        builder: (context, state) {
          if (state is PaymentRequestSuccess) {
            return Column(
              children: [
                //
                SizedBox(height: mqSize.height * (0.025)),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    context.tr(successfullyRequestedKey)!,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: mqSize.height * (0.025)),
                LottieBuilder.asset(
                  'assets/animations/success.json',
                  fit: BoxFit.cover,
                  animate: true,
                  height: mqSize.height * (0.2),
                ),

                SizedBox(height: mqSize.height * (0.025)),
                CustomRoundedButton(
                  widthPercentage: 0.525,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: context.tr(trackRequestKey),
                  radius: 15,
                  showBorder: false,
                  titleColor: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                  textSize: 17,
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  height: 40,
                ),
              ],
            );
          }

          final payoutMethod = payoutMethods[_selectedPaymentMethodIndex];

          return Column(
            children: [
              SizedBox(height: mqSize.height * .015),
              //
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${context.tr(payoutMethodKey)!} - ${payoutMethod.type}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeights.bold,
                    fontSize: 22,
                  ),
                ),
              ),

              SizedBox(height: mqSize.height * .025),

              for (var i = 0; i < payoutMethod.inputs.length; i++)
                _buildInputDetailsContainer(i),

              SizedBox(height: mqSize.height * (0.01)),

              AnimatedOpacity(
                opacity: _errorMessage.isEmpty ? 0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              SizedBox(height: mqSize.height * .0125),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mqSize.width * UiUtils.hzMarginPct,
                ),
                child: CustomRoundedButton(
                  widthPercentage: 1,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: state is PaymentRequestInProgress
                      ? context.tr(requestingKey)
                      : context.tr(makeRequestKey),
                  radius: 10,
                  showBorder: false,
                  titleColor: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                  textSize: 18,
                  onTap: () {
                    var isAnyInputFieldEmpty = false;
                    for (final textEditingController
                        in _inputDetailsControllers) {
                      if (textEditingController.text.trim().isEmpty) {
                        isAnyInputFieldEmpty = true;

                        break;
                      }
                    }

                    if (isAnyInputFieldEmpty) {
                      setState(() {
                        _errorMessage = context.tr(pleaseFillAllDataKey)!;
                      });
                      return;
                    }

                    widget.paymentRequestCubit.makePaymentRequest(
                      paymentType: payoutMethod.type,
                      paymentAddress: jsonEncode(
                        _inputDetailsControllers
                            .map((e) => e.text.trim())
                            .toList(),
                      ),
                      paymentAmount: widget.redeemableAmount.toString(),
                      coinUsed: widget.deductedCoins.toString(),
                      details: context.tr('redeemRequest')!,
                    );
                  },
                  height: 50,
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _selectPaymentMethodDx = 0;
                    _enterPayoutMethodDx = 1;
                    _errorMessage = '';
                  });
                },
                child: Text(
                  context.tr(changePayoutMethodKey)!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeights.semiBold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPayoutSelectMethodContainer() {
    final children = <Widget>[];
    for (var i = 0; i < payoutMethods.length; i++) {
      children.add(_buildPaymentSelectMethodContainer(paymentMethodIndex: i));
    }
    return children;
  }

  Widget _buildSelectPayoutOption() {
    final mqSize = MediaQuery.of(context).size;
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(0, 3, mqSize.width * _selectPaymentMethodDx),
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Text(
                context.tr('payoutMethod')!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const Divider(),
              Text(
                context.tr(redeemableAmountKey)!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontSize: 18,
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${context.read<SystemConfigCubit>().payoutRequestCurrency} ${widget.redeemableAmount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeights.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '${widget.deductedCoins} ${context.tr(coinsWillBeDeductedKey)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeights.medium,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mqSize.width * UiUtils.hzMarginPct,
            ),
            child: const Divider(),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              context.tr(selectPayoutOptionKey)!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeights.medium,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            height: mqSize.height * (0.55) * (0.05),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mqSize.width * UiUtils.hzMarginPct,
            ),
            child: Wrap(
              //alignment: WrapAlignment.center,
              children: _buildPayoutSelectMethodContainer(),
            ),
          ),
          SizedBox(
            height: mqSize.height * (0.55) * (0.075),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mqSize.width * UiUtils.hzMarginPct,
            ),
            child: CustomRoundedButton(
              widthPercentage: 1,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle: context.tr(continueLbl),
              radius: 10,
              showBorder: false,
              titleColor: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
              textSize: 18,
              onTap: () {
                setState(() {
                  _selectPaymentMethodDx = -1;
                  _enterPayoutMethodDx = 0;
                });
              },
              height: 50,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mqHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: mqHeight * .8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  _buildSelectPayoutOption(),
                  _buildEnterPayoutMethodDetailsContainer(),
                ],
              ),
              SizedBox(height: mqHeight * .05),
            ],
          ),
        ),
      ),
    );
  }
}
