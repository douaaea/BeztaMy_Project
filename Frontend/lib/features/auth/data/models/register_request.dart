import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String telephone;
  final String password;
  final String? profilePicture;
  final String? status;

  RegisterRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.telephone,
    required this.password,
    this.profilePicture,
    this.status,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
