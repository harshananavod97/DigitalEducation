import 'package:flutterquiz/features/auth/cubits/authCubit.dart';

class AuthModel {
  AuthModel({
    required this.jwtToken,
    required this.firebaseId,
    required this.authProvider,
    required this.isNewUser,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      jwtToken: json['jwtToken'] as String,
      firebaseId: json['firebaseId'] as String,
      authProvider: AuthProviders.values.firstWhere(
        (e) => e.toString() == json['authProvider'].toString(),
      ),
      isNewUser: false,
    );
  }

  final AuthProviders authProvider;
  final String firebaseId;
  final String jwtToken;
  final bool isNewUser;

  AuthModel copyWith({
    String? jwtToken,
    String? firebaseId,
    AuthProviders? authProvider,
    bool? isNewUser,
  }) {
    return AuthModel(
      jwtToken: jwtToken ?? this.jwtToken,
      firebaseId: firebaseId ?? this.firebaseId,
      authProvider: authProvider ?? this.authProvider,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
