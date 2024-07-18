class BattleRoomException implements Exception {
  BattleRoomException({required this.errorMessageCode});
  final String? errorMessageCode;

  @override
  String toString() => errorMessageCode!;
}
