import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

@immutable
abstract class SetCategoryPlayedState {}

class SetCategoryPlayedInitial extends SetCategoryPlayedState {}

class SetCategoryPlayedInProgress extends SetCategoryPlayedState {}

class SetCategoryPlayedSuccess extends SetCategoryPlayedState {}

class SetCategoryPlayedFailure extends SetCategoryPlayedState {
  SetCategoryPlayedFailure(this.errorMessage);

  final String errorMessage;
}

class SetCategoryPlayed extends Cubit<SetCategoryPlayedState> {
  SetCategoryPlayed(this._quizRepository) : super(SetCategoryPlayedInitial());
  final QuizRepository _quizRepository;

  //to update level
  Future<void> setCategoryPlayed({
    required QuizTypes quizType,
    required String categoryId,
    required String subcategoryId,
    required String typeId,
  }) async {
    emit(SetCategoryPlayedInProgress());
    await _quizRepository
        .setQuizCategoryPlayed(
          type: UiUtils.getCategoryTypeNumberFromQuizType(quizType),
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          typeId: typeId,
        )
        .then(
          (val) => emit(SetCategoryPlayedSuccess()),
        )
        .catchError((Object e) {
      emit(SetCategoryPlayedFailure(e.toString()));
    });
  }
}
