import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../services/i_auth_service.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Set to true to use mock auth for testing.
/// Default is real API; override with --dart-define=USE_MOCK_AUTH=true when needed.
const bool _useMockAuth = bool.fromEnvironment(
  'USE_MOCK_AUTH',
  defaultValue: false,
);

Future<void> configureDependencies() async {
  // ── Network ──────────────────────────────────────────────────
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // ── Dashboard data ───────────────────────────────────────────
  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(apiClient: getIt<ApiClient>()),
  );

  // ── Services ─────────────────────────────────────────────────
  if (_useMockAuth) {
    // Use mock auth service for testing
    getIt.registerLazySingleton<IAuthService>(() => MockAuthService());
  } else {
    // Use real auth service
    getIt.registerLazySingleton<IAuthService>(
      () => AuthService(apiClient: getIt<ApiClient>()),
    );
  }

  // ── BLoCs ────────────────────────────────────────────────────
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authService: getIt<IAuthService>()),
  );
}
