class Exam {
  const Exam({
    required this.id,
    required this.languageId,
    required this.title,
    required this.date,
    required this.examKey,
    required this.duration,
    required this.status,
    required this.noOfQue,
    required this.answerAgain,
    required this.examStatus, //(status: 1-Not in Exam, 2-In exam, 3-Completed)
    required this.totalMarks,
  });

  Exam.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        languageId = json['language_id'].toString(),
        title = json['title'].toString(),
        date = json['date'].toString(),
        examKey = json['exam_key'].toString(),
        duration = json['duration'].toString(),
        status = json['status'].toString(),
        noOfQue = json['no_of_que'].toString(),
        examStatus = json['exam_status'].toString(),
        totalMarks = json['total_marks'].toString(),
        answerAgain = json['answer_again'].toString();

  final String id;
  final String languageId;
  final String title;
  final String date;
  final String examKey;
  final String duration;
  final String status;
  final String noOfQue;
  final String examStatus;
  final String totalMarks;
  final String answerAgain;

  Map<String, dynamic> toJson() => {
        'id': id,
        'language_id': languageId,
        'title': title,
        'date': date,
        'exam_key': examKey,
        'duration': duration,
        'status': status,
        'no_of_que': noOfQue,
        'exam_status': examStatus,
        'total_marks': totalMarks,
        'answer_again': answerAgain,
      };
}
