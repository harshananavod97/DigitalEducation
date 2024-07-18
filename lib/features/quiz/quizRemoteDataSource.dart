import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutterquiz/features/quiz/quizException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class QuizRemoteDataSource {
  static late String profile;
  static late String score;
  static late String rank;

  Future<List<Map<String, dynamic>>> getQuestionsForDailyQuiz({
    String? languageId,
  }) async {
    try {
      final body = <String, String>{languageIdKey: languageId!};

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionForDailyQuizUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionByType(
    String languageId,
  ) async {
    try {
      final body = <String, String>{typeKey: '2', languageIdKey: languageId};
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionByTypeUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionContest(
    String contestId,
  ) async {
    try {
      final body = <String, String>{
        contestIdKey: contestId,
      };

      final response = await http.post(
        Uri.parse(getQuestionContestUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getGuessTheWordQuestions({
    required String languageId,
    required String type, //category or subcategory
    required String typeId,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        typeKey: type,
        typeIdKey: typeId,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      final response = await http.post(
        Uri.parse(getGuessTheWordQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  /*
  get_questions_by_level
        access_key:8525
	level:2
	category:5 {or}
	subcategory:9
	language_id:2
   */

  Future<List<Map<String, dynamic>>> getQuestionsForQuizZone({
    required String languageId,
    required String categoryId,
    required String subcategoryId,
    required String level,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
        levelKey: level,
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }
      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }
      if (subcategoryId.isNotEmpty) {
        body.remove(categoryKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionsByLevelUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionByCategoryOrSubcategory({
    required String type,
    required String id,
  }) async {
    try {
      final body = <String, String>{
        typeKey: type,
        idKey: id,
      };

      final response = await http.post(
        Uri.parse(getQuestionsByCategoryOrSubcategory),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getAudioQuestions({
    required String type,
    required String id,
  }) async {
    try {
      final body = <String, String>{
        typeKey: type,
        typeIdKey: id,
      };

      final response = await http.post(
        Uri.parse(getAudioQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getLatexQuestions({
    required String type,
    required String id,
  }) async {
    try {
      final body = <String, String>{
        typeKey: type,
        typeIdKey: id,
      };

      final response = await http.post(
        Uri.parse(getLatexQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryWithUser({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        languageIdKey: languageId,
        typeKey: type,
        subTypeKey: subType ?? '',
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subType != null && subType.isEmpty) {
        body.remove(subTypeKey);
      }

      final response = await http.post(
        Uri.parse(getCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getCategory({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        languageIdKey: languageId,
        typeKey: type,
        subTypeKey: subType ?? '',
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subType != null && subType.isEmpty) {
        body.remove(subTypeKey);
      }

      final response = await http.post(
        Uri.parse(getCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSelfChallenge({
    required String languageId,
    required String categoryId,
    required String subcategoryId,
    required String numberOfQuestions,
  }) async {
    try {
      final body = <String, String>{
        languageIdKey: languageId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
        limitKey: numberOfQuestions,
      };

      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }

      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }

      if (categoryId.isEmpty) {
        body.remove(categoryKey);
      }

      final response = await http.post(
        Uri.parse(getQuestionForSelfChallengeUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getSubCategory(String category) async {
    try {
      //body of post request
      final body = <String, String>{categoryKey: category};

      final response = await http.post(
        Uri.parse(getSubCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<int> getUnlockedLevel(String category, String subCategory) async {
    try {
      //body of post request
      final body = <String, String>{
        categoryKey: category,
        subCategoryKey: subCategory,
      };

      if (subCategory.isEmpty) body.remove(subCategoryKey);

      final response = await http.post(
        Uri.parse(getLevelUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      final data = responseJson['data'] as Map<String, dynamic>;

      return int.parse(data['level'] as String? ?? '0');
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> updateLevel({
    required String category,
    required String subCategory,
    required String level,
  }) async {
    try {
      final body = <String, String>{
        categoryKey: category,
        subCategoryKey: subCategory,
        levelKey: level,
      };

      final response = await http.post(
        Uri.parse(updateLevelUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<Map<String, dynamic>> getContest({required String languageId}) async {
    try {
      //body of post request
      final body = {
        'get_contest': '1',
        languageIdKey: languageId,
      };

      final response = await http.post(
        Uri.parse(getContestUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body);

      return responseJson as Map<String, dynamic>;
      // return responseJson;
    } on SocketException catch (_) {
      throw QuizException(
        errorMessageCode: notPlayedContestKey,
      );
    } catch (e) {
      throw QuizException(
        errorMessageCode: notPlayedContestKey,
      );
    }
  }

  Future<void> setContestLeaderboard({
    String? contestId,
    int? questionAttended,
    int? correctAns,
    int? score,
  }) async {
    try {
      final body = <String, dynamic>{
        contestIdKey: contestId,
        questionAttendedKey: questionAttended.toString(),
        correctAnswersKey: correctAns.toString(),
        scoreKey: score.toString(),
      };
      final response = await http.post(
        Uri.parse(setContestLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getContestLeaderboard(
    String? contestId,
  ) async {
    try {
      final body = {contestIdKey: contestId};
      final response = await http.post(
        Uri.parse(getContestLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      final myRank = responseJson['my_rank'] as Map<String, dynamic>;

      rank = myRank['user_rank'].toString();
      profile = myRank[profileKey].toString();
      score = myRank['score'].toString();
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getComprehension({
    required String languageId,
    required String type,
    required String typeId,
  }) async {
    try {
      final body = {
        typeKey: type,
        typeIdKey: typeId,
        languageIdKey: languageId,
      };
      if (languageId.isEmpty) {
        body.remove(languageIdKey);
      }
      final response = await http.post(
        Uri.parse(getFunAndLearnUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getComprehensionQuestion(
    String? funAndLearnId,
  ) async {
    try {
      //body of post request
      final body = {funAndLearnKey: funAndLearnId};
      final response = await http.post(
        Uri.parse(getFunAndLearnQuestionsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> setQuizCategoryPlayed({
    required String type,
    required String categoryId,
    required String subcategoryId,
    required String typeId,
  }) async {
    try {
      final body = <String, dynamic>{
        typeKey: type,
        typeIdKey: typeId,
        categoryKey: categoryId,
        subCategoryKey: subcategoryId,
      };
      if (subcategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }
      if (typeId.isEmpty) {
        body.remove(typeIdKey);
      }

      final response = await http.post(
        Uri.parse(setQuizCategoryPlayedUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw QuizException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> unlockPremiumCategory({
    required String categoryId,
    String? subCategoryId,
  }) async {
    try {
      final body = {
        categoryKey: categoryId,
        subCategoryKey: subCategoryId,
      };

      if (subCategoryId == null || subCategoryId.isEmpty) {
        body.remove(subCategoryKey);
      }

      log('Body $body', name: 'unlockPremiumCategory API');
      final rawRes = await http.post(
        Uri.parse(unlockPremiumCategoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final jsonRes = jsonDecode(rawRes.body) as Map<String, dynamic>;

      if (jsonRes['error'] as bool) {
        throw QuizException(
          errorMessageCode: jsonRes['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw QuizException(errorMessageCode: errorCodeNoInternet);
    } on QuizException catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    } catch (e) {
      throw QuizException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
