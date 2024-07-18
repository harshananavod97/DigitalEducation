import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/reportQuestion/reportQuestionException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class ReportQuestionRemoteDataSource {
  Future<void> reportQuestion({
    required String questionId,
    required String message,
  }) async {
    try {
      final body = <String, String>{
        questionIdKey: questionId,
        messageKey: message,
      };

      final response = await http.post(
        Uri.parse(reportQuestionUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ReportQuestionException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw ReportQuestionException(errorMessageCode: errorCodeNoInternet);
    } on ReportQuestionException catch (e) {
      throw ReportQuestionException(errorMessageCode: e.toString());
    } catch (e) {
      throw ReportQuestionException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
