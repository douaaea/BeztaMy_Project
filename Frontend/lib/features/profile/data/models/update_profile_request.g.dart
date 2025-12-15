// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  telephone: json['telephone'] as String?,
  status: json['status'] as String?,
  profilePicture: json['profilePicture'] as String?,
  monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
  riskTolerance: json['riskTolerance'] as String?,
  financialGoals: json['financialGoals'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'telephone': instance.telephone,
  'status': instance.status,
  'profilePicture': instance.profilePicture,
  'monthlyBudget': instance.monthlyBudget,
  'riskTolerance': instance.riskTolerance,
  'financialGoals': instance.financialGoals,
};
