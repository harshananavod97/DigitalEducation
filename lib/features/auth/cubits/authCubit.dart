import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authModel.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';

//authentication provider
enum AuthProviders { gmail, fb, email, mobile, apple }

//State
@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.authModel});

  //to store authDetials
  final AuthModel authModel;
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  final AuthRepository _authRepository;

  AuthProviders getAuthProvider() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.authProvider;
    }
    return AuthProviders.email;
  }

  void _checkAuthStatus() {
    //authDetails is map. keys are isLogin,userId,authProvider,jwtToken
    final authDetails = _authRepository.getLocalAuthDetails();

    if (authDetails['isLogin'] as bool) {
      emit(Authenticated(authModel: AuthModel.fromJson(authDetails)));
    } else {
      emit(Unauthenticated());
    }
  }

  //to update auth status
  void updateAuthDetails({
    String? firebaseId,
    AuthProviders? authProvider,
    bool? authStatus,
    bool? isNewUser,
  }) {
    //updating authDetails locally
    _authRepository.setLocalAuthDetails(
      jwtToken: '',
      firebaseId: firebaseId,
      authType: authProvider!.name,
      authStatus: authStatus,
      isNewUser: isNewUser,
    );

    //emitting new state in cubit
    emit(
      Authenticated(
        authModel: AuthModel(
          jwtToken: '',
          firebaseId: firebaseId!,
          authProvider: authProvider,
          isNewUser: isNewUser!,
        ),
      ),
    );
  }

  //to signout
  void signOut() {
    if (state is Authenticated) {
      _authRepository.signOut((state as Authenticated).authModel.authProvider);
      emit(Unauthenticated());
    }
  }
}
