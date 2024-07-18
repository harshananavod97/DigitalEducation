class CoinHistory {
  CoinHistory({
    required this.id,
    required this.userId,
    required this.uid,
    required this.points,
    required this.type,
    required this.status,
    required this.date,
  });

  CoinHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String? ?? '';
    userId = json['user_id'] as String? ?? '';
    uid = json['uid'] as String? ?? '';
    points = json['points'] as String? ?? '';
    type = json['type'] as String? ?? '';
    status = json['status'] as String? ?? '';
    date = json['date'] as String? ?? '';
  }

  late final String id;
  late final String userId;
  late final String uid;
  late final String points;
  late final String type;
  late final String status;
  late final String date;
}
