import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/badgesException.dart';
import 'package:flutterquiz/features/badges/badgesRemoteDataSource.dart';

class BadgesRepository {
  factory BadgesRepository() {
    _badgesRepository._badgesRemoteDataSource = BadgesRemoteDataSource();
    return _badgesRepository;
  }

  BadgesRepository._internal();

  static final _badgesRepository = BadgesRepository._internal();
  late BadgesRemoteDataSource _badgesRemoteDataSource;

  Future<List<Badges>> getBadges({required String languageId}) async {
    try {
      final result =
          await _badgesRemoteDataSource.getBadges(languageId: languageId);

      return result.map(Badges.fromJson).toList();
    } catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    }
  }

  Future<void> setBadge({
    required String badgeType,
    required String languageId,
  }) async {
    try {
      await _badgesRemoteDataSource.setBadges(
        badgeType: badgeType,
        languageId: languageId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
