abstract class AppConstants {
  // ── API ──────────────────────────────────────────────────────
  /// Base URL of the Django backend.
  /// Override per-environment via --dart-define=BASE_URL=https://...
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  // ── Secure Storage Keys ──────────────────────────────────────
  static const accessTokenKey = 'medisync_access_token';
  static const refreshTokenKey = 'medisync_refresh_token';
  static const lastRoleKey = 'medisync_last_role';

  // ── UI ───────────────────────────────────────────────────────
  static const animationDurationFast = Duration(milliseconds: 200);
  static const animationDurationNormal = Duration(milliseconds: 350);
  static const animationDurationSlow = Duration(milliseconds: 600);

  static const cardBorderRadius = 16.0;
  static const inputBorderRadius = 10.0;
  static const buttonBorderRadius = 10.0;
  static const chipBorderRadius = 100.0;

  // ── Pagination ───────────────────────────────────────────────
  static const defaultPageSize = 20;

  // ── Contact ──────────────────────────────────────────────────
  static const salesEmail = 'sales@medisync.ai';
  static const supportEmail = 'support@medisync.ai';
  static const demoSubject = 'MediSynC Demo & Trial Request';
  static const recoverySubject = 'Password Recovery Request';
  static const defaultDemoMessage =
      'I would like to request a trial for the MediSynC service and learn '
      'more about how it can help our hospital synchronize data, doctors, '
      'and patients.';
}
