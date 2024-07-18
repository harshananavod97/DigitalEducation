import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;

class ProfileManagementRemoteDataSource {
  Future<Map<String, dynamic>> getUserDetailsById() async {
    try {
      final response = await http.post(
        Uri.parse(getUserDetailsByIdUrl),
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<Map<String, dynamic>> addProfileImage(
    File? images,
  ) async {
    try {
      final fileList = <String, File?>{
        imageKey: images,
      };
      final response = await postApiFile(
        Uri.parse(uploadProfileUrl),
        fileList,
      );
      final res = json.decode(response) as Map<String, dynamic>;
      if (res['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: res['message'].toString(),
        );
      }

      return res['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<String> postApiFile(
    Uri url,
    Map<String, File?> fileList,
  ) async {
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(await ApiUtils.getHeaders());

      for (final key in fileList.keys.toList()) {
        final pic = await http.MultipartFile.fromPath(key, fileList[key]!.path);
        request.files.add(pic);
      }
      final res = await request.send();
      final responseData = await res.stream.toBytes();
      final response = String.fromCharCodes(responseData);
      if (res.statusCode == 200) {
        return response;
      } else {
        throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage,
        );
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<Map<String, dynamic>> updateCoinsAndScore({
    required String score,
    required String coins,
    required String title,
    String? type,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        coinsKey: coins,
        scoreKey: score,
        typeKey: type ?? '',
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? '1' : '0',
      };

      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }
      final response = await http.post(
        Uri.parse(updateUserCoinsAndScoreUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<Map<String, dynamic>> updateCoins({
    required String coins,
    required String title,
    String? type, //dashing_debut, clash_winner
  }) async {
    try {
      final body = <String, String>{
        coinsKey: coins,
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? '1' : '0',
        typeKey: type ?? '',
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }

      final response = await http.post(
        Uri.parse(updateUserCoinsAndScoreUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<Map<String, dynamic>> updateScore({
    required String score,
    String? type,
  }) async {
    try {
      final body = <String, String>{
        scoreKey: score,
        typeKey: type ?? '',
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }
      final response = await http.post(
        Uri.parse(updateUserCoinsAndScoreUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<void> removeAdsForUser({required bool status}) async {
    try {
      final body = <String, String>{
        removeAdsKey: status ? '1' : '0',
      };

      final rawRes = await http.post(
        Uri.parse(updateProfileUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final resJson = jsonDecode(rawRes.body) as Map<String, dynamic>;
      if (resJson['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: resJson['message'].toString(),
        );
      }
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<void> updateProfile({
    required String email,
    required String name,
    required String mobile,
  }) async {
    try {
      final body = <String, String>{
        emailKey: email,
        nameKey: name,
        mobileKey: mobile,
      };

      final response = await http.post(
        Uri.parse(updateProfileUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseJson['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.delete();

      await http.post(
        Uri.parse(deleteUserAccountUrl),
        headers: await ApiUtils.getHeaders(),
      );
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on FirebaseAuthException catch (e) {
      throw ProfileManagementException(
        errorMessageCode: firebaseErrorCodeToNumber(e.code),
      );
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<bool> watchedDailyAd() async {
    try {
      final rawRes = await http.post(
        Uri.parse(watchedDailyAdUrl),
        headers: await ApiUtils.getHeaders(),
      );

      final jsonRes = jsonDecode(rawRes.body) as Map<String, dynamic>;

      if (jsonRes['error'] as bool) {
        throw ProfileManagementException(
          errorMessageCode: jsonRes['message'].toString(),
        );
      }

      return jsonRes['message'] == errorCodeDataUpdateSuccess;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on FirebaseAuthException catch (e) {
      throw ProfileManagementException(
        errorMessageCode: firebaseErrorCodeToNumber(e.code),
      );
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }
}
