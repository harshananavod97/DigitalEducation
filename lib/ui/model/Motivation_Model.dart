import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class MotivationModel {
  String ConId;
  String Simage;

  String Timage;
  String Eimage;
  List<dynamic> English_Motivation;
  List<dynamic> Sinhala_Motivation;

  List<dynamic> Tamil_Motivation;

  MotivationModel(this.ConId, this.Timage, this.Eimage, this.Simage,
      this.English_Motivation, this.Sinhala_Motivation, this.Tamil_Motivation);

  factory MotivationModel.fromJson(Map<String, dynamic> json) =>
      _$MotivationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MotivationModelToJson(this);
}

MotivationModel _$MotivationModelFromJson(Map<String, dynamic> json) {
  return MotivationModel(
    json['ConId'] as String,
    json['Timage'] as String,
    json['Eimage'] as String,
    json['Simage'] as String,
    (json['English_Motivation'] as List<dynamic>?) ?? [],
    (json['Sinhala_Motivation'] as List<dynamic>?) ?? [],
    (json['Tamil_Motivation'] as List<dynamic>?) ?? [],
  );
}

Map<String, dynamic> _$MotivationModelToJson(MotivationModel instance) =>
    <String, dynamic>{
      'ConId': instance.ConId,
      'Timage': instance.ConId,
      'Eimage': instance.ConId,
      'Simage': instance.ConId,
      'English_Motivation': instance.English_Motivation,
      'Sinhala_Motivation': instance.Sinhala_Motivation,
      'Tamil_Motivation': instance.Tamil_Motivation,
    };
