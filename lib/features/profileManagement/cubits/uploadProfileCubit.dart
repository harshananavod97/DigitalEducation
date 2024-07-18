import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UploadProfileState {}

class UploadProfileInitial extends UploadProfileState {}

class UploadProfileInProgress extends UploadProfileState {}

class UploadProfileSuccess extends UploadProfileState {
  UploadProfileSuccess(this.imageUrl);

  final String imageUrl;
}

class UploadProfileFailure extends UploadProfileState {
  UploadProfileFailure(this.errorMessage);

  final String errorMessage;
}

class UploadProfileCubit extends Cubit<UploadProfileState> {
  UploadProfileCubit(this._profileManagementRepository)
      : super(UploadProfileInitial());
  final ProfileManagementRepository _profileManagementRepository;

  Future<void> uploadProfilePicture(File? file) async {
    emit(UploadProfileInProgress());
    try {
      final imageUrl =
          await _profileManagementRepository.uploadProfilePicture(file);
      //success
      emit(UploadProfileSuccess(imageUrl));
    } catch (e) {
      //failure
      emit(UploadProfileFailure(e.toString()));
    }
  }
}
