enum RoomCodeCharType {
  onlyNumbers(type: '1', value: '1234567890'),
  onlyLetters(
    type: '2',
    value: 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz',
  ),
  bothNumbersAndLetters(
    type: '3',
    value: 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890',
  );

  const RoomCodeCharType({required this.type, required this.value});

  final String type;
  final String value;

  static RoomCodeCharType fromString(String v) =>
      RoomCodeCharType.values.firstWhere((e) => e.type == v);
}
