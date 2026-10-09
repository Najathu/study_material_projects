// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pet _$PetFromJson(Map<String, dynamic> json) => _Pet(
  name: json['name'] as String,
  id: (json['id'] as num?)?.toInt(),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  photoUrls: (json['photoUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] == null
      ? null
      : PetStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$PetToJson(_Pet instance) => <String, dynamic>{
  'name': instance.name,
  'id': instance.id,
  'category': instance.category,
  'photoUrls': instance.photoUrls,
  'tags': instance.tags,
  'status': _$PetStatusEnumMap[instance.status],
};

const _$PetStatusEnumMap = {
  PetStatus.available: 'available',
  PetStatus.pending: 'pending',
  PetStatus.sold: 'sold',
  PetStatus.$unknown: r'$unknown',
};
