import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String token;
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
