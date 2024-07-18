import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutterquiz/features/auth/auhtException.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //to addUser
  Future<Map<String, dynamic>> addUser({
    required String firebaseId,
    required String type,
    required String name,
    String? profile,
    String? mobile,
    String? email,
    String? referCode,
    String? friendCode,
  }) async {
    try {
      final fcmToken = await getFCMToken();
      //body of post request
      final body = <String, String>{
        firebaseIdKey: firebaseId,
        typeKey: type,
        nameKey: name,
        emailKey: email ?? '',
        profileKey: profile ?? '',
        mobileKey: mobile ?? '',
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? '',
      };

      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw AuthException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: errorCodeNoInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //to addUser
  Future<String> getJWTTokenOfUser({
    required String firebaseId,
    required String type,
    String? name,
  }) async {
    try {
      //body of post request
      final body = <String, String>{
        firebaseIdKey: firebaseId,
        typeKey: type,
        nameKey: name ?? '',
      };

      if (name == null || name.isEmpty) body.remove(nameKey);

      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw AuthException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
      final data = responseJson['data'] as Map<String, dynamic>;

      return data['api_token'].toString();
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: errorCodeNoInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<bool> isUserExist(String firebaseId) async {
    try {
      final body = {
        firebaseIdKey: firebaseId,
      };
      final response =
          await http.post(Uri.parse(checkUserExistUrl), body: body);
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw AuthException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return responseJson['message'].toString() == errorCodeUserExists;
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: errorCodeNoInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> updateFcmId({
    required String firebaseId,
    required bool userLoggingOut,
  }) async {
    try {
      final fcmId = userLoggingOut
          ? 'empty'
          : await fcm.FirebaseMessaging.instance.getToken() ?? 'empty';
      final body = {
        fcmIdKey: fcmId,
        firebaseIdKey: firebaseId.isNotEmpty ? firebaseId : 'firebaseId',
      };
      final response = await http.post(
        Uri.parse(updateFcmIdUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw AuthException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

//signIn using phone number
  Future<UserCredential> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    final phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
    return userCredential;
  }

  //SignIn user will accept AuthProvider (enum)
  Future<UserCredential> signInUser(
    AuthProviders authProvider, {
    String? email,
    String? password,
    String? verificationId,
    String? smsCode,
  }) async {
    try {
      return switch (authProvider) {
        AuthProviders.gmail => await signInWithGoogle(),
        AuthProviders.mobile => await signInWithPhoneNumber(
            verificationId: verificationId!,
            smsCode: smsCode!,
          ),
        AuthProviders.email =>
          await signInWithEmailAndPassword(email!, password!),
        _ => await signInWithApple(),
      };
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: errorCodeNoInternet);
    } on FirebaseAuthException catch (e) {
      throw AuthException(errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  //signIn using google account
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);

      if (userCredential.additionalUserInfo!.isNewUser ||
          userCredential.user!.displayName == null) {
        final user = userCredential.user!;
        final givenName = credential.givenName ?? '';
        final familyName = credential.familyName ?? '';

        await user.updateDisplayName('$givenName $familyName');
        await user.reload();
      }

      return userCredential;
    } catch (error) {
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    //sign in using email
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user!.emailVerified) {
      return userCredential;
    } else {
      throw AuthException(errorMessageCode: '135');
    }
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  static Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      return '';
    }
  }

  //create user account
  Future<void> signUpUser(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //verify email address
      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: errorCodeNoInternet);
    } catch (e) {
      throw AuthException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> signOut(AuthProviders? authProvider) async {
    await _firebaseAuth.signOut();
    if (authProvider == AuthProviders.gmail) {
      await _googleSignIn.signOut();
    }
  }
}
