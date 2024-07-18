import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRemoteDataSource.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signInCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/app_logo.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/email_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/pswd_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/terms_and_condition.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyDialog = GlobalKey<FormState>();

  bool isLoading = false;

  final emailController = TextEditingController();
  final forgotPswdController = TextEditingController();
  final pswdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(AuthRepository()),
      child: Builder(
        builder: (context) => Scaffold(
          body: SingleChildScrollView(child: showForm(context)),
        ),
      ),
    );
  }

  Widget showForm(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Padding(
        // padding: const EdgeInsets.all(30),
        padding: EdgeInsets.symmetric(
          vertical: size.height * UiUtils.vtMarginPct,
          horizontal: size.width * UiUtils.hzMarginPct + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: size.height * .09),
            const AppLogo(),
            SizedBox(height: size.height * .08),
            EmailTextField(controller: emailController),
            SizedBox(height: size.height * .02),
            PswdTextField(controller: pswdController),
            SizedBox(height: size.height * .01),
            forgetPwd(),
            SizedBox(height: size.height * 0.02),
            showSignIn(context),
            SizedBox(height: size.height * 0.02),
            showGoSignup(),
            orLabel(),
            SizedBox(height: size.height * 0.03),
            loginWith(),
            showSocialMedia(context),
            SizedBox(height: size.height * 0.05),
            const TermsAndCondition(),
          ],
        ),
      ),
    );
  }

  Widget showSignIn(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.055,
      child: BlocConsumer<SignInCubit, SignInState>(
        bloc: context.read<SignInCubit>(),
        listener: (context, state) async {
          //Exceuting only if authProvider is email
          if (state is SignInSuccess &&
              state.authProvider == AuthProviders.email) {
            //to update authdetails after successfull sign in
            context.read<AuthCubit>().updateAuthDetails(
                  authProvider: state.authProvider,
                  firebaseId: state.user.uid,
                  authStatus: true,
                  isNewUser: state.isNewUser,
                );
            if (state.isNewUser) {
              await context.read<UserDetailsCubit>().fetchUserDetails();
              //navigate to select profile screen

              await Navigator.of(context).pushReplacementNamed(
                Routes.selectProfile,
                arguments: true,
              );
            } else {
              //get user detials of signed in user
              await context.read<UserDetailsCubit>().fetchUserDetails();
              await Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.home,
                (_) => false,
                arguments: false,
              );
            }
          } else if (state is SignInFailure &&
              state.authProvider == AuthProviders.email) {
            UiUtils.showSnackBar(
              context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!,
              context,
            );
          }
        },
        builder: (context, state) {
          return CupertinoButton(
            padding: const EdgeInsets.all(5),
            color: Theme.of(context).primaryColor,
            onPressed: state is SignInProgress
                ? () {}
                : () async {
                    if (_formKey.currentState!.validate()) {
                      {
                        context.read<SignInCubit>().signInUser(
                              AuthProviders.email,
                              email: emailController.text.trim(),
                              password: pswdController.text.trim(),
                            );
                      }
                    }
                  },
            child: state is SignInProgress &&
                    state.authProvider == AuthProviders.email
                ? const Center(
                    child: CircularProgressContainer(whiteLoader: true),
                  )
                : Text(
                    context.tr('loginLbl')!,
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        height: 1.2,
                        fontSize: 20,
                        fontWeight: FontWeights.regular,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Padding forgetPwd() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          splashColor: Colors.white,
          child: Text(
            context.tr('forgotPwdLbl')!,
            style: TextStyle(
              fontWeight: FontWeights.regular,
              fontSize: 14,
              height: 1.21,
              color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
            ),
          ),
          onTap: () async {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: UiUtils.bottomSheetTopRadius,
              ),
              context: context,
              builder: (context) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: UiUtils.bottomSheetTopRadius,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * (0.41),
                  ),
                  child: Form(
                    key: _formKeyDialog,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Text(
                          context.tr('resetPwdLbl')!,
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 20,
                            end: 20,
                            top: 20,
                          ),
                          child: Text(
                            context.tr('resetEnterEmailLbl')!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontWeight: FontWeights.semiBold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: MediaQuery.of(context).size.width * .08,
                            end: MediaQuery.of(context).size.width * .08,
                            top: 20,
                          ),
                          child:
                              EmailTextField(controller: forgotPswdController),
                        ),
                        const SizedBox(height: 30),
                        CustomRoundedButton(
                          widthPercentage: 0.55,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: context.tr('submitBtn'),
                          radius: 10,
                          showBorder: false,
                          height: 50,
                          onTap: () {
                            final form = _formKeyDialog.currentState;
                            if (form!.validate()) {
                              form.save();
                              UiUtils.showSnackBar(
                                context.tr('pwdResetLinkLbl')!,
                                context,
                              );
                              AuthRemoteDataSource().resetPassword(
                                forgotPswdController.text.trim(),
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.pop(context, 'Cancel');
                              });

                              forgotPswdController.text = '';
                              form.reset();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget orLabel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        context.tr('orLbl')!,
        style: TextStyle(
          fontWeight: FontWeights.regular,
          color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget loginWith() {
    return Text(
      context.tr('loginSocialMediaLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeights.regular,
        color: Theme.of(context).colorScheme.onTertiary,
        fontSize: 14,
      ),
    );
  }

  Widget showSocialMedia(BuildContext context) {
    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        //Exceuting only if authProvider is not email
        if (state is SignInSuccess &&
            state.authProvider != AuthProviders.email) {
          context.read<AuthCubit>().updateAuthDetails(
                authProvider: state.authProvider,
                firebaseId: state.user.uid,
                authStatus: true,
                isNewUser: state.isNewUser,
              );
          if (state.isNewUser) {
            context.read<UserDetailsCubit>().fetchUserDetails();
            //navigate to select profile screen
            Navigator.of(context)
                .pushReplacementNamed(Routes.selectProfile, arguments: true);
          } else {
            //get user detials of signed in user
            context.read<UserDetailsCubit>().fetchUserDetails();
            //updateFcm id
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.home,
              (_) => false,
              arguments: false,
            );
          }
        } else if (state is SignInFailure &&
            state.authProvider != AuthProviders.email) {
          UiUtils.showSnackBar(
            context.tr(
              convertErrorCodeToLanguageKey(state.errorMessage),
            )!,
            context,
          );
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: (state is SignInProgress &&
                    state.authProvider != AuthProviders.email)
                ? [
                    const Center(child: CircularProgressContainer()),
                  ]
                : [
                    if (Platform.isIOS) ...[
                      InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            Assets.appleIcon,
                            height: 38,
                            width: 38,
                          ),
                        ),
                        onTap: () => context
                            .read<SignInCubit>()
                            .signInUser(AuthProviders.apple),
                      ),
                      const SizedBox(width: 25),
                    ],
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          Assets.googleIcon,
                          height: 38,
                          width: 38,
                        ),
                      ),
                      onTap: () => context
                          .read<SignInCubit>()
                          .signInUser(AuthProviders.gmail),
                    ),
                    const SizedBox(width: 25),
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          Assets.phoneIcon,
                          height: 38,
                          width: 38,
                        ),
                      ),
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.otpScreen),
                    ),
                  ],
          ),
        );
      },
    );
  }

  Widget showGoSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('noAccountLbl')!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeights.regular,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 4),
        CupertinoButton(
          onPressed: () {
            _formKey.currentState!.reset();
            Navigator.of(context).pushNamed(Routes.signUp);
          },
          padding: EdgeInsets.zero,
          child: Text(
            context.tr('signUpLbl')!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeights.regular,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
