import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

@immutable
abstract class AudioQuestionBookMarkState {}

class AudioQuestionBookmarkInitial extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchInProgress extends AudioQuestionBookMarkState {}

class AudioQuestionBookmarkFetchSuccess extends AudioQuestionBookMarkState {
  AudioQuestionBookmarkFetchSuccess(this.questions, this.submittedAnswerIds);

  //bookmarked questions
  final List<Question> questions;
  final List<Map<String, String>> submittedAnswerIds;
}

class AudioQuestionBookmarkFetchFailure extends AudioQuestionBookMarkState {
  AudioQuestionBookmarkFetchFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class AudioQuestionBookmarkCubit extends Cubit<AudioQuestionBookMarkState> {
  AudioQuestionBookmarkCubit(this._bookmarkRepository)
      : super(AudioQuestionBookmarkInitial());
  final BookmarkRepository _bookmarkRepository;

  Future<void> getBookmark(String userId) async {
    emit(AudioQuestionBookmarkFetchInProgress());

    try {
      final questions = await _bookmarkRepository.getBookmark('4')
          as List<Question>; //type 4 is for audio questions

      //coming from local database (hive)
      final submittedAnswerIds = await _bookmarkRepository
          .getSubmittedAnswerOfAudioBookmarkedQuestions(
        questions.map((e) => e.id!).toList(),
        userId,
      );

      emit(AudioQuestionBookmarkFetchSuccess(questions, submittedAnswerIds));
    } catch (e) {
      emit(AudioQuestionBookmarkFetchFailure(e.toString()));
    }
  }

  bool hasQuestionBookmarked(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final questions = (state as AudioQuestionBookmarkFetchSuccess).questions;
      return questions.indexWhere((element) => element.id == questionId) != -1;
    }
    return false;
  }

  void addBookmarkQuestion(Question question, String userId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = state as AudioQuestionBookmarkFetchSuccess;
      //set submitted answer for given index initially submitted answer will be empty
      _bookmarkRepository.setAnswerForAudioBookmarkedQuestion(
        question.id!,
        question.submittedAnswerId,
        userId,
      );
      emit(
        AudioQuestionBookmarkFetchSuccess(
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
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = state as AudioQuestionBookmarkFetchSuccess;
      _bookmarkRepository.setAnswerForAudioBookmarkedQuestion(
        question.id!,
        question.submittedAnswerId,
        userId,
      );
      final updatedSubmittedAnswerIds =
          List<Map<String, String>>.from(currentState.submittedAnswerIds);
      //
      updatedSubmittedAnswerIds[updatedSubmittedAnswerIds
          .indexWhere((element) => element.keys.first == question.id)] = {
        question.id!: question.submittedAnswerId,
      };
      emit(
        AudioQuestionBookmarkFetchSuccess(
          List.from(currentState.questions),
          updatedSubmittedAnswerIds,
        ),
      );
    }
  }

  //remove bookmark question and respective submitted answer
  void removeBookmarkQuestion(String? questionId, String userId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = state as AudioQuestionBookmarkFetchSuccess;
      final updatedQuestions = List<Question>.from(currentState.questions);
      final submittedAnswerIds =
          List<Map<String, String>>.from(currentState.submittedAnswerIds);

      updatedQuestions.removeWhere((element) => element.id == questionId);
      submittedAnswerIds
          .removeWhere((element) => element.keys.first == questionId);
      _bookmarkRepository.removeAudioBookmarkedAnswer('$userId-$questionId');
      emit(
        AudioQuestionBookmarkFetchSuccess(
          updatedQuestions,
          submittedAnswerIds,
        ),
      );
    }
  }

  List<Question> questions() {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      return (state as AudioQuestionBookmarkFetchSuccess).questions;
    }
    return [];
  }

  //to get submitted answer title for given quesiton
  String getSubmittedAnswerForQuestion(String? questionId) {
    if (state is AudioQuestionBookmarkFetchSuccess) {
      final currentState = state as AudioQuestionBookmarkFetchSuccess;
      //submitted answer index based on question id
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

  void updateState(AudioQuestionBookMarkState updatedState) {
    emit(updatedState);
  }
}
