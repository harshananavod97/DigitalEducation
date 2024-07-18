class NotificationException implements Exception {
  NotificationException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
