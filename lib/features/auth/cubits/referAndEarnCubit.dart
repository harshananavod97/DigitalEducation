import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';

//State
@immutable
abstract class ReferAndEarnState {}

class ReferAndEarnInitial extends ReferAndEarnState {}

class ReferAndEarnProgress extends ReferAndEarnState {}

class ReferAndEarnSuccess extends ReferAndEarnState {
  ReferAndEarnSuccess({required this.userProfile});

  final UserProfile userProfile;
}

class ReferAndEarnFailure extends ReferAndEarnState {
  ReferAndEarnFailure(this.errorMessage);

  final String errorMessage;
}

class ReferAndEarnCubit extends Cubit<ReferAndEarnState> {
  ReferAndEarnCubit(this._authRepository) : super(ReferAndEarnInitial());
  final AuthRepository _authRepository;

  void getReward({
    required UserProfile userProfile,
    required String name,
    required String friendReferralCode,
    required AuthProviders authType,
  }) {
    //emitting signInProgress state
    emit(ReferAndEarnProgress());

    //signIn user with given provider and also add user detials in api
    _authRepository
        .addUserData(
      email: userProfile.email,
      firebaseId: userProfile.firebaseId!,
      friendCode: friendReferralCode,
      mobile: userProfile.mobileNumber,
      name: name,
      type: authType.name,
      profile: userProfile.profileUrl,
    )
        .then((result) {
      emit(ReferAndEarnSuccess(userProfile: UserProfile.fromJson(result)));
    }).catchError((dynamic e) {
      /// FIXME: closed before emit issue in some case.
      emit(ReferAndEarnFailure(e.toString()));
    });
  }
}
