import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/statistic/statisticException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class StatisticRemoteDataSource {
  /*
  {
        "id": "2",
        userIdKey: "11",
        "questions_answered": "1",
        correctAnswersKey: "1",
        "strong_category": "News",
        "ratio1": "100",
        "weak_category": "0",
        "ratio2": "0",
        "best_position": "0",
        "date_created": "2021-06-25 15:48:20",
        "name": "RAHUL HIRANI",
        profileKey: "https://lh3.googleusercontent.com/a/AATXAJyzUAfJwUFTV3yE6tM9KdevDnX2rcM8vm3GKHFz=s96-c"
    }
  
   */

  Future<Map<String, dynamic>> getStatistic() async {
    try {
      //body of post request
      final response = await http.post(
        Uri.parse(getStatisticUrl),
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw StatisticException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: errorCodeNoInternet);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } catch (e) {
      throw StatisticException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  /*
  user_id:10
	questions_answered:100
	correct_answers:10
	category_id:1 //(id of category which user played)
	ratio:50 // (In percenatge)
   */

  Future<dynamic> updateStatistic({
    String? answeredQuestion,
    String? correctAnswers,
    String? winPercentage,
    String? categoryId,
  }) async {
    try {
      //body of post request
      final body = {
        'questions_answered': answeredQuestion,
        correctAnswersKey: correctAnswers,
        'category_id': categoryId,
        'ratio': winPercentage,
      };

      final response = await http.post(
        Uri.parse(updateStatisticUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw StatisticException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: errorCodeNoInternet);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } catch (e) {
      throw StatisticException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> updateBattleStatistic({
    required String userId1,
    required String userId2,
    required String isDrawn,
    required String winnerId,
  }) async {
    try {
      //access_key:8525
      // user_id1:709
      // user_id2:710
      // winner_id:710
      // is_drawn:0 / 1 (0->no_drawn,1->drawn)
      //body of post request
      final body = {
        userId1Key: userId1,
        userId2Key: userId2,
        winnerIdKey: winnerId,
        isDrawnKey: isDrawn,
      };
      final response = await http.post(
        Uri.parse(setBattleStatisticsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw StatisticException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: errorCodeNoInternet);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } catch (e) {
      throw StatisticException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<Map<String, dynamic>> getBattleStatistic() async {
    try {
      final response = await http.post(
        Uri.parse(getBattleStatisticsUrl),
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      return responseJson;
    } on SocketException catch (_) {
      throw StatisticException(errorMessageCode: errorCodeNoInternet);
    } on StatisticException catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    } catch (e) {
      throw StatisticException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
