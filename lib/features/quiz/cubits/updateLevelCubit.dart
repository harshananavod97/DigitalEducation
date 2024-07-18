import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class UpdateLevelState {}

class UpdateLevelInitial extends UpdateLevelState {}

class UpdateLevelInProgress extends UpdateLevelState {}

class UpdateLevelSuccess extends UpdateLevelState {}

class UpdateLevelFailure extends UpdateLevelState {
  UpdateLevelFailure(this.errorMessage);

  final String errorMessage;
}

class UpdateLevelCubit extends Cubit<UpdateLevelState> {
  UpdateLevelCubit(this._quizRepository) : super(UpdateLevelInitial());
  final QuizRepository _quizRepository;

  Future<void> updateLevel(
    String category,
    String subCategory,
    String level,
  ) async {
    emit(UpdateLevelInProgress());
    try {
      await _quizRepository.updateLevel(
        category: category,
        level: level,
        subCategory: subCategory,
      );

      emit(UpdateLevelSuccess());
    } catch (e) {
      emit(UpdateLevelFailure(e.toString()));
    }
  }
}
