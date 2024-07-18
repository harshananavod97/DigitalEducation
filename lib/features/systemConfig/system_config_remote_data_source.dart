import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/systemConfig/system_config_exception.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class SystemConfigRemoteDataSource {
  Future<Map<String, dynamic>> getSystemConfig() async {
    try {
      final response = await http.post(Uri.parse(getSystemConfigUrl));
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getSupportedQuestionLanguages() async {
    try {
      final response = await http.post(
        Uri.parse(getSupportedQuestionLanguageUrl),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return (responseJson['data'] as List).cast<Map<String, dynamic>>();
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {typeKey: type};
      final response = await http.post(
        Uri.parse(getAppSettingsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw SystemConfigException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'].toString();
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: errorCodeNoInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
