class AuthException implements Exception {
  AuthException({required this.errorMessageCode});
  final String errorMessageCode;
  @override
  String toString() => errorMessageCode;
}
