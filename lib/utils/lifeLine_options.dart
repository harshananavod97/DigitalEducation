import 'dart:math';

import 'package:flutterquiz/features/quiz/models/answerOption.dart';

class LifeLineOptions {
  static int getRandomAnswerIndex(int length, int correctAnswerIndex) {
    final index = Random.secure().nextInt(length);
    if (index == correctAnswerIndex) {
      return getRandomAnswerIndex(length, correctAnswerIndex);
    } else {
      return index;
    }
  }

  static List<AnswerOption> getFiftyFiftyOptions(
    List<AnswerOption> answerOptions,
    String correctAnswerOptionId,
  ) {
    final updatedAnswerOptions = List<AnswerOption>.from(answerOptions);
    final correctAnswerOptionIndex = updatedAnswerOptions
        .indexWhere((element) => element.id == correctAnswerOptionId);

    //fetching random index for array
    final randomIndex = getRandomAnswerIndex(
      updatedAnswerOptions.length,
      correctAnswerOptionIndex,
    );

    final otherOptionId = updatedAnswerOptions[randomIndex].id;

    //remove options
    updatedAnswerOptions.removeWhere(
      (element) =>
          element.id != otherOptionId && element.id != correctAnswerOptionId,
    );

    return updatedAnswerOptions;
  }

  static List<int> numbersForAudiencePoll(int optionsLength) {
    final numbers = <int>[];
    final highest = Random.secure().nextInt(20) + 45;
    numbers.add(highest);

    for (var i = 1; i < (optionsLength - 1); i++) {
      final number = Random.secure().nextInt(100 - _sum(numbers));
      numbers.add(number);
    }
    numbers.add(100 - _sum(numbers));

    return numbers;
  }

  static int _sum(List<int> numbers) {
    var total = 0;

    for (final e in numbers) {
      total = total + e;
    }

    return total;
  }

  static List<int> getAudiencePollPercentage(
    List<AnswerOption> answerOptions,
    String correctAnswerOptionId,
  ) {
    final percentages = numbersForAudiencePoll(answerOptions.length);

    //correct percentage
    final correctAnswerPercentage = percentages.removeAt(0);

    //shuffle percentages
    percentages.shuffle();

    //get correctAnswer index
    final correctAnswerOptionIndex = answerOptions
        .indexWhere((element) => element.id == correctAnswerOptionId);

    //add audience percentage for correct answer
    if (correctAnswerOptionIndex == percentages.length) {
      percentages.add(correctAnswerPercentage);
    } else {
      percentages.insert(correctAnswerOptionIndex, correctAnswerPercentage);
    }

    return percentages;
  }
}
