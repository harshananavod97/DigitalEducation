import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class SetContestLeaderboardState {}

class SetContestLeaderboardInitial extends SetContestLeaderboardState {}

class SetContestLeaderboardProgress extends SetContestLeaderboardState {}

class SetContestLeaderboardSuccess extends SetContestLeaderboardState {}

class SetContestLeaderboardFailure extends SetContestLeaderboardState {
  SetContestLeaderboardFailure(this.errorMessage);

  final String errorMessage;
}

class SetContestLeaderboardCubit extends Cubit<SetContestLeaderboardState> {
  SetContestLeaderboardCubit(this._quizRepository)
      : super(SetContestLeaderboardInitial());
  final QuizRepository _quizRepository;

  Future<void> setContestLeaderboard({
    String? contestId,
    int? questionAttended,
    int? correctAns,
    int? score,
  }) async {
    emit(SetContestLeaderboardProgress());
    try {
      await _quizRepository.setContestLeaderboard(
        contestId: contestId,
        questionAttended: questionAttended,
        correctAns: correctAns,
        score: score,
      );
      emit(SetContestLeaderboardSuccess());
    } catch (e) {
      emit(SetContestLeaderboardFailure(e.toString()));
    }
  }
}
