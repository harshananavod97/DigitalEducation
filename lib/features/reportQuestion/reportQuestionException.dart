class ReportQuestionException implements Exception {
  ReportQuestionException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
