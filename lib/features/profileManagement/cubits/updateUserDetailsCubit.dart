import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UpdateUserDetailState {}

class UpdateUserDetailInitial extends UpdateUserDetailState {}

class UpdateUserDetailInProgress extends UpdateUserDetailState {}

class UpdateUserDetailSuccess extends UpdateUserDetailState {}

class UpdateUserDetailFailure extends UpdateUserDetailState {
  UpdateUserDetailFailure(this.errorMessage);

  final String errorMessage;
}

class UpdateUserDetailCubit extends Cubit<UpdateUserDetailState> {
  UpdateUserDetailCubit(this._profileManagementRepository)
      : super(UpdateUserDetailInitial());
  final ProfileManagementRepository _profileManagementRepository;

  void updateState(UpdateUserDetailState newState) {
    emit(newState);
  }

  void removeAdsForUser({required bool status}) {
    emit(UpdateUserDetailInProgress());
    _profileManagementRepository
        .removeAdsForUser(status: status)
        .then((value) => emit(UpdateUserDetailSuccess()))
        .catchError((Object e) => emit(UpdateUserDetailFailure(e.toString())));
  }

  Future<void> updateProfile({
    required String email,
    required String name,
    required String mobile,
  }) async {
    emit(UpdateUserDetailInProgress());
    await _profileManagementRepository
        .updateProfile(
      email: email,
      mobile: mobile,
      name: name,
    )
        .then((value) {
      emit(UpdateUserDetailSuccess());
    }).catchError((Object e) {
      emit(UpdateUserDetailFailure(e.toString()));
    });
  }
}
