import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';

class ContestLeaderboard {
  const ContestLeaderboard({
    this.userId,
    this.score,
    this.userRank,
    this.name,
    this.profile,
  });

  ContestLeaderboard.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'] as String?,
        score = json['score'] as String?,
        userRank = json['user_rank'] as String?,
        name = json['name'] as String?,
        profile = json[profileKey] as String?;

  final String? userId;
  final String? score;
  final String? userRank;
  final String? name;
  final String? profile;
}
