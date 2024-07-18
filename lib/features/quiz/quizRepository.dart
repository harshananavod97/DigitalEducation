import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/contestLeaderboard.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/leaderBoardMonthly.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quizException.dart';
import 'package:flutterquiz/features/quiz/quizRemoteDataSource.dart';

class QuizRepository {
  //QuizLocalDataSource _quizLocalDataSource;

  factory QuizRepository() {
    _quizRepository._quizRemoteDataSource = QuizRemoteDataSource();
    //_quizRepository._quizLocalDataSource = QuizLocalDataSource();
    return _quizRepository;
  }

  QuizRepository._internal();

  static final QuizRepository _quizRepository = QuizRepository._internal();
  late QuizRemoteDataSource _quizRemoteDataSource;
  static List<LeaderBoardMonthly> leaderBoardMonthlyList = [];

  Future<List<Category>> getCategory({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getCategoryWithUser(
        languageId: languageId,
        type: type,
        subType: subType,
      );

      return result.map(Category.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Category>> getCategoryWithoutUser({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getCategory(
        languageId: languageId,
        type: type,
        subType: subType,
      );

      return result.map(Category.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Subcategory>> getSubCategory(String category) async {
    try {
      final result = await _quizRemoteDataSource.getSubCategory(category);

      return result.map(Subcategory.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<int> getUnlockedLevel(String category, String subCategory) async {
    try {
      return await _quizRemoteDataSource.getUnlockedLevel(
        category,
        subCategory,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateLevel({
    required String category,
    required String subCategory,
    required String level,
  }) async {
    try {
      await _quizRemoteDataSource.updateLevel(
        category: category,
        level: level,
        subCategory: subCategory,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getQuestions(
    QuizTypes? quizType, {
    String? languageId,
    String? categoryId,
    String? subcategoryId,
    String? numberOfQuestions,
    String? level,
    String? contestId,
    String? funAndLearnId,
  }) async {
    try {
      final List<Map<String, dynamic>> result;

      if (quizType == QuizTypes.dailyQuiz) {
        result = await _quizRemoteDataSource.getQuestionsForDailyQuiz(
          languageId: languageId,
        );
      } else if (quizType == QuizTypes.selfChallenge) {
        result = await _quizRemoteDataSource.getQuestionsForSelfChallenge(
          languageId: languageId!,
          categoryId: categoryId!,
          numberOfQuestions: numberOfQuestions!,
          subcategoryId: subcategoryId!,
        );
      } else if (quizType == QuizTypes.quizZone) {
        //if level is 0 means need to fetch questions by get_question api endpoint
        if (level! == '0') {
          final type = categoryId!.isNotEmpty ? 'category' : 'subcategory';
          final id = type == 'category' ? categoryId : subcategoryId!;
          result =
              await _quizRemoteDataSource.getQuestionByCategoryOrSubcategory(
            type: type,
            id: id,
          );
        } else {
          result = await _quizRemoteDataSource.getQuestionsForQuizZone(
            languageId: languageId!,
            categoryId: categoryId!,
            subcategoryId: subcategoryId!,
            level: level,
          );
        }
      } else if (quizType == QuizTypes.trueAndFalse) {
        result = await _quizRemoteDataSource.getQuestionByType(languageId!);
      } else if (quizType == QuizTypes.contest) {
        result = await _quizRemoteDataSource.getQuestionContest(contestId!);
      } else if (quizType == QuizTypes.funAndLearn) {
        result =
            await _quizRemoteDataSource.getComprehensionQuestion(funAndLearnId);
      } else if (quizType == QuizTypes.audioQuestions) {
        final type = categoryId!.isNotEmpty ? 'category' : 'subcategory';
        final id = type == 'category' ? categoryId : subcategoryId!;
        result =
            await _quizRemoteDataSource.getAudioQuestions(type: type, id: id);
      } else if (quizType == QuizTypes.mathMania) {
        final type = categoryId!.isNotEmpty ? 'category' : 'subcategory';
        final id = type == 'category' ? categoryId : subcategoryId!;
        result =
            await _quizRemoteDataSource.getLatexQuestions(type: type, id: id);
      } else {
        result = [];
      }

      return result.map(Question.fromJson).toList(growable: false);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<GuessTheWordQuestion>> getGuessTheWordQuestions({
    required String languageId,
    required String type, //category or subcategory
    required String typeId, //id of the category or subcategory
  }) async {
    try {
      final result = await _quizRemoteDataSource.getGuessTheWordQuestions(
        languageId: languageId,
        type: type,
        typeId: typeId,
      );

      return result.map(GuessTheWordQuestion.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<Contests> getContest({required String languageId}) async {
    try {
      final result =
          await _quizRemoteDataSource.getContest(languageId: languageId);
      return Contests.fromJson(result);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> setContestLeaderboard({
    String? contestId,
    int? questionAttended,
    int? correctAns,
    int? score,
  }) async {
    try {
      await _quizRemoteDataSource.setContestLeaderboard(
        contestId: contestId,
        questionAttended: questionAttended,
        correctAns: correctAns,
        score: score,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<ContestLeaderboard>> getContestLeaderboard({
    String? contestId,
  }) async {
    try {
      final result =
          await _quizRemoteDataSource.getContestLeaderboard(contestId);

      return result.map(ContestLeaderboard.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Comprehension>> getComprehension({
    required String languageId,
    required String type,
    required String typeId,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getComprehension(
        languageId: languageId,
        type: type,
        typeId: typeId,
      );

      return result.map(Comprehension.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> setQuizCategoryPlayed({
    required String type,
    required String categoryId,
    required String subcategoryId,
    required String typeId,
  }) async {
    try {
      await _quizRemoteDataSource.setQuizCategoryPlayed(
        type: type,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        typeId: typeId,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> unlockPremiumCategory({
    required String categoryId,
    String? subCategoryId,
  }) async {
    try {
      await _quizRemoteDataSource.unlockPremiumCategory(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }
}
