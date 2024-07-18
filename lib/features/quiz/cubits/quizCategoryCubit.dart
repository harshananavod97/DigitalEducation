import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class QuizCategoryState {}

class QuizCategoryInitial extends QuizCategoryState {}

class QuizCategoryProgress extends QuizCategoryState {}

class QuizCategorySuccess extends QuizCategoryState {
  QuizCategorySuccess(this.categories);

  final List<Category> categories;
}

class QuizCategoryFailure extends QuizCategoryState {
  QuizCategoryFailure(this.errorMessage);

  final String errorMessage;
}

class QuizCategoryCubit extends Cubit<QuizCategoryState> {
  QuizCategoryCubit(this._quizRepository) : super(QuizCategoryInitial());
  final QuizRepository _quizRepository;

  Future<void> getQuizCategoryWithUserId({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    emit(QuizCategoryProgress());
    await _quizRepository
        .getCategory(
          languageId: languageId,
          type: type,
          subType: subType,
        )
        .then((v) => emit(QuizCategorySuccess(v)))
        .catchError((Object e) => emit(QuizCategoryFailure(e.toString())));
  }

  Future<void> getQuizCategory({
    required String languageId,
    required String type,
  }) async {
    emit(QuizCategoryProgress());
    await _quizRepository
        .getCategoryWithoutUser(languageId: languageId, type: type)
        .then((v) => emit(QuizCategorySuccess(v)))
        .catchError((Object e) => emit(QuizCategoryFailure(e.toString())));
  }

  void updateState(QuizCategoryState updatedState) {
    emit(updatedState);
  }

  void unlockPremiumCategory({required String id}) {
    if (state is QuizCategorySuccess) {
      final categories = (state as QuizCategorySuccess).categories;

      final idx = categories.indexWhere((c) => c.id == id);

      if (idx != -1) {
        emit(QuizCategoryProgress());

        categories[idx] = categories[idx].copyWith(hasUnlocked: true);

        emit(QuizCategorySuccess(categories));
      }
    }
  }

  bool isPremiumCategoryUnlocked(String categoryId) {
    if (state is QuizCategorySuccess) {
      final categories = (state as QuizCategorySuccess).categories;

      final idx = categories.indexWhere((c) => c.id == categoryId);

      if (idx != -1) {
        final cate = categories[idx];
        return !cate.isPremium || (cate.isPremium && cate.hasUnlocked);
      }
    }
    return false;
  }

  Object getCat() {
    if (state is QuizCategorySuccess) {
      return (state as QuizCategorySuccess).categories;
    }
    return '';
  }
}
