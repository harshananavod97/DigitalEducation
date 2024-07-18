class CorrectAnswer {
  const CorrectAnswer({
    required this.cipherText,
    required this.iv,
  });

  CorrectAnswer.fromJson(Map<String, dynamic> json)
      : cipherText = json['ciphertext'].toString(),
        iv = json['iv'].toString();

  final String cipherText;
  final String iv;
}
