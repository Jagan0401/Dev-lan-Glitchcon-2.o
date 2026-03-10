import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'i_auth_service.dart';
import '../constants/test_data.dart';
import '../constants/app_constants.dart';
import '../../features/auth/models/login_request.dart';
import '../../features/auth/models/auth_user.dart';

/// Mock auth service for testing — bypasses API calls and uses test data
class MockAuthService implements IAuthService {
  final _storage = const FlutterSecureStorage();
  static const _mockToken = 'mock_jwt_token_for_testing';

  /// Mock login — accepts any test user credentials
  Future<AuthUser> login(LoginRequest request) async {
    // Minimal delay for instant login
    await Future.delayed(const Duration(milliseconds: 100));

    // Find matching test user
    final testUser = TestData.testUsers.values.firstWhere(
      (u) =>
          u.email.toLowerCase() == request.email.toLowerCase() &&
          u.password == request.password &&
          u.role == request.role,
      orElse: () => throw Exception(
        'Invalid credentials. Check email, password, and role.\n\n'
        'Available test users:\n'
        '${TestData.testUsers.values.map((u) => u.toString()).join('\n')}',
      ),
    );

    // Store mock tokens
    await _storage.write(key: AppConstants.accessTokenKey, value: _mockToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: _mockToken);

    return TestData.testUserToAuthUser(testUser);
  }

  /// Mock session check
  Future<AuthUser?> checkSession() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null || token != _mockToken) return null;

    // Return last logged-in user (for testing)
    // In a real app, this would query the backend
    return null;
  }

  /// Mock logout
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Mock password reset
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
