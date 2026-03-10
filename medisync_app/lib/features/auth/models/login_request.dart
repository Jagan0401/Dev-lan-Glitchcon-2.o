import 'auth_user.dart';

class LoginRequest {
  final String hospitalId;
  final String email;
  final String password;
  final UserRole role;

  const LoginRequest({
    required this.hospitalId,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'hospital_id': hospitalId,
    'email': email,
    'password': password,
    'role': role.apiValue,
  };
}
