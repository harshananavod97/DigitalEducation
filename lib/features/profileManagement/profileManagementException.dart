class ProfileManagementException implements Exception {
  ProfileManagementException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
