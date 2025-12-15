import 'package:json_annotation/json_annotation.dart';

part 'user_profile_response.g.dart';

@JsonSerializable()
class UserProfileResponse {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? telephone;
  final String status;
  final String? profilePicture;
  final DateTime createdAt;
  final double? monthlyBudget;
  final String? riskTolerance;
  final String? financialGoals;

  UserProfileResponse({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.telephone,
    required this.status,
    this.profilePicture,
    required this.createdAt,
    this.monthlyBudget,
    this.riskTolerance,
    this.financialGoals,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
}
