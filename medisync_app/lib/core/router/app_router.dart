import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/screens/login_screen.dart';
import '../theme/app_theme.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/book_demo_screen.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/models/auth_user.dart';
import '../../features/doctor/screens/doctor_dashboard.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/screens/unauthorised_screen.dart';

import '../../features/lab_tech/screens/technician_dashboard.dart';
import '../../features/hospital_admin/screens/hospital_admin_dashboard.dart';
import '../../features/super_admin/screens/platform_admin_dashboard.dart';

// Coordinator dashboard — uncomment once the screen is implemented:
// import '../../features/coordinator/screens/coordinator_dashboard.dart';

/// Route name constants — use these instead of raw strings throughout the app.
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/login/forgot-password';
  static const bookDemo = '/login/book-demo';
  static const unauthorised = '/unauthorised';

  // Role shells
  static const doctorDashboard = '/doctor/dashboard';
  static const coordinatorDashboard = '/coordinator/dashboard';
  static const hospitalAdminDashboard = '/hospital-admin/dashboard';
  static const labTechDashboard = '/lab-tech/dashboard';
  static const superAdminDashboard = '/super-admin/dashboard';
}

class AppRouter {
  final AuthState authState;
  AppRouter({required this.authState});

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: _guard,
    routes: [
      // ── Splash ──────────────────────────────────────────
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),

      // ── Auth ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'forgot-password',
            builder: (_, __) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: 'book-demo',
            builder: (_, __) => const BookDemoScreen(),
          ),
        ],
      ),

      // ── Unauthorised ────────────────────────────────────
      GoRoute(
        path: AppRoutes.unauthorised,
        builder: (_, __) => const UnauthorisedScreen(),
      ),

      // ── Doctor ───────────────────────────────────────────
      GoRoute(path: '/doctor', redirect: (_, __) => AppRoutes.doctorDashboard),
      GoRoute(
        path: AppRoutes.doctorDashboard,
        builder: (_, __) => const DoctorDashboard(),
      ),

      // ── Other roles (stub routes — add screens as built) ─
      GoRoute(
        path: AppRoutes.coordinatorDashboard,
        builder: (_, __) => const _RoleStubScreen(role: 'Care Coordinator'),
      ),
      GoRoute(
        path: AppRoutes.hospitalAdminDashboard,
        builder: (_, __) => const HospitalAdminDashboard(),
      ),
      // ── Lab Technician ───────────────────────────────────
      GoRoute(
        path: '/lab-tech',
        redirect: (_, __) => AppRoutes.labTechDashboard,
      ),
      GoRoute(
        path: AppRoutes.labTechDashboard,
        builder: (_, __) => const TechnicianDashboard(),
      ),
      GoRoute(
        path: AppRoutes.superAdminDashboard,
        builder: (_, __) => const PlatformAdminDashboard(),
      ),
    ],
  );

  /// Global route guard.
  /// Unauthenticated → /login
  /// Authenticated → role shell
  /// Wrong role → /unauthorised
  String? _guard(BuildContext context, GoRouterState state) {
    final isOnSplash = state.matchedLocation == AppRoutes.splash;
    final isOnAuth = state.matchedLocation.startsWith('/login');

    if (authState is AuthLoadingState) {
      return isOnSplash ? null : AppRoutes.splash;
    }

    if (authState is AuthUnauthenticatedState || authState is AuthErrorState) {
      return isOnAuth ? null : AppRoutes.login;
    }

    if (authState is AuthAuthenticatedState) {
      final role = (authState as AuthAuthenticatedState).role;
      // Redirect away from auth & splash pages once logged in
      if (isOnAuth || isOnSplash) {
        return _roleHomeRoute(role);
      }
      // Guard each role section
      if (state.matchedLocation.startsWith('/doctor') &&
          role != UserRole.doctor) {
        return AppRoutes.unauthorised;
      }
      if (state.matchedLocation.startsWith('/coordinator') &&
          role != UserRole.coordinator) {
        return AppRoutes.unauthorised;
      }
      if (state.matchedLocation.startsWith('/hospital-admin') &&
          role != UserRole.hospitalAdmin) {
        return AppRoutes.unauthorised;
      }
      if (state.matchedLocation.startsWith('/lab-tech') &&
          role != UserRole.labTechnician) {
        return AppRoutes.unauthorised;
      }
      if (state.matchedLocation.startsWith('/super-admin') &&
          role != UserRole.superAdmin) {
        return AppRoutes.unauthorised;
      }
    }
    return null;
  }

  String _roleHomeRoute(UserRole role) {
    return switch (role) {
      UserRole.doctor => AppRoutes.doctorDashboard,
      UserRole.coordinator => AppRoutes.coordinatorDashboard,
      UserRole.hospitalAdmin => AppRoutes.hospitalAdminDashboard,
      UserRole.labTechnician => AppRoutes.labTechDashboard,
      UserRole.superAdmin => AppRoutes.superAdminDashboard,
    };
  }
}

// ── Stub screen for unbuilt role dashboards ──────────────────────────────────

class _RoleStubScreen extends StatelessWidget {
  final String role;
  const _RoleStubScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$role Dashboard',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in the next sprint',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
