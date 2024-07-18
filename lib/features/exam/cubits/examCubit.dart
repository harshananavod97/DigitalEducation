import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/exam/examRepository.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';

abstract class ExamState {}

class ExamInitial extends ExamState {}

class ExamFetchInProgress extends ExamState {}

class ExamFetchFailure extends ExamState {
  ExamFetchFailure(this.errorMessage);

  final String errorMessage;
}

class ExamFetchSuccess extends ExamState {
  ExamFetchSuccess({required this.exam, required this.questions});

  final List<Question> questions;
  final Exam exam;
}

class ExamCubit extends Cubit<ExamState> {
  ExamCubit(this._examRepository) : super(ExamInitial());
  final ExamRepository _examRepository;

  void updateState(ExamState newState) {
    emit(newState);
  }

  Future<void> startExam({required Exam exam}) async {
    emit(ExamFetchInProgress());
    try {
      final questions = await _examRepository.getExamQuestions(examId: exam.id);

      //check if user can give exam or not
      //if user is in exam then it will throw 103 error means fill all data
      await _examRepository.updateExamStatusToInExam(examModuleId: exam.id);
      await _examRepository.examLocalDataSource.addExamModuleId(exam.id);
      emit(
        ExamFetchSuccess(exam: exam, questions: arrangeQuestions(questions)),
      );
    } catch (e) {
      emit(ExamFetchFailure(e.toString()));
    }
  }

  List<Question> arrangeQuestions(List<Question> questions) {
    final arrangedQuestions = <Question>[];

    final marks = questions.map((q) => q.marks!).toSet().toList()
      ..sort((f, s) => f.compareTo(s));

    //arrange questions from low to high marks
    for (final questionMark in marks) {
      arrangedQuestions.addAll(
        questions.where((e) => e.marks == questionMark).toList(),
      );
    }

    return arrangedQuestions;
  }

  int getQuestionIndexById(String questionId) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .indexWhere((element) => element.id == questionId);
    }
    return 0;
  }

  //submitted AnswerId will contain -1, 0 or optionId (a,b,c,d,e)
  void updateQuestionWithAnswer(String questionId, String submittedAnswerId) {
    if (state is ExamFetchSuccess) {
      final updatedQuestions = (state as ExamFetchSuccess).questions;
      //fetching index of question that need to update with submittedAnswer
      final questionIndex =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
          .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);

      emit(
        ExamFetchSuccess(
          exam: (state as ExamFetchSuccess).exam,
          questions: updatedQuestions,
        ),
      );
    }
  }

  List<Question> getQuestions() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).questions;
    }
    return [];
  }

  Exam getExam() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).exam;
    }
    return Exam.fromJson({});
  }

  bool canUserSubmitAnswerAgainInExam() {
    return getExam().answerAgain == '1';
  }

  void submitResult({
    required String userId,
    required String totalDuration,
    required bool rulesViolated,
    required List<String> capturedQuestionIds,
  }) {
    if (state is ExamFetchSuccess) {
      final markStatistics = <Statistics>[];

      getUniqueQuestionMark().forEach((mark) {
        final questions = getQuestionsByMark(mark);
        final correctAnswers = questions
            .where(
              (e) =>
                  e.submittedAnswerId ==
                  AnswerEncryption.decryptCorrectAnswer(
                    rawKey: userId,
                    correctAnswer: e.correctAnswer!,
                  ),
            )
            .toList()
            .length;
        final statistics = Statistics(
          mark: mark,
          correctAnswer: correctAnswers.toString(),
          incorrect: (questions.length - correctAnswers).toString(),
        );
        markStatistics.add(statistics);
      });

      //
      _examRepository.submitExamResult(
        capturedQuestionIds: capturedQuestionIds,
        rulesViolated: rulesViolated,
        obtainedMarks: obtainedMarks(userId).toString(),
        examModuleId: (state as ExamFetchSuccess).exam.id,
        totalDuration: totalDuration,
        statistics: markStatistics.map((e) => e.toJson()).toList(),
      );

      _examRepository.examLocalDataSource
          .removeExamModuleId((state as ExamFetchSuccess).exam.id);
    }
  }

  int correctAnswers(String userId) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .where(
            (e) =>
                e.submittedAnswerId ==
                AnswerEncryption.decryptCorrectAnswer(
                  rawKey: userId,
                  correctAnswer: e.correctAnswer!,
                ),
          )
          .toList()
          .length;
    }
    return 0;
  }

  int incorrectAnswers(String userId) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess).questions.length -
          correctAnswers(userId);
    }
    return 0;
  }

  int obtainedMarks(String userId) {
    if (state is ExamFetchSuccess) {
      final correctAnswers = (state as ExamFetchSuccess)
          .questions
          .where(
            (element) =>
                element.submittedAnswerId ==
                AnswerEncryption.decryptCorrectAnswer(
                  rawKey: userId,
                  correctAnswer: element.correctAnswer!,
                ),
          )
          .toList();
      var obtainedMark = 0;

      for (final element in correctAnswers) {
        obtainedMark = obtainedMark + int.parse(element.marks ?? '0');
      }

      return obtainedMark;
    }
    return 0;
  }

  List<Question> getQuestionsByMark(String questionMark) {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .where((question) => question.marks == questionMark)
          .toList();
    }
    return [];
  }

  List<String> getUniqueQuestionMark() {
    if (state is ExamFetchSuccess) {
      return (state as ExamFetchSuccess)
          .questions
          .map((question) => question.marks!)
          .toSet()
          .toList();
    }
    return [];
  }

  void completePendingExams() {
    _examRepository.completePendingExams();
  }
}
