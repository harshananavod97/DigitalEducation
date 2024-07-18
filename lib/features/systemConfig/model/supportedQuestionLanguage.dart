class SupportedLanguage {
  SupportedLanguage({
    required this.id,
    required this.language,
    required this.languageCode,
  });

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      id: json['id'] as String,
      language: json['language'] as String,
      languageCode: json['code'] as String,
    );
  }

  final String id;
  final String language;
  final String languageCode;
}
