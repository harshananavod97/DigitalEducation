import 'package:flutterquiz/utils/constants/string_labels.dart';

enum QuizTypes {
  dailyQuiz,
  contest,
  groupPlay,
  practiceSection,
  oneVsOneBattle,
  funAndLearn,
  trueAndFalse,
  selfChallenge,
  guessTheWord,
  quizZone,
  bookmarkQuiz,
  mathMania,
  audioQuestions,
  exam,
  randomBattle,
}

QuizTypes getQuizTypeEnumFromTitle(String? title) {
  if (title == 'contest') {
    return QuizTypes.contest;
  } else if (title == 'dailyQuiz') {
    return QuizTypes.dailyQuiz;
  } else if (title == 'groupPlay') {
    return QuizTypes.groupPlay;
  } else if (title == 'battleQuiz') {
    return QuizTypes.oneVsOneBattle;
  } else if (title == 'funAndLearn') {
    return QuizTypes.funAndLearn;
  } else if (title == 'guessTheWord') {
    return QuizTypes.guessTheWord;
  } else if (title == 'trueAndFalse') {
    return QuizTypes.trueAndFalse;
  } else if (title == 'selfChallenge') {
    return QuizTypes.selfChallenge;
  } else if (title == 'quizZone') {
    return QuizTypes.quizZone;
  } else if (title == mathManiaKey) {
    return QuizTypes.mathMania;
  } else if (title == audioQuestionsKey) {
    return QuizTypes.audioQuestions;
  } else if (title == examKey) {
    return QuizTypes.exam;
  }

  return QuizTypes.practiceSection;
}
