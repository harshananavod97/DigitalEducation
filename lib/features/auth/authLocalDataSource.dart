import 'package:flutterquiz/utils/constants/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

//AuthLocalDataSource will communicate with local database (hive)
class AuthLocalDataSource {
  static String getJwtToken() {
    return Hive.box<dynamic>(authBox).get(jwtTokenKey, defaultValue: '')
        as String;
  }

  static Future<void> setJwtToken(String jwtToken) async {
    await Hive.box<dynamic>(authBox).put(jwtTokenKey, jwtToken);
  }

  static bool checkIsAuth() {
    return Hive.box<dynamic>(authBox).get(isLoginKey, defaultValue: false)
        as bool;
  }

  static String getAuthType() {
    return Hive.box<dynamic>(authBox).get(authTypeKey, defaultValue: '')
        as String;
  }

  static String getUserFirebaseId() {
    return Hive.box<dynamic>(authBox).get(firebaseIdBoxKey, defaultValue: '')
        as String;
  }

  Future<void> setUserFirebaseId(String? userId) async {
    await Hive.box<dynamic>(authBox).put(firebaseIdBoxKey, userId);
  }

  Future<void> setAuthType(String? authType) async {
    await Hive.box<dynamic>(authBox).put(authTypeKey, authType);
  }

  Future<void> changeAuthStatus({bool? authStatus}) async {
    await Hive.box<dynamic>(authBox).put(isLoginKey, authStatus);
  }
}
