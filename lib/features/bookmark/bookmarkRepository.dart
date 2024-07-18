import 'package:flutterquiz/features/bookmark/bookmarkException.dart';
import 'package:flutterquiz/features/bookmark/bookmarkLocalDataSource.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRemoteDataSource.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

class BookmarkRepository {
  factory BookmarkRepository() {
    _bookmarkRepository._bookmarkRemoteDataSource = BookmarkRemoteDataSource();
    _bookmarkRepository._bookmarkLocalDataSource = BookmarkLocalDataSource();
    return _bookmarkRepository;
  }

  BookmarkRepository._internal();

  static final BookmarkRepository _bookmarkRepository =
      BookmarkRepository._internal();
  late BookmarkRemoteDataSource _bookmarkRemoteDataSource;
  late BookmarkLocalDataSource _bookmarkLocalDataSource;

  //to get bookmark questions
  Future<List<dynamic>> getBookmark(String type) async {
    try {
      final result = await _bookmarkRemoteDataSource.getBookmark(type);

      if (type == '3') {
        return result.map(GuessTheWordQuestion.fromBookmarkJson).toList();
      }
      return result.map(Question.fromBookmarkJson).toList();
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //to update bookmark status (add(1) or remove(0))
  Future<void> updateBookmark(
    String questionId,
    String status,
    String type,
  ) async {
    try {
      await _bookmarkRemoteDataSource.updateBookmark(
        questionId,
        status,
        type,
      );
    } catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    }
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<Map<String, String>>> getSubmittedAnswerOfBookmarkedQuestions(
    List<String> questionIds,
    String userId,
  ) async {
    final ids = <String>[];
    //key will be in hive box is "userId-questionId"
    for (final element in questionIds) {
      ids.add('$userId-$element');
    }
    //
    return _bookmarkLocalDataSource.getAnswerOfBookmarkedQuestion(ids);
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<Map<String, String>>>
      getSubmittedAnswerOfAudioBookmarkedQuestions(
    List<String> questionIds,
    String userId,
  ) async {
    final ids = <String>[];
    //key will be in hive box is "userId-questionId"
    for (final element in questionIds) {
      ids.add('$userId-$element');
    }
    return _bookmarkLocalDataSource.getAnswerOfAudioBookmarkedQuestion(ids);
  }

  //get submitted answer for given question index which is store in hive box
  Future<List<Map<String, String>>>
      getSubmittedAnswerOfGuessTheWordBookmarkedQuestions(
    List<String> questionIds,
    String userId,
  ) async {
    final ids = <String>[];
    //key will be in hive box is "userId-questionId"
    for (final element in questionIds) {
      ids.add('$userId-$element');
    }
    return _bookmarkLocalDataSource
        .getAnswerOfGuessTheWordBookmarkedQuestion(ids);
  }

  //remove bookmark answer from hive box
  Future<void> removeBookmarkedAnswer(String id) async {
    await _bookmarkLocalDataSource.removeBookmarkedAnswer(id);
  }

  //remove bookmark answer from hive box audio
  Future<void> removeAudioBookmarkedAnswer(String id) async {
    await _bookmarkLocalDataSource.removeAudioBookmarkedAnswer(id);
  }

  //remove bookmark answer from hive box
  Future<void> removeGuessTheWordBookmarkedAnswer(String id) async {
    await _bookmarkLocalDataSource.removeGuessTheWordBookmarkedAnswer(id);
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForBookmarkedQuestion(
    String questionId,
    String submittedAnswerId,
    String userId,
  ) async {
    await _bookmarkLocalDataSource.setAnswerForBookmarkedQuestion(
      submittedAnswerId,
      questionId,
      userId,
    );
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForAudioBookmarkedQuestion(
    String questionId,
    String submittedAnswerId,
    String userId,
  ) async {
    await _bookmarkLocalDataSource.setAnswerForAudioBookmarkedQuestion(
      submittedAnswerId,
      questionId,
      userId,
    );
  }

  //set submitted answer id for given question index
  Future<void> setAnswerForGuessTheWordBookmarkedQuestion(
    String questionId,
    String submittedAnswer,
    String userId,
  ) async {
    await _bookmarkLocalDataSource.setAnswerForGuessTheWordBookmarkedQuestion(
      submittedAnswer,
      questionId,
      userId,
    );
  }
}
