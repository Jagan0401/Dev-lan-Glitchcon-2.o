import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Resolve the API base URL for the current platform.
String _resolveBaseUrl() {
  const env = AppConstants.baseUrl;
  if (kIsWeb) {
    // 10.0.2.2 is Android-emulator-only; on web use localhost.
    return env.replaceFirst('10.0.2.2', 'localhost');
  }
  return env;
}

class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => debugPrint('[API] $log'),
      ),
    );
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(
          key: AppConstants.refreshTokenKey,
        );
        if (refreshToken == null) {
          _isRefreshing = false;
          return handler.next(err);
        }

        // Attempt token refresh against Django SimpleJWT endpoint
        final response = await _dio.post(
          '/auth/token/refresh/',
          data: {'refresh': refreshToken},
          options: Options(
            headers: {'Authorization': null}, // No auth header for refresh
          ),
        );

        final newAccessToken = response.data['access'] as String;
        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: newAccessToken,
        );

        // Retry original request with new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(retryOptions);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } catch (_) {
        _isRefreshing = false;
        // Refresh failed — let AuthBloc handle logout
        await _storage.deleteAll();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
