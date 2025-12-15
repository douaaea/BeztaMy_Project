// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileResponse _$UserProfileResponseFromJson(Map<String, dynamic> json) =>
    UserProfileResponse(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      telephone: json['telephone'] as String?,
      status: json['status'] as String,
      profilePicture: json['profilePicture'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
      riskTolerance: json['riskTolerance'] as String?,
      financialGoals: json['financialGoals'] as String?,
    );

Map<String, dynamic> _$UserProfileResponseToJson(
  UserProfileResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'telephone': instance.telephone,
  'status': instance.status,
  'profilePicture': instance.profilePicture,
  'createdAt': instance.createdAt.toIso8601String(),
  'monthlyBudget': instance.monthlyBudget,
  'riskTolerance': instance.riskTolerance,
  'financialGoals': instance.financialGoals,
};
