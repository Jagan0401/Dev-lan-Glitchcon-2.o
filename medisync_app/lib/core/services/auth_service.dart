import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'i_auth_service.dart';
import '../constants/app_constants.dart';
import '../../features/auth/models/login_request.dart';
import '../../features/auth/models/auth_user.dart';
import 'api_client.dart';

class AuthService implements IAuthService {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// POST /auth/login/  →  JWT pair + user profile
  Future<AuthUser> login(LoginRequest request) async {
    final response = await _apiClient.dio.post(
      '/auth/login/',
      data: request.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access'] as String;
    final refreshToken = data['refresh'] as String;

    // Persist tokens in secure storage
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );

    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Check whether a valid session already exists (app cold-start)
  Future<AuthUser?> checkSession() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null) return null;

    try {
      final response = await _apiClient.dio.get('/auth/me/');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// POST /auth/logout/  +  clear local tokens
  Future<void> logout() async {
    try {
      final refresh = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refresh != null) {
        await _apiClient.dio.post('/auth/logout/', data: {'refresh': refresh});
      }
    } catch (_) {
      // Best-effort — always clear local storage
    } finally {
      await _storage.deleteAll();
    }
  }

  /// POST /auth/password-reset/  →  sends recovery email
  Future<void> requestPasswordReset(String email) async {
    await _apiClient.dio.post('/auth/password-reset/', data: {'email': email});
  }
}
