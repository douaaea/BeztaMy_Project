// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryRequest _$CategoryRequestFromJson(Map<String, dynamic> json) =>
    CategoryRequest(
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$CategoryRequestToJson(CategoryRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'icon': instance.icon,
    };
