import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';

class LeaderBoardMonthly {
  const LeaderBoardMonthly({
    this.userId,
    this.score,
    this.userRank,
    this.email,
    this.name,
    this.profile,
  });

  LeaderBoardMonthly.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'] as String?,
        score = json['score'] as String?,
        userRank = json['user_rank'] as String?,
        email = json[emailKey] as String?,
        name = json['name'] as String?,
        profile = json[profileKey] as String?;

  final String? userId;
  final String? score;
  final String? userRank;
  final String? email;
  final String? name;
  final String? profile;
}

class MyRank {
  const MyRank({
    this.userId,
    this.score,
    this.userRank,
    this.email,
    this.name,
    this.profile,
  });

  MyRank.fromJson(Map<dynamic, dynamic> jsonData)
      : userId = jsonData['user_id'] as String?,
        score = jsonData['score'] as String?,
        userRank = jsonData['user_rank'] as String?,
        email = jsonData[emailKey] as String?,
        name = jsonData['name'] as String?,
        profile = jsonData[profileKey] as String?;

  final String? userId;
  final String? score;
  final String? userRank;
  final String? email;
  final String? name;
  final String? profile;
}
