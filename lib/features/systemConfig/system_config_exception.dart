class SystemConfigException implements Exception {
  SystemConfigException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
