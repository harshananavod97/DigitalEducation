class PayoutMethod {
  PayoutMethod({
    required this.inputs,
    required this.image,
    required this.type,
  });

  final String type;
  final String image;
  final List<({String name, bool isNumber, int maxLength})> inputs;
}
