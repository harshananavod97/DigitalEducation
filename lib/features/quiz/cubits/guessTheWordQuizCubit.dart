import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

abstract class GuessTheWordQuizState {}

class GuessTheWordQuizIntial extends GuessTheWordQuizState {}

class GuessTheWordQuizFetchInProgress extends GuessTheWordQuizState {}

class GuessTheWordQuizFetchFailure extends GuessTheWordQuizState {
  GuessTheWordQuizFetchFailure(this.errorMessage);

  final String errorMessage;
}

class GuessTheWordQuizFetchSuccess extends GuessTheWordQuizState {
  GuessTheWordQuizFetchSuccess({
    required this.questions,
    required this.currentPoints,
  });

  final List<GuessTheWordQuestion> questions;
  final int currentPoints;
}

class GuessTheWordQuizCubit extends Cubit<GuessTheWordQuizState> {
  GuessTheWordQuizCubit(this._quizRepository) : super(GuessTheWordQuizIntial());
  final QuizRepository _quizRepository;

  void getQuestion({
    required String questionLanguageId,
    required String type, //category or subcategory
    required String typeId, //id of the category or subcategory
  }) {
    emit(GuessTheWordQuizFetchInProgress());
    _quizRepository
        .getGuessTheWordQuestions(
      languageId: questionLanguageId,
      type: type,
      typeId: typeId,
    )
        .then(
      (questions) {
        emit(
          GuessTheWordQuizFetchSuccess(
            questions: questions,
            currentPoints: 0,
          ),
        );
      },
    ).catchError((Object e) {
      emit(GuessTheWordQuizFetchFailure(e.toString()));
    });
  }

  void updateAnswer(String answer, int answerIndex, String questionId) {
    if (state is GuessTheWordQuizFetchSuccess) {
      final questions = (state as GuessTheWordQuizFetchSuccess).questions;
      final questionIndex =
          questions.indexWhere((element) => element.id == questionId);
      final question = questions[questionIndex];
      final updatedAnswer = question.submittedAnswer;
      updatedAnswer[answerIndex] = answer;
      questions[questionIndex] =
          question.copyWith(updatedAnswer: updatedAnswer);

      emit(
        GuessTheWordQuizFetchSuccess(
          questions: questions,
          currentPoints: (state as GuessTheWordQuizFetchSuccess).currentPoints,
        ),
      );
    }
  }

  List<GuessTheWordQuestion> getQuestions() {
    if (state is GuessTheWordQuizFetchSuccess) {
      return (state as GuessTheWordQuizFetchSuccess).questions;
    }
    return [];
  }

  int getCurrentPoints() {
    if (state is GuessTheWordQuizFetchSuccess) {
      return (state as GuessTheWordQuizFetchSuccess).currentPoints;
    }
    return 0;
  }

  void submitAnswer(
    String questionId,
    List<String> answer,
    int correctAnswerPoints,
    int wrongAnswerPoints,
  ) {
    //update hasAnswer and current points

    if (state is GuessTheWordQuizFetchSuccess) {
      final currentState = state as GuessTheWordQuizFetchSuccess;
      final questions = currentState.questions;
      final questionIndex =
          questions.indexWhere((element) => element.id == questionId);
      final question = questions[questionIndex];
      var updatedPoints = currentState.currentPoints;

      questions[questionIndex] =
          question.copyWith(hasAnswerGiven: true, updatedAnswer: answer);

      //check correctness of answer and update current points
      if (UiUtils.buildGuessTheWordQuestionAnswer(answer) == question.answer) {
        updatedPoints = updatedPoints + correctAnswerPoints;
      } else {
        updatedPoints = updatedPoints - wrongAnswerPoints;
      }

      emit(
        GuessTheWordQuizFetchSuccess(
          questions: questions,
          currentPoints: updatedPoints,
        ),
      );
    }
  }

  void updateState(GuessTheWordQuizState updatedState) {
    emit(updatedState);
  }
}
