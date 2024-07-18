class Comprehension {
  const Comprehension({
    required this.isPlayed,
    required this.id,
    required this.languageId,
    required this.title,
    required this.detail,
    required this.status,
    required this.noOfQue,
  });

  Comprehension.fromJson(Map<String, dynamic> json)
      : isPlayed = (json['is_play'] as String? ?? '1') == '1',
        id = json['id'] as String,
        languageId = json['language_id'] as String,
        title = json['title'] as String,
        detail = json['detail'] as String,
        status = json['status'] as String,
        noOfQue = json['no_of_que'] as String;

  Comprehension.empty()
      : isPlayed = true,
        id = '',
        languageId = '',
        title = '',
        detail = '',
        status = '',
        noOfQue = '';

  final String id;
  final String languageId;
  final String title;
  final String detail;
  final String status;
  final String noOfQue;
  final bool isPlayed;
}
