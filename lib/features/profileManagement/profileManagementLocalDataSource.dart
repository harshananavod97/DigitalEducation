import 'package:flutterquiz/utils/constants/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManagementLocalDataSource {
  Box<dynamic> get _box => Hive.box<dynamic>(userDetailsBox);

  String getName() => _box.get(nameBoxKey, defaultValue: '') as String;

  String getUserUID() => _box.get(userUIdBoxKey, defaultValue: '') as String;

  String getEmail() => _box.get(emailBoxKey, defaultValue: '') as String;

  String getMobileNumber() =>
      _box.get(mobileNumberBoxKey, defaultValue: '') as String;

  String getRank() => _box.get(rankBoxKey, defaultValue: '') as String;

  String getCoins() => _box.get(coinsBoxKey, defaultValue: '') as String;

  String getScore() => _box.get(scoreBoxKey, defaultValue: '') as String;

  String getProfileUrl() =>
      _box.get(profileUrlBoxKey, defaultValue: '') as String;

  String getFirebaseId() =>
      _box.get(firebaseIdBoxKey, defaultValue: '') as String;

  String getStatus() => _box.get(statusBoxKey, defaultValue: '1') as String;

  String getReferCode() =>
      _box.get(referCodeBoxKey, defaultValue: '') as String;

  String getFCMToken() => _box.get(fcmTokenBoxKey, defaultValue: '') as String;

  Future<void> setEmail(String email) async {
    await _box.put(emailBoxKey, email);
  }

  Future<void> setUserUId(String userId) async {
    await _box.put(userUIdBoxKey, userId);
  }

  Future<void> setName(String name) async {
    await _box.put(nameBoxKey, name);
  }

  Future<void> serProfileUrl(String profileUrl) async {
    await _box.put(profileUrlBoxKey, profileUrl);
  }

  Future<void> setRank(String rank) async {
    await _box.put(rankBoxKey, rank);
  }

  Future<void> setCoins(String coins) async {
    await _box.put(coinsBoxKey, coins);
  }

  Future<void> setMobileNumber(String mobileNumber) async {
    await _box.put(mobileNumberBoxKey, mobileNumber);
  }

  Future<void> setScore(String score) async {
    await _box.put(scoreBoxKey, score);
  }

  Future<void> setStatus(String status) async {
    await _box.put(statusBoxKey, status);
  }

  Future<void> setFirebaseId(String firebaseId) async {
    await _box.put(firebaseIdBoxKey, firebaseId);
  }

  Future<void> setReferCode(String referCode) async {
    await _box.put(referCodeBoxKey, referCode);
  }

  Future<void> setFCMToken(String fcmToken) async {
    await _box.put(fcmTokenBoxKey, fcmToken);
  }

  static Future<void> updateReversedCoins(int coins) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('reversedCoins', coins);
  }

  static Future<int> getUpdateReversedCoins() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      return sharedPreferences.getInt('reversedCoins') ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
