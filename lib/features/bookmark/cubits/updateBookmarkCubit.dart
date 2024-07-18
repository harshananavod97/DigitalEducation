import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';

@immutable
abstract class UpdateBookmarkState {}

class UpdateBookmarkIntial extends UpdateBookmarkState {}

class UpdateBookmarkInProgress extends UpdateBookmarkState {}

class UpdateBookmarkSuccess extends UpdateBookmarkState {}

class UpdateBookmarkFailure extends UpdateBookmarkState {
  UpdateBookmarkFailure(this.errorMessageCode, this.failedStatus);

  final String errorMessageCode;
  final String failedStatus;
}

class UpdateBookmarkCubit extends Cubit<UpdateBookmarkState> {
  UpdateBookmarkCubit(this._bookmarkRepository) : super(UpdateBookmarkIntial());
  final BookmarkRepository _bookmarkRepository;

  Future<void> updateBookmark(
    String questionId,
    String status,
    String type,
  ) async {
    emit(UpdateBookmarkInProgress());
    try {
      await _bookmarkRepository.updateBookmark(
        questionId,
        status,
        type,
      );
      emit(UpdateBookmarkSuccess());
    } catch (e) {
      emit(UpdateBookmarkFailure(e.toString(), status));
    }
  }
}
