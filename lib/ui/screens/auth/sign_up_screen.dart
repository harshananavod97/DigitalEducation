import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signUpCubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/app_logo.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/email_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/pswd_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/terms_and_condition.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  final emailController = TextEditingController();
  final pswdController = TextEditingController();
  final confirmPswdController = TextEditingController();
  String userEmail = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (_) => SignUpCubit(AuthRepository()),
      child: Builder(
        builder: (_) => Scaffold(
          body: SingleChildScrollView(child: form()),
        ),
      ),
    );
  }

  Widget form() {
    final size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * UiUtils.vtMarginPct,
          horizontal: size.shortestSide * UiUtils.hzMarginPct + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: size.height * .07),
            Row(
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
            ),
            SizedBox(height: size.height * .02),
            const AppLogo(),
            SizedBox(height: size.height * .08),
            EmailTextField(controller: emailController),
            SizedBox(height: size.height * .02),
            PswdTextField(controller: pswdController),
            SizedBox(height: size.height * .02),
            PswdTextField(
              controller: confirmPswdController,
              hintText: "${context.tr("cnPwdLbl")!}*",
              validator: (val) {
                if (val != pswdController.text) {
                  return context.tr('cnPwdNotMatchMsg');
                }
                return null;
              },
            ),
            SizedBox(height: size.height * .04),
            signupButton(),
            SizedBox(height: size.height * .02),
            showGoSignIn(),
            SizedBox(height: size.height * .04),
            const TermsAndCondition(),
          ],
        ),
      ),
    );
  }

  Widget showGoSignIn() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('alreadyAccountLbl')!,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: Navigator.of(context).pop,
          child: Text(
            context.tr('loginLbl')!,
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

  Widget signupButton() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.055,
          child: BlocConsumer<SignUpCubit, SignUpState>(
            listener: (context, state) async {
              if (state is SignUpSuccess) {
                //on signup success navigate user to sign in screen
                UiUtils.showSnackBar(
                  "${context.tr('emailVerify')} $userEmail",
                  context,
                );
                setState(() {
                  Navigator.pop(context);
                });
              } else if (state is SignUpFailure) {
                //show error message
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    //calling signup user
                    context.read<SignUpCubit>().signUpUser(
                          AuthProviders.email,
                          emailController.text.trim(),
                          pswdController.text.trim(),
                        );
                    userEmail = emailController.text.trim();
                    resetForm();
                  }
                },
                child: state is SignUpProgress
                    ? const Center(
                        child: CircularProgressContainer(whiteLoader: true),
                      )
                    : Text(
                        context.tr('signUpLbl')!,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 20,
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  void resetForm() {
    setState(() {
      isLoading = false;
      emailController.text = '';
      pswdController.text = '';
      confirmPswdController.text = '';
      _formKey.currentState!.reset();
    });
  }
}
