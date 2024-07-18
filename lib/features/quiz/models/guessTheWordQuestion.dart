import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/quiz/models/correctAnswer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';

class GuessTheWordQuestion {
  GuessTheWordQuestion({
    required this.id,
    required this.languageId,
    required this.image,
    required this.question,
    required this.answer,
    required this.submittedAnswer,
    required this.options,
    required this.hasAnswered,
    required this.subcategory,
    required this.category,
  });

  GuessTheWordQuestion.fromJson(Map<String, dynamic> json) {
    final submittedAns = <String>[];
    final initialOptions = <String>[];

    var correctAnswer = AnswerEncryption.decryptCorrectAnswer(
      rawKey: AuthLocalDataSource.getUserFirebaseId(),
      correctAnswer:
          CorrectAnswer.fromJson(json['answer'] as Map<String, dynamic>),
    );

    correctAnswer = correctAnswer.toUpperCase();
    for (var i = 0; i < correctAnswer.length; i++) {
      submittedAns.add('');
      initialOptions.add(correctAnswer.substring(i, i + 1));
    }
    initialOptions
      ..shuffle()
      ..add('!');

    id = json['id'] as String;
    languageId = json['language_id'] as String;
    image = json['image'] as String;
    question = json['question'] as String;
    subcategory = json['subcategory'] as String;
    category = json['category'] as String;
    answer = correctAnswer;
    submittedAnswer = submittedAns;
    options = initialOptions;
    hasAnswered = false;
  }

  GuessTheWordQuestion.fromBookmarkJson(Map<String, dynamic> json) {
    final submittedAns = <String>[];
    final initialOptions = <String>[];
    var correctAnswer = json['answer'].toString().split(' ').join();
    correctAnswer = correctAnswer.toUpperCase();
    for (var i = 0; i < correctAnswer.length; i++) {
      submittedAns.add('');
      initialOptions.add(correctAnswer.substring(i, i + 1));
    }
    initialOptions
      ..shuffle()
      ..add('!');

    id = json['question_id'] as String;
    languageId = json['language_id'] as String;
    image = json['image'] as String;
    question = json['question'] as String;
    subcategory = json['subcategory'] as String;
    category = json['category'] as String;
    answer = correctAnswer;
    submittedAnswer = submittedAns;
    options = initialOptions;
    hasAnswered = false;
  }

  late String id;
  late String languageId;
  late String image;
  late String question;
  late String answer;
  late String subcategory;

  late String category;

  //it store option letter index
  late List<String> submittedAnswer;
  late List<String> options; //to build options
  late bool hasAnswered;

  GuessTheWordQuestion copyWith({
    List<String>? updatedAnswer,
    bool? hasAnswerGiven,
  }) {
    return GuessTheWordQuestion(
      category: category,
      subcategory: subcategory,
      answer: answer,
      id: id,
      image: image,
      languageId: languageId,
      question: question,
      submittedAnswer: updatedAnswer ?? submittedAnswer,
      options: options,
      hasAnswered: hasAnswerGiven ?? hasAnswered,
    );
  }
}
