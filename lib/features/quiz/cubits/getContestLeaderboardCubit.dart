import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/contestLeaderboard.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class GetContestLeaderboardState {}

class GetContestLeaderboardInitial extends GetContestLeaderboardState {}

class GetContestLeaderboardProgress extends GetContestLeaderboardState {}

class GetContestLeaderboardSuccess extends GetContestLeaderboardState {
  GetContestLeaderboardSuccess(this.getContestLeaderboardList);

  final List<ContestLeaderboard> getContestLeaderboardList;
}

class GetContestLeaderboardFailure extends GetContestLeaderboardState {
  GetContestLeaderboardFailure(this.errorMessage);

  final String errorMessage;
}

class GetContestLeaderboardCubit extends Cubit<GetContestLeaderboardState> {
  GetContestLeaderboardCubit(this._quizRepository)
      : super(GetContestLeaderboardInitial());
  final QuizRepository _quizRepository;

  Future<void> getContestLeaderboard({String? contestId}) async {
    emit(GetContestLeaderboardProgress());
    await _quizRepository
        .getContestLeaderboard(contestId: contestId)
        .then((val) => emit(GetContestLeaderboardSuccess(val)))
        .catchError(
          (Object e) => emit(GetContestLeaderboardFailure(e.toString())),
        );
  }
}
