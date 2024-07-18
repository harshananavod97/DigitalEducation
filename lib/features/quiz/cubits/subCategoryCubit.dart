import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryFetchInProgress extends SubCategoryState {}

class SubCategoryFetchSuccess extends SubCategoryState {
  SubCategoryFetchSuccess(this.categoryId, this.subcategoryList);

  final List<Subcategory> subcategoryList;
  final String? categoryId;
}

class SubCategoryFetchFailure extends SubCategoryState {
  SubCategoryFetchFailure(this.errorMessage);

  final String errorMessage;
}

class SubCategoryCubit extends Cubit<SubCategoryState> {
  SubCategoryCubit(this._quizRepository) : super(SubCategoryInitial());
  final QuizRepository _quizRepository;

  Future<void> fetchSubCategory(String category) async {
    emit(SubCategoryFetchInProgress());
    await _quizRepository
        .getSubCategory(category)
        .then((val) => emit(SubCategoryFetchSuccess(category, val)))
        .catchError((Object e) {
      emit(SubCategoryFetchFailure(e.toString()));
    });
  }

  void updateState(SubCategoryState updatedState) {
    emit(updatedState);
  }

  void unlockPremiumSubCategory({
    required String categoryId,
    required String id,
  }) {
    if (state is SubCategoryFetchSuccess) {
      final subcategories = (state as SubCategoryFetchSuccess).subcategoryList;

      final idx = subcategories.indexWhere((s) => s.id == id);

      if (idx != -1) {
        emit(SubCategoryFetchInProgress());
        subcategories[idx] = subcategories[idx].copyWith(hasUnlocked: true);
        emit(SubCategoryFetchSuccess(categoryId, subcategories));
      }
    }
  }
}
