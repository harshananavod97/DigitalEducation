class StatisticModel {
  const StatisticModel({
    required this.battleDrawn,
    required this.battleLoose,
    required this.battleVictories,
    required this.playedBattles,
    required this.answeredQuestions,
    required this.bestPosition,
    required this.correctAnswers,
    required this.id,
    required this.ratio1,
    required this.ratio2,
    required this.strongCategory,
    required this.weakCategory,
  });

  StatisticModel.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> battleJson,
  )   : battleDrawn = battleJson['Drawn'] as String? ?? '0',
        battleLoose = battleJson['Loose'] as String? ?? '0',
        playedBattles =
            battleJson['playedBattles'] as List<dynamic>? ?? <dynamic>[],
        battleVictories = battleJson['Victories'] as String? ?? '0',
        answeredQuestions = json['questions_answered'] as String? ?? '',
        bestPosition = json['best_position'] as String? ?? '',
        correctAnswers = json['correct_answers'] as String? ?? '',
        id = json['id'] as String? ?? '',
        ratio1 = json['ratio1'] as String? ?? '',
        strongCategory = json['strong_category'] as String? ?? '',
        weakCategory = json['weak_category'] as String? ?? '',
        ratio2 = json['ratio2'] as String? ?? '';

  final String id;
  final String answeredQuestions;
  final String correctAnswers;
  final String strongCategory;
  final String ratio1;
  final String ratio2;
  final String weakCategory;
  final String bestPosition;
  final String battleVictories;
  final String battleDrawn;
  final String battleLoose;
  final List<dynamic> playedBattles;

  int calculatePlayedBattles() {
    return int.parse(battleDrawn) +
        int.parse(battleLoose) +
        int.parse(battleVictories);
  }
}
