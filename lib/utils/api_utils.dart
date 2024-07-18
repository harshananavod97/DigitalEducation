import 'dart:developer';

import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/authRemoteDataSource.dart';

class ApiUtils {
  static Future<Map<String, String>> getHeaders() async {
    var jwtToken = AuthLocalDataSource.getJwtToken();

    if (jwtToken.isEmpty) {
      try {
        jwtToken = await AuthRemoteDataSource().getJWTTokenOfUser(
          firebaseId: AuthLocalDataSource.getUserFirebaseId(),
          type: AuthLocalDataSource.getAuthType(),
        );
        await AuthLocalDataSource.setJwtToken(jwtToken);
      } catch (e) {
        log(name: 'API: Get Headers', e.toString());
      }
    }

    log(name: 'API: JWT Token', jwtToken);

    return {'Authorization': 'Bearer $jwtToken'};
  }
}
