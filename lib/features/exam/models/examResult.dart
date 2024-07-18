class ExamResult {
  ExamResult({
    required this.id,
    required this.languageId,
    required this.title,
    required this.date,
    required this.examKey,
    required this.duration,
    required this.status,
    required this.totalDuration,
    required this.statistics,
  });

  ExamResult.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    languageId = json['language_id'] as String;
    title = json['title'] as String;
    date = json['date'] as String;
    examKey = json['exam_key'] as String;
    duration = json['duration'] as String;
    status = json['status'] as String;
    totalDuration = json['total_duration'] as String? ?? '0';
    totalMarks = json['total_marks'] as String? ?? '0';
    statistics = (json['statistics'] as List)
        .cast<Map<String, dynamic>>()
        .map(Statistics.fromJson)
        .toList();
  }

  late final String id;
  late final String languageId;
  late final String title;
  late final String date;
  late final String examKey;
  late final String duration;
  late final String status;
  late final String totalDuration;
  late final List<Statistics> statistics;

  late final String totalMarks;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['language_id'] = languageId;
    data['title'] = title;
    data['date'] = date;
    data['exam_key'] = examKey;
    data['duration'] = duration;
    data['status'] = status;
    data['total_duration'] = totalDuration;
    data['statistics'] = statistics.map((e) => e.toJson()).toList();

    data['total_marks'] = totalMarks;
    return data;
  }

  int obtainedMarks() {
    var totalObtainedMarks = 0;
    for (final markStatistics in statistics) {
      totalObtainedMarks = totalObtainedMarks +
          int.parse(markStatistics.mark) *
              int.parse(markStatistics.correctAnswer);
    }

    return totalObtainedMarks;
  }

  int totalQuestions() {
    var totalQuestion = 0;
    for (final markStatistics in statistics) {
      totalQuestion = totalQuestion +
          int.parse(markStatistics.correctAnswer) +
          int.parse(markStatistics.incorrect);
    }
    return totalQuestion;
  }

  int totalCorrectAnswers() {
    var correctAnswers = 0;
    for (final markStatistics in statistics) {
      correctAnswers = correctAnswers + int.parse(markStatistics.correctAnswer);
    }
    return correctAnswers;
  }

  int totalInCorrectAnswers() {
    var inCorrectAnswers = 0;
    for (final markStatistics in statistics) {
      inCorrectAnswers = inCorrectAnswers + int.parse(markStatistics.incorrect);
    }
    return inCorrectAnswers;
  }

  int totalQuestionsByMark(String questionMark) {
    final statistics = _getStatisticsByMark(questionMark);
    return int.parse(statistics.correctAnswer) +
        int.parse(statistics.incorrect);
  }

  int totalInCorrectAnswersByMark(String questionMark) {
    final statistics = _getStatisticsByMark(questionMark);
    return int.parse(statistics.incorrect);
  }

  int totalCorrectAnswersByMark(String questionMark) {
    final statistics = _getStatisticsByMark(questionMark);
    return int.parse(statistics.correctAnswer);
  }

  Statistics _getStatisticsByMark(String questionMark) {
    return statistics
        .where((element) => element.mark == questionMark)
        .toList()
        .first;
  }

  List<String> getUniqueMarksOfQuestion() {
    return statistics.map((e) => e.mark).toList();
  }
}

class Statistics {
  const Statistics({
    required this.mark,
    required this.correctAnswer,
    required this.incorrect,
  });

  Statistics.fromJson(Map<String, dynamic> json)
      : mark = json['mark'] as String,
        correctAnswer = json['correct_answer'] as String,
        incorrect = json['incorrect'] as String;

  final String mark;
  final String correctAnswer;
  final String incorrect;

  Map<String, dynamic> toJson() => {
        'mark': mark,
        'correct_answer': correctAnswer,
        'incorrect': incorrect,
      };
}
