import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutterquiz/features/bookmark/bookmarkException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class BookmarkRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBookmark(
    String type,
  ) async {
    try {
      //type is 1 - Quiz zone 3- Guess the word 4 - Audio question
      //body of post request
      final body = <String, String>{typeKey: type};

      final response = await http.post(
        Uri.parse(getBookmarkUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      log(name: 'Bookmarks', responseJson.toString());

      if (responseJson['error'] as bool) {
        throw BookmarkException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: errorCodeNoInternet);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> updateBookmark(
    String questionId,
    String status,
    String type,
  ) async {
    try {
      //body of post request
      final body = {
        statusKey: status,
        questionIdKey: questionId,
        typeKey: type, //1 - Quiz zone 3 - Guess the word 4 - Audio quesitons
      };
      final response = await http.post(
        Uri.parse(updateBookmarkUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      log(name: 'Update Bookmark', responseJson.toString());

      if (responseJson['error'] as bool) {
        throw BookmarkException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: errorCodeNoInternet);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
