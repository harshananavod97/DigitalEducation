enum AnswerMode {
  showAnswerCorrectness(value: '1'),
  noAnswerCorrectness(value: '2'),
  showAnswerCorrectnessAndCorrectAnswer(value: '3');

  const AnswerMode({required this.value});

  final String value;

  static AnswerMode fromString(String v) =>
      AnswerMode.values.firstWhere((e) => e.value == v);
}
