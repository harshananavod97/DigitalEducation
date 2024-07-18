import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class HowToWinModel {
  String ConId;
  String Eimage;
  String Simage;
  String Timage;

  List<dynamic> English;
  List<dynamic> Sinhala;
  List<dynamic> Tamil;

  HowToWinModel(
    this.ConId,
    this.Eimage,
    this.Simage,
    this.Timage,
    this.English,
    this.Sinhala,
    this.Tamil,
  );

  factory HowToWinModel.fromJson(Map<String, dynamic> json) =>
      _$HowToWinModelFromJson(json);

  Map<String, dynamic> toJson() => _$HowToWinModelToJson(this);
}

HowToWinModel _$HowToWinModelFromJson(Map<String, dynamic> json) {
  return HowToWinModel(
    json['ConId'] as String,
    json['Eimage'] as String,
    json['Simage'] as String,
    json['Timage'] as String,
    (json['English'] as List<dynamic>?) ?? [],
    (json['Sinhala'] as List<dynamic>?) ?? [],
    (json['Tamil'] as List<dynamic>?) ?? [],
  );
}

Map<String, dynamic> _$HowToWinModelToJson(HowToWinModel instance) =>
    <String, dynamic>{
      'ConId': instance.ConId,
      'Eimage': instance.ConId,
      'Simage': instance.ConId,
      'Timage': instance.ConId,
      'English': instance.English,
      'Sinhala': instance.Sinhala,
      'Tamil': instance.Tamil,
    };
