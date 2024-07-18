import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

@immutable
abstract class GuessTheWordBookmarkState {}

class GuessTheWordBookmarkInitial extends GuessTheWordBookmarkState {}

class GuessTheWordBookmarkFetchInProgress extends GuessTheWordBookmarkState {}

class GuessTheWordBookmarkFetchSuccess extends GuessTheWordBookmarkState {
  GuessTheWordBookmarkFetchSuccess(this.questions, this.submittedAnswers);

  //bookmarked questions
  final List<GuessTheWordQuestion> questions;

  //submitted answer id for questions we can get submitted answer id for given quesiton
  //by comparing index of these two lists
  final List<Map<String, String>> submittedAnswers;
}

class GuessTheWordBookmarkFetchFailure extends GuessTheWordBookmarkState {
  GuessTheWordBookmarkFetchFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class GuessTheWordBookmarkCubit extends Cubit<GuessTheWordBookmarkState> {
  GuessTheWordBookmarkCubit(this._bookmarkRepository)
      : super(GuessTheWordBookmarkInitial());
  final BookmarkRepository _bookmarkRepository;

  Future<void> getBookmark(String userId) async {
    emit(GuessTheWordBookmarkFetchInProgress());

    try {
      final questions = await _bookmarkRepository.getBookmark('3')
          as List<GuessTheWordQuestion>; //type 3 is for guess the word

      //coming from local database (hive)
      final submittedAnswers = await _bookmarkRepository
          .getSubmittedAnswerOfGuessTheWordBookmarkedQuestions(
        questions.map((e) => e.id).toList(),
        userId,
      );

      // print("+++ GuessTheWord: Bookmark fetch success");

      emit(GuessTheWordBookmarkFetchSuccess(questions, submittedAnswers));
    } catch (e) {
      emit(GuessTheWordBookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final questions = (state as GuessTheWordBookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(GuessTheWordQuestion question, String userId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = state as GuessTheWordBookmarkFetchSuccess;
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForGuessTheWordBookmarkedQuestion(
        question.id,
        UiUtils.buildGuessTheWordQuestionAnswer(question.submittedAnswer),
        userId,
      );

      emit(
        GuessTheWordBookmarkFetchSuccess(
          List.from(currentState.questions)..insert(0, question),
          List.from(currentState.submittedAnswers)
            ..insert(0, {
              question.id: UiUtils.buildGuessTheWordQuestionAnswer(
                question.submittedAnswer,
              ),
            }),
        ),
      );
    }
  }

  //we need to update submitted answer for given queston index
  //this will be call after user has given answer for question and question has been bookmarked
  void updateSubmittedAnswer({
    required String questionId,
    required String submittedAnswer,
    required String userId,
  }) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = state as GuessTheWordBookmarkFetchSuccess;

      //update the answer
      _bookmarkRepository.setAnswerForGuessTheWordBookmarkedQuestion(
        questionId,
        submittedAnswer,
        userId,
      );

      //update state
      final updatedSubmittedAnswers =
          List<Map<String, String>>.from(currentState.submittedAnswers);

      updatedSubmittedAnswers[currentState.submittedAnswers
          //There will be only one key in map
          .indexWhere((element) => element.keys.first == questionId)] = {
        questionId: submittedAnswer,
      };
      emit(
        GuessTheWordBookmarkFetchSuccess(
          List.from(currentState.questions),
          updatedSubmittedAnswers,
        ),
      );
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String questionId, String userId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = state as GuessTheWordBookmarkFetchSuccess;
      final updatedQuestions =
          List<GuessTheWordQuestion>.from(currentState.questions);
      final submittedAnswerIds =
          List<Map<String, String>>.from(currentState.submittedAnswers);

      updatedQuestions.removeWhere((element) => element.id == questionId);
      submittedAnswerIds
          .removeWhere((element) => element.keys.first == questionId);
      _bookmarkRepository
          .removeGuessTheWordBookmarkedAnswer('$userId-$questionId');
      emit(
        GuessTheWordBookmarkFetchSuccess(
          updatedQuestions,
          submittedAnswerIds,
        ),
      );
    }
  }

  List<GuessTheWordQuestion> questions() {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      return (state as GuessTheWordBookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String questionId) {
    if (state is GuessTheWordBookmarkFetchSuccess) {
      final currentState = state as GuessTheWordBookmarkFetchSuccess;
      //current question
      final index = currentState.submittedAnswers
          .indexWhere((element) => element.keys.first == questionId);
      if (currentState.submittedAnswers[index][questionId]!.isEmpty) {
        return 'unAttemptedLbl';
      }

      return currentState.submittedAnswers[index][questionId]!;
    }
    return '';
  }

  void updateState(GuessTheWordBookmarkState updatedState) {
    emit(updatedState);
  }
}
