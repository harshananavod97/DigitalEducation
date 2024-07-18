class CoinHistoryException implements Exception {
  CoinHistoryException({required this.errorMessageCode});
  final String errorMessageCode;
  @override
  String toString() => errorMessageCode;
}
