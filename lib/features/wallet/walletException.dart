class WalletException implements Exception {
  WalletException({required this.errorMessageCode});
  final String errorMessageCode;
  @override
  String toString() => errorMessageCode;
}
