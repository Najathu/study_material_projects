// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freezed_examples.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'skills': instance.skills,
  'is_active': instance.isActive,
};
