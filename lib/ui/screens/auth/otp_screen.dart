import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signInCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

const int otpTimeOutSeconds = 60;

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<SignInCubit>(
        child: const OtpScreen(),
        create: (_) => SignInCubit(AuthRepository()),
      ),
    );
  }
}

class _OtpScreen extends State<OtpScreen> {
  TextEditingController phoneNumberController = TextEditingController();

  CountryCode? selectedCountryCode;
  final smsCodeController = TextEditingController();

  final resendOtpTimerContainerKey = GlobalKey<ResendOtpTimerContainerState>();

  bool codeSent = false;
  bool hasError = false;
  String errorMessage = '';
  bool isLoading = false;
  String userVerificationId = '';

  bool enableResendOtpButton = false;

  Future<void> signInWithPhoneNumber({required String phoneNumber}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: otpTimeOutSeconds),
      phoneNumber: '${selectedCountryCode!.dialCode} $phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        //if otp code does not verify

        UiUtils.showSnackBar(
          context.tr(
            convertErrorCodeToLanguageKey(
              e.code == 'invalid-phone-number'
                  ? errorCodeInvalidPhoneNumber
                  : errorCodeDefaultMessage,
            ),
          )!,
          context,
        );

        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          codeSent = true;
          userVerificationId = verificationId;
          isLoading = false;
        });

        Future<void>.delayed(const Duration(milliseconds: 75)).then((value) {
          resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Widget _buildOTPSentToPhoneNumber() {
    if (codeSent) {
      return Column(
        children: [
          Text(
            context.tr(otpSendLbl)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          Text(
            '${selectedCountryCode!.dialCode} ${phoneNumberController.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop:
          context.read<SignInCubit>().state is! SignInProgress && !isLoading,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: size.height * UiUtils.vtMarginPct,
                horizontal: size.shortestSide * UiUtils.hzMarginPct + 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: size.height * .07),
                  _backButton(),
                  SizedBox(height: size.height * 0.02),
                  if (!codeSent) const AppLogo() else const SizedBox(),
                  SizedBox(height: size.height * 0.03),
                  _registerText(),
                  SizedBox(height: size.height * 0.03),
                  _buildOTPSentToPhoneNumber(),
                  SizedBox(height: size.height * 0.04),
                  if (codeSent)
                    _buildSmsCodeContainer()
                  else
                    _buildMobileNumberWithCountryCode(),
                  SizedBox(height: size.height * 0.04),
                  if (codeSent)
                    _buildSubmitOtpContainer()
                  else
                    _buildRequestOtpContainer(),
                  if (codeSent) _buildResendText() else const SizedBox(),
                  SizedBox(height: size.height * 0.04),
                  const TermsAndCondition(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return Row(
      children: [
        InkWell(
          onTap: Navigator.of(context).pop,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
      ],
    );
  }

  Widget _registerText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr('registration')!,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeights.bold,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        if (!codeSent) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * .7,
            child: Text(
              context.tr('regSubtitle')!,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeights.regular,
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget otpLabelIos() {
    return Row(
      children: [
        Expanded(
          child: QBackButton(color: Theme.of(context).primaryColor),
        ),
        Expanded(
          flex: 10,
          child: Text(
            context.tr('otpVerificationLbl')!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget otpLabel() {
    return Text(
      context.tr('otpVerificationLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMobileNumberWithCountryCode() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IgnorePointer(
            ignoring: isLoading,
            child: CountryCodePicker(
              onInit: (countryCode) {
                selectedCountryCode = countryCode;
              },
              onChanged: (countryCode) {
                selectedCountryCode = countryCode;
              },
              flagDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
              ),
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
                fontSize: 16,
              ),
              initialSelection: defaultCountryCodeForPhoneLogin,
            ),
          ),
          Flexible(
            child: TextField(
              enabled: !isLoading,
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              cursorColor: Theme.of(context).colorScheme.onTertiary,
              inputFormatters: [
                LengthLimitingTextInputFormatter(maxPhoneNumberLength),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
                  fontSize: 16,
                ),
                hintText: context.tr('phoneInputHintText'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsCodeContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return PinCodeTextField(
      onChanged: (value) {},
      keyboardType: TextInputType.number,
      appContext: context,
      length: 6,
      hintCharacter: '0',
      hintStyle: TextStyle(color: colorScheme.onTertiary.withOpacity(.3)),
      textStyle: TextStyle(color: colorScheme.onTertiary),
      pinTheme: PinTheme(
        selectedFillColor: Theme.of(context).primaryColor,
        inactiveColor: colorScheme.surface,
        activeColor: colorScheme.surface,
        inactiveFillColor: colorScheme.surface,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.5),
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 45,
        fieldWidth: 45,
        activeFillColor: colorScheme.surface,
      ),
      cursorColor: colorScheme.surface,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      controller: smsCodeController,
    );
  }

  Widget _buildSubmitOtpContainer() {
    return BlocConsumer<SignInCubit, SignInState>(
      bloc: context.read<SignInCubit>(),
      builder: (context, state) {
        if (state is SignInProgress) {
          return const CircularProgressContainer(size: 50);
        }

        return Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * (0.04),
          ),
          width: MediaQuery.of(context).size.width,
          child: CustomRoundedButton(
            widthPercentage: 1,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: context.tr(submitBtn),
            textSize: 20,
            fontWeight: FontWeights.bold,
            radius: 8,
            showBorder: false,
            height: 58,
            onTap: () async {
              if (smsCodeController.text.trim().length == 6) {
                context.read<SignInCubit>().signInUser(
                      AuthProviders.mobile,
                      smsCode: smsCodeController.text.trim(),
                      verificationId: userVerificationId,
                    );
              }
            },
          ),
        );
      },
      listener: (context, state) {
        if (state is SignInSuccess) {
          //update auth details
          context.read<AuthCubit>().updateAuthDetails(
                authProvider: AuthProviders.mobile,
                authStatus: true,
                firebaseId: state.user.uid,
                isNewUser: state.isNewUser,
              );

          if (state.isNewUser) {
            context.read<UserDetailsCubit>().fetchUserDetails();
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushReplacementNamed(Routes.selectProfile, arguments: true);
          } else {
            context.read<UserDetailsCubit>().fetchUserDetails();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.home,
              (_) => false,
              arguments: false,
            );
          }
        } else if (state is SignInFailure) {
          UiUtils.showSnackBar(
            context.tr(
              convertErrorCodeToLanguageKey(state.errorMessage),
            )!,
            context,
          );
        }
      },
    );
  }

  Widget _buildRequestOtpContainer() {
    if (isLoading) {
      return const CircularProgressContainer(size: 50);
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          setState(() => isLoading = true);
          await signInWithPhoneNumber(
            phoneNumber: phoneNumberController.text.trim(),
          );
        },
        child: Text(
          context.tr('requestOtpLbl')!,
          maxLines: 1,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 20,
              fontWeight: FontWeights.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResendOtpTimerContainer(
          key: resendOtpTimerContainerKey,
          enableResendOtpButton: () {
            setState(() {
              enableResendOtpButton = true;
            });
          },
        ),
        TextButton(
          onPressed: enableResendOtpButton
              ? () async {
                  setState(() {
                    isLoading = false;
                    enableResendOtpButton = false;
                    smsCodeController.text = '';
                  });
                  resendOtpTimerContainerKey.currentState?.cancelOtpTimer();
                  await signInWithPhoneNumber(
                    phoneNumber: phoneNumberController.text.trim(),
                  );
                }
              : null,
          child: Text(
            context.tr('resendBtn')!,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
