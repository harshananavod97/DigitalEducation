import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StudyTipsModel {
  String ConId;

  List<dynamic> Simage;
  List<dynamic> Timage;
  List<dynamic> Eimage;

  List<dynamic> English_Tips;
  List<dynamic> English_Title;

  List<dynamic> Sinhala_Tips;
  List<dynamic> Sinhala_Title;
  List<dynamic> Tamil_Tips;

  List<dynamic> Tamil_Title;

  StudyTipsModel(
      this.ConId,
      this.Simage,
      this.Eimage,
      this.Timage,
      this.English_Tips,
      this.English_Title,
      this.Sinhala_Tips,
      this.Sinhala_Title,
      this.Tamil_Tips,
      this.Tamil_Title);

  factory StudyTipsModel.fromJson(Map<String, dynamic> json) =>
      _$StudyTipsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudyTipsModelToJson(this);
}

StudyTipsModel _$StudyTipsModelFromJson(Map<String, dynamic> json) {
  return StudyTipsModel(
    json['ConId'] as String,
    (json['Simage'] as List<dynamic>?) ?? [],
    (json['Eimage'] as List<dynamic>?) ?? [],
    (json['Timage'] as List<dynamic>?) ?? [],
    (json['English_Tips'] as List<dynamic>?) ?? [],
    (json['English_Title'] as List<dynamic>?) ?? [],
    (json['Sinhala_Tips'] as List<dynamic>?) ?? [],
    (json['Sinhala_Title'] as List<dynamic>?) ?? [],
    (json['Tamil_Tips'] as List<dynamic>?) ?? [],
    (json['Tamil_Title'] as List<dynamic>?) ?? [],
  );
}

Map<String, dynamic> _$StudyTipsModelToJson(StudyTipsModel instance) =>
    <String, dynamic>{
      'ConId': instance.ConId,
      'Simage': instance.ConId,
      'Eimage': instance.ConId,
      'Timage': instance.ConId,
      'English_Tips': instance.English_Tips,
      'English_Title': instance.English_Title,
      'Sinhala_Tips': instance.Sinhala_Tips,
      'Sinhala_Title': instance.English_Tips,
      'Tamil_Tips': instance.English_Title,
      'Tamil_Title': instance.Sinhala_Tips,
    };
