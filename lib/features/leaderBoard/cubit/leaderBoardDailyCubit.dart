import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/leaderBoard/leaderboardException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

@immutable
abstract class LeaderBoardDailyState {}

class LeaderBoardDailyInitial extends LeaderBoardDailyState {}

class LeaderBoardDailyProgress extends LeaderBoardDailyState {}

class LeaderBoardDailySuccess extends LeaderBoardDailyState {
  LeaderBoardDailySuccess(
    this.leaderBoardDetails,
    this.totalData, {
    required this.hasMore,
  });

  final List<Map<String, dynamic>> leaderBoardDetails;
  final int totalData;
  final bool hasMore;
}

class LeaderBoardDailyFailure extends LeaderBoardDailyState {
  LeaderBoardDailyFailure(this.errorMessage);

  final String errorMessage;
}

class LeaderBoardDailyCubit extends Cubit<LeaderBoardDailyState> {
  LeaderBoardDailyCubit() : super(LeaderBoardDailyInitial());
  static late String profileD;
  static late String nameD;
  static late String scoreD;
  static late String rankD;

  Future<({int total, List<Map<String, dynamic>> otherUsersRanks})> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      final body = <String, String>{
        limitKey: limit,
        offsetKey: offset ?? '',
      };

      if (offset == null) body.remove(offset);

      final response = await http.post(
        Uri.parse(getDailyLeaderboardUrl),
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

        nameD = myRank['name'].toString();
        rankD = myRank['user_rank'].toString();
        profileD = myRank[profileKey].toString();
        scoreD = myRank['score'].toString();
      } else {
        nameD = '';
        rankD = '';
        profileD = '';
        scoreD = '0';
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
    emit(LeaderBoardDailyProgress());
    _fetchData(limit: limit).then((v) {
      emit(
        LeaderBoardDailySuccess(
          v.otherUsersRanks,
          v.total,
          hasMore: v.total > v.otherUsersRanks.length,
        ),
      );
    }).catchError((dynamic e) {
      emit(LeaderBoardDailyFailure(e.toString()));
    });
  }

  void fetchMoreLeaderBoardData(String limit) {
    _fetchData(
      limit: limit,
      offset: (state as LeaderBoardDailySuccess)
          .leaderBoardDetails
          .length
          .toString(),
    ).then((v) {
      final oldState = state as LeaderBoardDailySuccess;
      final updatedUserDetails = oldState.leaderBoardDetails
        ..addAll(v.otherUsersRanks);

      emit(
        LeaderBoardDailySuccess(
          updatedUserDetails,
          oldState.totalData,
          hasMore: oldState.totalData > updatedUserDetails.length,
        ),
      );
    }).catchError((dynamic e) {
      emit(LeaderBoardDailyFailure(e.toString()));
    });
  }

  // ignore: avoid_bool_literals_in_conditional_expressions
  bool hasMoreData() => state is LeaderBoardDailySuccess
      ? (state as LeaderBoardDailySuccess).hasMore
      : false;
}
