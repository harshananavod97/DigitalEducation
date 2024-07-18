import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class WinnersModel {
  String ConId;
  String Month_Name;
  List<dynamic> Winner_Description_Sinhala;
  List<dynamic> Winner_Description_Tamil;
  List<dynamic> Winner_Description_English;
  List<dynamic> Winner_Post_Image;
  List<dynamic> Winners_Profile_Image;
  List<dynamic> Winner_Names;
  WinnersModel(
      this.ConId,
      this.Month_Name,
      this.Winner_Description_Sinhala,
      this.Winner_Description_Tamil,
      this.Winner_Description_English,
      this.Winner_Post_Image,
      this.Winners_Profile_Image,
      this.Winner_Names);

  factory WinnersModel.fromJson(Map<String, dynamic> json) =>
      _$WinnersModelFromJson(json);

  Map<String, dynamic> toJson() => _$WinnersModelToJson(this);
}

WinnersModel _$WinnersModelFromJson(Map<String, dynamic> json) {
  return WinnersModel(
      json['ConId'] as String,
      json['Month_Name'] as String,
      (json['Winner_Description_Sinhala'] as List<dynamic>?) ?? [],
      (json['Winner_Description_Tamil'] as List<dynamic>?) ?? [],
      (json['Winner_Description_English'] as List<dynamic>?) ?? [],
      (json['Winner_Post_Image'] as List<dynamic>?) ?? [],
      (json['Winners_Profile_Image'] as List<dynamic>?) ?? [],
      (json['Winner_Names'] as List<dynamic>?) ?? []);
}

Map<String, dynamic> _$WinnersModelToJson(WinnersModel instance) =>
    <String, dynamic>{
      'ConId': instance.ConId,
      'Month_Name': instance.Month_Name,
      'Winner_Description_Sinhala': instance.Winner_Description_Sinhala,
      'Winner_Description_Tamil': instance.Winner_Description_Tamil,
      'Winner_Description_English': instance.Winner_Description_English,
      'Winner_Post_Image': instance.Winner_Post_Image,
      'Winners_Profile_Image': instance.Winners_Profile_Image,
      'Winner_Names': instance.Winners_Profile_Image,
    };
