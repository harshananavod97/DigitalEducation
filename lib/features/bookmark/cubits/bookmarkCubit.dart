import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

@immutable
abstract class BookmarkState {}

class BookmarkInitial extends BookmarkState {}

class BookmarkFetchInProgress extends BookmarkState {}

class BookmarkFetchSuccess extends BookmarkState {
  BookmarkFetchSuccess(this.questions, this.submittedAnswerIds);

  //bookmarked questions
  final List<Question> questions;

  //submitted answer id for questions we can get submitted answer id for given quesiton
  //by comparing index of these two lists
  final List<Map<String, String>> submittedAnswerIds;
}

class BookmarkFetchFailure extends BookmarkState {
  BookmarkFetchFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit(this._bookmarkRepository) : super(BookmarkInitial());
  final BookmarkRepository _bookmarkRepository;

  Future<void> getBookmark(String userId) async {
    emit(BookmarkFetchInProgress());

    try {
      final questions = await _bookmarkRepository.getBookmark('1')
          as List<Question>; //type 1 is for quiz zone

      //coming from local database (hive)
      final submittedAnswerIds =
          await _bookmarkRepository.getSubmittedAnswerOfBookmarkedQuestions(
        questions.map((e) => e.id!).toList(),
        userId,
      );

      emit(BookmarkFetchSuccess(questions, submittedAnswerIds));
    } catch (e) {
      emit(BookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is BookmarkFetchSuccess) {
      final questions = (state as BookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(Question question, String userId) {
    if (state is BookmarkFetchSuccess) {
      final currentState = state as BookmarkFetchSuccess;
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForBookmarkedQuestion(
        question.id!,
        question.submittedAnswerId,
        userId,
      );
      emit(
        BookmarkFetchSuccess(
          List.from(currentState.questions)
            ..insert(
              0,
              question.updateQuestionWithAnswer(submittedAnswerId: ''),
            ),
          List.from(currentState.submittedAnswerIds)
            ..insert(0, {question.id!: question.submittedAnswerId}),
        ),
      );
    }
  }

  //we need to update submitted answer for given queston index
  //this will be call after user has given answer for question and question has been bookmarked
  void updateSubmittedAnswerId(Question question, String userId) {
    if (state is BookmarkFetchSuccess) {
      final currentState = state as BookmarkFetchSuccess;
      _bookmarkRepository.setAnswerForBookmarkedQuestion(
        question.id!,
        question.submittedAnswerId,
        userId,
      );
      final updatedSubmittedAnswerIds =
          List<Map<String, String>>.from(currentState.submittedAnswerIds);

      //
      //In submittedAnswerIds it will have only one key so
      //first key will be the questionId
      updatedSubmittedAnswerIds[updatedSubmittedAnswerIds
          .indexWhere((element) => element.keys.first == question.id)] = {
        question.id!: question.submittedAnswerId,
      };
      emit(
        BookmarkFetchSuccess(
          List.from(currentState.questions),
          updatedSubmittedAnswerIds,
        ),
      );
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String? questionId, String userId) {
    if (state is BookmarkFetchSuccess) {
      final currentState = state as BookmarkFetchSuccess;
      final updatedQuestions = List<Question>.from(currentState.questions);
      final submittedAnswerIds =
          List<Map<String, String>>.from(currentState.submittedAnswerIds);

      updatedQuestions.removeWhere((element) => element.id == questionId);
      submittedAnswerIds
          .removeWhere((element) => element.keys.first == questionId);
      _bookmarkRepository.removeBookmarkedAnswer('$userId-$questionId');
      emit(
        BookmarkFetchSuccess(
          updatedQuestions,
          submittedAnswerIds,
        ),
      );
    }
  }

  List<Question> questions() {
    if (state is BookmarkFetchSuccess) {
      return (state as BookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String? questionId) {
    if (state is BookmarkFetchSuccess) {
      final currentState = state as BookmarkFetchSuccess;
      //submitted answer index
      final index = currentState.submittedAnswerIds
          .indexWhere((element) => element.keys.first == questionId);

      if (currentState.submittedAnswerIds[index][questionId]!.isEmpty ||
          currentState.submittedAnswerIds[index][questionId] == '-1' ||
          currentState.submittedAnswerIds[index][questionId] == '0') {
        return 'unAttemptedLbl';
      }

      final question = currentState.questions
          .where((element) => element.id == questionId)
          .toList()
          .first;

      final submittedAnswerOptionIndex = question.answerOptions!.indexWhere(
        (element) =>
            element.id == currentState.submittedAnswerIds[index][questionId],
      );

      return question.answerOptions![submittedAnswerOptionIndex].title!;
    }
    return '';
  }

  void updateState(BookmarkState updatedState) {
    emit(updatedState);
  }
}
