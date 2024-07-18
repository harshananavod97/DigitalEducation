class BookmarkException implements Exception {
  BookmarkException({required this.errorMessageCode});
  final String errorMessageCode;

  @override
  String toString() => errorMessageCode;
}
