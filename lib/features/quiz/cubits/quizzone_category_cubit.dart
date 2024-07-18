import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class QuizoneCategoryState {}

class QuizoneCategoryInitial extends QuizoneCategoryState {}

class QuizoneCategoryProgress extends QuizoneCategoryState {}

class QuizoneCategorySuccess extends QuizoneCategoryState {
  QuizoneCategorySuccess(this.categories);

  final List<Category> categories;
}

class QuizoneCategoryFailure extends QuizoneCategoryState {
  QuizoneCategoryFailure(this.errorMessage);

  final String errorMessage;
}

class QuizoneCategoryCubit extends Cubit<QuizoneCategoryState> {
  QuizoneCategoryCubit(this._quizRepository) : super(QuizoneCategoryInitial());
  final QuizRepository _quizRepository;

  Future<void> getQuizCategoryWithUserId({required String languageId}) async {
    emit(QuizoneCategoryProgress());
    await _quizRepository
        .getCategory(languageId: languageId, type: '1')
        .then((v) => emit(QuizoneCategorySuccess(v)))
        .catchError((Object e) => emit(QuizoneCategoryFailure(e.toString())));
  }

  Future<void> getQuizCategory({required String languageId}) async {
    emit(QuizoneCategoryProgress());
    await _quizRepository
        .getCategoryWithoutUser(languageId: languageId, type: '1')
        .then((v) => emit(QuizoneCategorySuccess(v)))
        .catchError((Object e) => emit(QuizoneCategoryFailure(e.toString())));
  }

  void unlockPremiumCategory({required String id}) {
    if (state is QuizoneCategorySuccess) {
      final categories = (state as QuizoneCategorySuccess).categories;

      final idx = categories.indexWhere((c) => c.id == id);

      if (idx != -1) {
        emit(QuizoneCategoryProgress());

        categories[idx] = categories[idx].copyWith(hasUnlocked: true);

        emit(QuizoneCategorySuccess(categories));
      }
    }
  }
}
