class ExamException implements Exception {
  ExamException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
