class LeaderBoardException implements Exception {
  LeaderBoardException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
