import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/leaderBoard/leaderboardException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

@immutable
abstract class LeaderBoardMonthlyState {}

class LeaderBoardMonthlyInitial extends LeaderBoardMonthlyState {}

class LeaderBoardMonthlyProgress extends LeaderBoardMonthlyState {}

class LeaderBoardMonthlySuccess extends LeaderBoardMonthlyState {
  LeaderBoardMonthlySuccess(
    this.leaderBoardDetails,
    this.totalData, {
    required this.hasMore,
  });

  final List<Map<String, dynamic>> leaderBoardDetails;
  final int totalData;
  final bool hasMore;
}

class LeaderBoardMonthlyFailure extends LeaderBoardMonthlyState {
  LeaderBoardMonthlyFailure(this.errorMessage);

  final String errorMessage;
}

class LeaderBoardMonthlyCubit extends Cubit<LeaderBoardMonthlyState> {
  LeaderBoardMonthlyCubit() : super(LeaderBoardMonthlyInitial());
  static late String profileM;
  static late String nameM;
  static late String scoreM;
  static late String rankM;

  Future<({int total, List<Map<String, dynamic>> otherUsersRanks})> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      final body = <String, String>{
        limitKey: limit,
        offsetKey: offset ?? '',
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(
        Uri.parse(getMonthlyLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw LeaderBoardException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      final total = int.parse(responseJson['total'] as String? ?? '0');
      final data = responseJson['data'] as Map<String, dynamic>;

      if (total != 0) {
        final myRank = data['my_rank'] as Map<String, dynamic>;

        nameM = myRank[nameKey].toString();
        rankM = myRank[userRankKey].toString();
        profileM = myRank[profileKey].toString();
        scoreM = myRank[scoreKey].toString();
      } else {
        nameM = '';
        rankM = '';
        profileM = '';
        scoreM = '0';
      }

      return (
        total: total,
        otherUsersRanks:
            (data['other_users_rank'] as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      throw LeaderBoardException(errorMessageCode: e.toString());
    }
  }

  void fetchLeaderBoard(String limit) {
    emit(LeaderBoardMonthlyProgress());
    _fetchData(limit: limit).then((v) {
      emit(
        LeaderBoardMonthlySuccess(
          v.otherUsersRanks,
          v.total,
          hasMore: v.total > v.otherUsersRanks.length,
        ),
      );
    }).catchError((dynamic e) {
      emit(LeaderBoardMonthlyFailure(e.toString()));
    });
  }

  void fetchMoreLeaderBoardData(String limit) {
    _fetchData(
      limit: limit,
      offset: (state as LeaderBoardMonthlySuccess)
          .leaderBoardDetails
          .length
          .toString(),
    ).then((v) {
      final oldState = state as LeaderBoardMonthlySuccess;

      final updatedUserDetails = oldState.leaderBoardDetails
        ..addAll(v.otherUsersRanks);

      emit(
        LeaderBoardMonthlySuccess(
          updatedUserDetails,
          oldState.totalData,
          hasMore: oldState.totalData > updatedUserDetails.length,
        ),
      );
    }).catchError((dynamic e) {
      emit(LeaderBoardMonthlyFailure(e.toString()));
    });
  }

  // ignore: avoid_bool_literals_in_conditional_expressions
  bool hasMoreData() => state is LeaderBoardMonthlySuccess
      ? (state as LeaderBoardMonthlySuccess).hasMore
      : false;
}
