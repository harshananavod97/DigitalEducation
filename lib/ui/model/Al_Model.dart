import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AlModel {
  String ConId;
  List<dynamic> S_Paper;
  List<dynamic> S_Paper_Title;

  List<dynamic> T_Paper;
  List<dynamic> T_Paper_Title;

  List<dynamic> E_Paper;
  List<dynamic> E_Paper_Title;
  List<dynamic> S_Note;
  List<dynamic> S_Note_Title;
  List<dynamic> T_Note;
  List<dynamic> T_Note_Title;
  List<dynamic> E_Note;
  List<dynamic> E_Note_Title;

  AlModel(
    this.ConId,
    this.S_Note,
    this.S_Note_Title,
    this.S_Paper,
    this.S_Paper_Title,
        this.T_Note,
    this.T_Note_Title,
    this.T_Paper,
    this.T_Paper_Title,
        this.E_Note,
    this.E_Note_Title,
    this.E_Paper,
    this.E_Paper_Title,
  );

  factory AlModel.fromJson(Map<String, dynamic> json) =>
      _$AlModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlModelToJson(this);
}

AlModel _$AlModelFromJson(Map<String, dynamic> json) {
  return AlModel(
    json['ConId'] as String,
    (json['S_Note'] as List<dynamic>?) ?? [],
    (json['S_Note_Title'] as List<dynamic>?) ?? [],
    (json['S_Paper'] as List<dynamic>?) ?? [],
    (json['S_Paper_Title'] as List<dynamic>?) ?? [],
       (json['T_Note'] as List<dynamic>?) ?? [],
    (json['T_Note_Title'] as List<dynamic>?) ?? [],
    (json['T_Paper'] as List<dynamic>?) ?? [],
    (json['T_Paper_Title'] as List<dynamic>?) ?? [],
          (json['E_Note'] as List<dynamic>?) ?? [],
    (json['E_Note_Title'] as List<dynamic>?) ?? [],
    (json['E_Paper'] as List<dynamic>?) ?? [],
    (json['E_Paper_Title'] as List<dynamic>?) ?? [],
    
  );
}

Map<String, dynamic> _$AlModelToJson(AlModel instance) => <String, dynamic>{
      'ConId': instance.ConId,
      'S_Note': instance.S_Note,
      'S_Note_Title': instance.S_Note_Title,
      'S_Paper': instance.S_Paper,
      'S_Paper_Title': instance.S_Paper_Title,
          'T_Note': instance.S_Note,
      'T_Note_Title': instance.S_Note_Title,
      'T_Paper': instance.S_Paper,
      'T_Paper_Title': instance.S_Paper_Title,
            'E_Note': instance.S_Note,
      'E_Note_Title': instance.S_Note_Title,
      'E_Paper': instance.S_Paper,
      'E_Paper_Title': instance.S_Paper_Title,
    };
