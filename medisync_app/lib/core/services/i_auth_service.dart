import '../../features/auth/models/login_request.dart';
import '../../features/auth/models/auth_user.dart';

/// Abstract auth service interface
/// Both AuthService (real) and MockAuthService (test) implement this
abstract class IAuthService {
  /// Login with credentials
  Future<AuthUser> login(LoginRequest request);

  /// Check existing session
  Future<AuthUser?> checkSession();

  /// Logout and clear session
  Future<void> logout();

  /// Request password reset
  Future<void> requestPasswordReset(String email);
}
