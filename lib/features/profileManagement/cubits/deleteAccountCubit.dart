import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {}

class DeleteAccountFailure extends DeleteAccountState {
  DeleteAccountFailure(this.errorMessage);

  final String errorMessage;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._profileManagementRepository)
      : super(DeleteAccountInitial());
  final ProfileManagementRepository _profileManagementRepository;

  void deleteUserAccount() {
    //
    emit(DeleteAccountInProgress());
    _profileManagementRepository.deleteAccount().then((value) {
      //
      emit(DeleteAccountSuccess());
    }).catchError((Object e) {
      //
      emit(DeleteAccountFailure(e.toString()));
    });
  }
}
