import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterquiz/features/auth/auhtException.dart';
import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/authRemoteDataSource.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';

class AuthRepository {
  factory AuthRepository() {
    _authRepository._authLocalDataSource = AuthLocalDataSource();
    _authRepository._authRemoteDataSource = AuthRemoteDataSource();
    return _authRepository;
  }

  AuthRepository._internal();

  static final AuthRepository _authRepository = AuthRepository._internal();
  late AuthLocalDataSource _authLocalDataSource;
  late AuthRemoteDataSource _authRemoteDataSource;

  //to get auth detials stored in hive box
  Map<String, dynamic> getLocalAuthDetails() {
    return {
      'isLogin': AuthLocalDataSource.checkIsAuth(),
      'jwtToken': AuthLocalDataSource.getJwtToken(),
      'firebaseId': AuthLocalDataSource.getUserFirebaseId(),
      'authProvider':
          getAuthProviderFromString(AuthLocalDataSource.getAuthType()),
    };
  }

  void setLocalAuthDetails({
    String? jwtToken,
    String? firebaseId,
    String? authType,
    bool? authStatus,
    bool? isNewUser,
  }) {
    _authLocalDataSource
      ..changeAuthStatus(authStatus: authStatus)
      ..setUserFirebaseId(firebaseId)
      ..setAuthType(authType);
  }

  //First we signing user with given provider then add user details
  Future<({bool isNewUser, User user})> signInUser(
    AuthProviders authProvider, {
    required String email,
    required String password,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final userCredentials = await _authRemoteDataSource.signInUser(
        authProvider,
        email: email,
        password: password,
        smsCode: smsCode,
        verificationId: verificationId,
      );

      final user = userCredentials.user;
      final additionalUserInfo = userCredentials.additionalUserInfo!;
      var isNewUser = additionalUserInfo.isNewUser;

      final firebaseUser = FirebaseAuth.instance.currentUser!;

      final userEmail = user?.email ??
          additionalUserInfo.profile?['email'] as String? ??
          firebaseUser.email ??
          '';
      final userPhotoUrl = user?.photoURL ??
          additionalUserInfo.profile?['picture'] as String? ??
          firebaseUser.photoURL ??
          '';
      final userPhoneNumber =
          user?.phoneNumber ?? firebaseUser.phoneNumber ?? '';
      final userName = user?.displayName ??
          additionalUserInfo.profile?['name'] as String? ??
          firebaseUser.displayName ??
          '';
      final userUid = user!.uid;

      /// checks in panel
      var userExists = !isNewUser;

      if (authProvider == AuthProviders.email) {
        userExists = await _authRemoteDataSource.isUserExist(userUid);
      }

      if (!userExists) {
        isNewUser = true;
        final registeredUser = await _authRemoteDataSource.addUser(
          email: userEmail,
          firebaseId: userUid,
          mobile: userPhoneNumber,
          name: userName,
          type: authProvider.name,
          profile: userPhotoUrl,
        );

        await AuthLocalDataSource.setJwtToken(
          registeredUser['api_token'].toString(),
        );
      } else {
        final jwtToken = await _authRemoteDataSource.getJWTTokenOfUser(
          firebaseId: userUid,
          type: authProvider.name,
          name: userName,
        );

        await AuthLocalDataSource.setJwtToken(jwtToken);
        await _authRemoteDataSource.updateFcmId(
          firebaseId: userUid,
          userLoggingOut: false,
        );
      }

      return (user: user, isNewUser: isNewUser);
    } catch (e) {
      await signOut(authProvider);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to signUp user
  Future<void> signUpUser(String email, String password) async {
    try {
      await _authRemoteDataSource.signUpUser(email, password);
    } catch (e) {
      if (e.toString() != errorCodeEmailExists) {
        await signOut(AuthProviders.email);
      }
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  Future<void> signOut(AuthProviders? authProvider) async {
    //remove fcm token when user logout
    try {
      await _authRemoteDataSource.updateFcmId(
        firebaseId: AuthLocalDataSource.getUserFirebaseId(),
        userLoggingOut: true,
      );
      await _authRemoteDataSource.signOut(authProvider);
      setLocalAuthDetails(
        authStatus: false,
        authType: '',
        jwtToken: '',
        firebaseId: '',
        isNewUser: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<Map<String, dynamic>> addUserData({
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
      final result = await _authRemoteDataSource.addUser(
        email: email,
        firebaseId: firebaseId,
        friendCode: friendCode,
        mobile: mobile,
        name: name,
        profile: profile,
        referCode: referCode,
        type: type,
      );

      //Update jwt token
      await AuthLocalDataSource.setJwtToken(result['api_token'].toString());

      return Map.from(result); //
    } catch (e) {
      await signOut(AuthProviders.mobile);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  AuthProviders getAuthProviderFromString(String? value) {
    AuthProviders authProvider;
    if (value == 'fb') {
      authProvider = AuthProviders.fb;
    } else if (value == 'gmail') {
      authProvider = AuthProviders.gmail;
    } else if (value == 'mobile') {
      authProvider = AuthProviders.mobile;
    } else if (value == 'apple') {
      authProvider = AuthProviders.apple;
    } else {
      authProvider = AuthProviders.email;
    }
    return authProvider;
  }
}
