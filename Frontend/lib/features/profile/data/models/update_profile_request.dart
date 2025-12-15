import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? telephone;
  final String? status;
  final String? profilePicture;
  final double? monthlyBudget;
  final String? riskTolerance;
  final String? financialGoals;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.telephone,
    this.status,
    this.profilePicture,
    this.monthlyBudget,
    this.riskTolerance,
    this.financialGoals,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
