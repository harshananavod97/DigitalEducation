//class Contest {
class Contests {
  Contests({required this.live, required this.past, required this.upcoming});

  Contests.fromJson(Map<String, dynamic> json)
      : live = Contest.fromJson(json['live_contest'] as Map<String, dynamic>),
        past = Contest.fromJson(json['past_contest'] as Map<String, dynamic>),
        upcoming =
            Contest.fromJson(json['upcoming_contest'] as Map<String, dynamic>);

  final Contest past;
  final Contest live;
  final Contest upcoming;
}

class Contest {
  Contest({required this.contestDetails, required this.errorMessage});

  Contest.fromJson(Map<String, dynamic> json) {
    final hasError = json['error'] as bool;
    errorMessage = hasError ? json['message'] as String : '';
    contestDetails = hasError
        ? <ContestDetails>[]
        : (json['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(ContestDetails.fromJson)
            .toList(growable: false);
  }

  late final String errorMessage;
  late final List<ContestDetails> contestDetails;
}

class ContestDetails {
  ContestDetails({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.description,
    this.image,
    this.entry,
    this.prizeStatus,
    this.dateCreated,
    this.status,
    this.points,
    this.topUsers,
    this.participants,
    this.showDescription,
  });

  ContestDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    startDate = json['start_date'] as String?;
    endDate = json['end_date'] as String?;
    description = json['description'] as String?;
    image = json['image'] as String?;
    entry = json['entry'] as String?;
    prizeStatus = json['prize_status'] as String?;
    dateCreated = json['date_created'] as String?;
    status = json['status'] as String?;
    points = (json['points'] as List?)?.cast<Map<String, dynamic>>();
    topUsers = json['top_users'] as String?;
    participants = json['participants'] as String?;
  }

  String? id;
  String? name;
  String? startDate;
  String? endDate;
  String? description;
  String? image;
  String? entry;
  String? prizeStatus;
  String? dateCreated;
  String? status;
  List<Map<String, dynamic>>? points;
  String? topUsers;
  String? participants;
  bool? showDescription = false;
}
