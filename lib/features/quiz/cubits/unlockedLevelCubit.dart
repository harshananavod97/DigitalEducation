import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class UnlockedLevelState {}

class UnlockedLevelInitial extends UnlockedLevelState {}

class UnlockedLevelFetchInProgress extends UnlockedLevelState {}

class UnlockedLevelFetchSuccess extends UnlockedLevelState {
  UnlockedLevelFetchSuccess(
    this.categoryId,
    this.subcategoryId,
    this.unlockedLevel,
  );

  final int unlockedLevel;
  final String? categoryId;
  final String? subcategoryId;
}

class UnlockedLevelFetchFailure extends UnlockedLevelState {
  UnlockedLevelFetchFailure(this.errorMessage);

  final String errorMessage;
}

class UnlockedLevelCubit extends Cubit<UnlockedLevelState> {
  UnlockedLevelCubit(this._quizRepository) : super(UnlockedLevelInitial());
  final QuizRepository _quizRepository;

  Future<void> fetchUnlockLevel(String category, String subCategory) async {
    emit(UnlockedLevelFetchInProgress());
    await _quizRepository
        .getUnlockedLevel(category, subCategory)
        .then(
          (val) => emit(UnlockedLevelFetchSuccess(category, subCategory, val)),
        )
        .catchError((Object e) {
      emit(UnlockedLevelFetchFailure(e.toString()));
    });
  }
}
