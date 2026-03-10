import '../../features/auth/models/auth_user.dart';

/// Sample users for testing each role — use these credentials to test login
abstract class TestData {
  // Test credentials - Hospital ID
  static const String testHospitalId = 'apollo_delhi';

  // Sample users for each role
  static final testUsers = {
    'doctor': TestUser(
      id: 'doc_001',
      email: 'dr.singh@apollo.com',
      password: 'test@123',
      fullName: 'Dr. Rajesh Singh',
      hospitalId: testHospitalId,
      role: UserRole.doctor,
      avatarUrl: null,
    ),
    'coordinator': TestUser(
      id: 'coord_001',
      email: 'kavya.patel@apollo.com',
      password: 'test@123',
      fullName: 'Kavya Patel',
      hospitalId: testHospitalId,
      role: UserRole.coordinator,
      avatarUrl: null,
    ),
    'hospitalAdmin': TestUser(
      id: 'admin_001',
      email: 'admin@apollo.com',
      password: 'test@123',
      fullName: 'Meera Iyer',
      hospitalId: testHospitalId,
      role: UserRole.hospitalAdmin,
      avatarUrl: null,
    ),
    'labTechnician': TestUser(
      id: 'tech_001',
      email: 'arjun.kumar@apollo.com',
      password: 'test@123',
      fullName: 'Arjun Kumar',
      hospitalId: testHospitalId,
      role: UserRole.labTechnician,
      avatarUrl: null,
    ),
    'superAdmin': TestUser(
      id: 'super_001',
      email: 'admin@medisync.ai',
      password: 'test@123',
      fullName: 'Platform Admin',
      hospitalId: 'medisync',
      role: UserRole.superAdmin,
      avatarUrl: null,
    ),
  };

  /// Convert TestUser to AuthUser for mock auth
  static AuthUser testUserToAuthUser(TestUser user) => AuthUser(
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    role: user.role,
    hospitalId: user.hospitalId,
    avatarUrl: user.avatarUrl,
  );
}

/// Simple test user model
class TestUser {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String hospitalId;
  final UserRole role;
  final String? avatarUrl;

  const TestUser({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.hospitalId,
    required this.role,
    this.avatarUrl,
  });

  @override
  String toString() => '$role: $email / $password';
}
