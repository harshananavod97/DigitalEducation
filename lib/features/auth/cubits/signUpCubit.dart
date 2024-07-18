import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';

//State
@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpProgress extends SignUpState {
  SignUpProgress(this.authProvider);

  final AuthProviders authProvider;
}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  SignUpFailure(this.errorMessage, this.authProvider);

  final String errorMessage;
  final AuthProviders authProvider;
}

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authRepository) : super(SignUpInitial());
  final AuthRepository _authRepository;

  //signUp user
  void signUpUser(
    AuthProviders authProvider,
    String email,
    String password,
  ) {
    //emitting signup progress state
    emit(SignUpProgress(authProvider));
    _authRepository
        .signUpUser(email, password)
        .then(
          (value) =>
              //success
              emit(SignUpSuccess()),
        )
        .catchError((dynamic e) {
      //failure
      emit(SignUpFailure(e.toString(), authProvider));
    });
  }
}
