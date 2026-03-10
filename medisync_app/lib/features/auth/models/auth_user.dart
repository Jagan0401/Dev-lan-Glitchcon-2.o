/// Represents the authenticated user returned from the Django backend.
class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String hospitalId;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.hospitalId,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.fromString(json['role'] as String),
      hospitalId: json['hospital_id'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role.apiValue,
    'hospital_id': hospitalId,
    'avatar_url': avatarUrl,
  };
}

/// Mirrors the role values used in the Django backend and the HTML <select>.
enum UserRole {
  doctor,
  coordinator,
  hospitalAdmin,
  labTechnician,
  superAdmin;

  String get apiValue => switch (this) {
    UserRole.doctor => 'doctor',
    UserRole.coordinator => 'coordinator',
    UserRole.hospitalAdmin => 'hospital_admin',
    UserRole.labTechnician => 'technician',
    UserRole.superAdmin => 'platform_admin',
  };

  String get displayName => switch (this) {
    UserRole.doctor => 'Doctor',
    UserRole.coordinator => 'Care Coordinator',
    UserRole.hospitalAdmin => 'Hospital Admin',
    UserRole.labTechnician => 'Lab Technician',
    UserRole.superAdmin => 'Platform Admin',
  };

  static UserRole fromString(String value) => switch (value) {
    'doctor' => UserRole.doctor,
    'coordinator' => UserRole.coordinator,
    'hospital_admin' => UserRole.hospitalAdmin,
    'technician' => UserRole.labTechnician,
    'platform_admin' => UserRole.superAdmin,
    _ => throw ArgumentError('Unknown role: $value'),
  };
}
