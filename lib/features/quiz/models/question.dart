import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/correctAnswer.dart';

class Question {
  Question({
    this.questionType,
    this.answerOptions,
    this.correctAnswer,
    this.id,
    this.languageId,
    this.level,
    this.note,
    this.question,
    this.categoryId,
    this.imageUrl,
    this.subcategoryId,
    this.audio,
    this.audioType,
    this.attempted = false,
    this.submittedAnswerId = '',
    this.marks,
  });

  factory Question.fromJson(Map<String, dynamic> questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    final optionIds = <String>['a', 'b', 'c', 'd', 'e'];
    final options = <AnswerOption>[];

    //creating answerOption model
    final queType = questionJson['question_type'] ?? '';

    if (queType == '2') {
      final ops1 = questionJson['optiona'].toString();
      final ops2 = questionJson['optionb'].toString();
      if (ops1.isNotEmpty) {
        options.add(AnswerOption(id: 'a', title: ops1));
      }
      if (ops2.isNotEmpty) {
        options.add(AnswerOption(id: 'b', title: ops2));
      }
    } else {
      for (final optionId in optionIds) {
        final optionTitle = questionJson['option$optionId'] as String? ?? '';
        if (optionTitle.isNotEmpty) {
          options.add(AnswerOption(id: optionId, title: optionTitle));
        }
      }
    }

    options.shuffle();

    return Question(
      id: questionJson['id'] as String?,
      categoryId: questionJson['category'] as String? ?? '',
      imageUrl: questionJson['image'] as String?,
      languageId: questionJson['language_id'] as String?,
      subcategoryId: questionJson['subcategory'] as String? ?? '',
      correctAnswer: CorrectAnswer.fromJson(
        questionJson['answer'] as Map<String, dynamic>,
      ),
      level: questionJson['level'] as String? ?? '',
      question: questionJson['question'] as String?,
      note: questionJson['note'] as String? ?? '',
      questionType: questionJson['question_type'] as String? ?? '',
      audio: questionJson['audio'] as String? ?? '',
      audioType: questionJson['audio_type'] as String? ?? '',
      marks: questionJson['marks'] as String? ?? '',
      answerOptions: options,
    );
  }

  factory Question.fromBookmarkJson(Map<String, dynamic> questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    final optionIds = <String>['a', 'b', 'c', 'd', 'e'];
    final options = <AnswerOption>[];

    //creating answerOption model
    for (final optionId in optionIds) {
      final optionTitle = questionJson['option$optionId'].toString();
      if (optionTitle.isNotEmpty) {
        options.add(AnswerOption(id: optionId, title: optionTitle));
      }
    }
    options.shuffle();

    return Question(
      id: questionJson['question_id'] as String?,
      categoryId: questionJson['category'] as String? ?? '',
      imageUrl: questionJson['image'] as String?,
      languageId: questionJson['language_id'] as String?,
      subcategoryId: questionJson['subcategory'] as String? ?? '',
      correctAnswer: CorrectAnswer.fromJson(
        questionJson['answer'] as Map<String, dynamic>,
      ),
      level: questionJson['level'] as String? ?? '',
      question: questionJson['question'] as String?,
      note: questionJson['note'] as String? ?? '',
      questionType: questionJson['question_type'] as String? ?? '',
      audio: questionJson['audio'] as String? ?? '',
      audioType: questionJson['audio_type'] as String? ?? '',
      marks: questionJson['marks'] as String? ?? '',
      answerOptions: options,
    );
  }

  final String? question;
  final String? id;
  final String? categoryId;
  final String? subcategoryId;
  final String? imageUrl;
  final String? level;
  final CorrectAnswer? correctAnswer;
  final String? note;
  final String? languageId;
  final String submittedAnswerId;
  final String? questionType;
  final List<AnswerOption>? answerOptions;
  final bool attempted;
  final String? audio;
  final String? audioType;
  final String? marks;

  Question updateQuestionWithAnswer({required String submittedAnswerId}) {
    return Question(
      marks: marks,
      submittedAnswerId: submittedAnswerId,
      audio: audio,
      audioType: audioType,
      answerOptions: answerOptions,
      attempted: submittedAnswerId.isNotEmpty,
      categoryId: categoryId,
      correctAnswer: correctAnswer,
      id: id,
      imageUrl: imageUrl,
      languageId: languageId,
      level: level,
      note: note,
      question: question,
      questionType: questionType,
      subcategoryId: subcategoryId,
    );
  }

  Question copyWith({String? submittedAnswer, bool? attempted}) {
    return Question(
      marks: marks,
      submittedAnswerId: submittedAnswer ?? submittedAnswerId,
      answerOptions: answerOptions,
      audio: audio,
      audioType: audioType,
      attempted: attempted ?? this.attempted,
      categoryId: categoryId,
      correctAnswer: correctAnswer,
      id: id,
      imageUrl: imageUrl,
      languageId: languageId,
      level: level,
      note: note,
      question: question,
      questionType: questionType,
      subcategoryId: subcategoryId,
    );
  }
}
