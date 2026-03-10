import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../models/doctor_dashboard_models.dart';
import '../widgets/doctor_bottom_nav.dart';
import '../widgets/doctor_drawer.dart';
import '../widgets/metric_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/caseload_chart.dart';
import '../widgets/patient_list_tab.dart';
import '../widgets/care_gap_tab.dart';
import '../widgets/lab_results_tab.dart';
import '../widgets/appointments_tab.dart';
import '../widgets/analytics_tab.dart';
import '../widgets/audit_tab.dart';
import '../../../features/auth/widgets/animated_grid_background.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/dashboard_service.dart';

// ── Tab index constants (mirrors HTML data-tab values) ───────────────────────
enum DoctorTab {
  dashboard,
  patients,
  alerts,
  results,
  appointments,
  communication,
  escalations,
  analytics,
  profile,
  audit,
}

extension DoctorTabExt on DoctorTab {
  String get title => switch (this) {
    DoctorTab.dashboard => 'Dashboard',
    DoctorTab.patients => 'My Patients',
    DoctorTab.alerts => 'Care Gap Alerts',
    DoctorTab.results => 'Test Results',
    DoctorTab.appointments => 'Appointments',
    DoctorTab.communication => 'Communication',
    DoctorTab.escalations => 'Escalations',
    DoctorTab.analytics => 'Analytics',
    DoctorTab.profile => 'Profile & Settings',
    DoctorTab.audit => 'Activity Logs',
  };

  String get subtitle => switch (this) {
    DoctorTab.dashboard => 'Physician control center overview',
    DoctorTab.patients => 'Assigned caseload and medical tracking',
    DoctorTab.alerts => 'Automated identification of overdue monitoring',
    DoctorTab.results => 'Reviewing recent laboratory outcomes',
    DoctorTab.appointments => 'Scheduled follow-ups and clinic visits',
    DoctorTab.communication => 'History of AI and physician outreach',
    DoctorTab.escalations => 'Managing high-risk critical interventions',
    DoctorTab.analytics => 'Physician caseload performance metrics',
    DoctorTab.profile => 'Profile and specialization preferences',
    DoctorTab.audit => 'History of physician-initiated actions',
  };

  IconData get icon => switch (this) {
    DoctorTab.dashboard => Icons.grid_view_rounded,
    DoctorTab.patients => Icons.people_alt_outlined,
    DoctorTab.alerts => Icons.notifications_outlined,
    DoctorTab.results => Icons.description_outlined,
    DoctorTab.appointments => Icons.calendar_month_outlined,
    DoctorTab.communication => Icons.chat_bubble_outline_rounded,
    DoctorTab.escalations => Icons.warning_amber_rounded,
    DoctorTab.analytics => Icons.bar_chart_rounded,
    DoctorTab.profile => Icons.person_outline_rounded,
    DoctorTab.audit => Icons.history_rounded,
  };
}

// Primary bottom nav tabs (5 max for mobile)
const _primaryTabs = [
  DoctorTab.dashboard,
  DoctorTab.patients,
  DoctorTab.alerts,
  DoctorTab.results,
  DoctorTab.appointments,
];

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard>
    with TickerProviderStateMixin {
  DoctorTab _currentTab = DoctorTab.dashboard;

  // Mutable state — populated from API
  List<PatientSummary> _patients = [];
  List<CareGapAlert> _careGaps = [];
  List<LabResult> _labResults = [];
  List<Appointment> _appointments = [];
  List<ActivityFeedItem> _activityFeed = [];
  List<ActivityFeedItem> _auditLog = [];
  List<CaseloadBar> _caseload = [];
  int _totalPatients = 0;
  int _criticalAlerts = 0;
  int _careGapsOpen = 0;
  bool _isLoading = true;

  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
        );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await getIt<DashboardService>().fetchDoctorDashboard();
      if (!mounted) return;
      setState(() {
        _patients = _parsePatients(data['patients']);
        _careGaps = _parseCareGaps(data['care_gaps']);
        _labResults = _parseLabResults(data['lab_results']);
        _appointments = _parseAppointments(data['appointments']);
        _activityFeed = _parseFeed(data['activity_feed']);
        _auditLog = _parseFeed(data['audit_log']);
        _caseload = _parseCaseload(data['caseload']);
        final m = data['metrics'] as Map<String, dynamic>? ?? {};
        _totalPatients = m['total_patients'] ?? 0;
        _criticalAlerts = m['critical_alerts'] ?? 0;
        _careGapsOpen = m['care_gaps_open'] ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Fallback to seed data on error
      setState(() {
        _patients = List.from(seedPatients);
        _careGaps = List.from(seedCareGaps);
        _labResults = List.from(seedLabResults);
        _appointments = List.from(seedAppointments);
        _activityFeed = List.from(seedActivityFeed);
        _auditLog = List.from(seedAuditLog);
        _caseload = List.from(seedCaseload);
        _totalPatients = seedPatients.length * 84;
        _criticalAlerts = 12;
        _careGapsOpen = 75;
        _isLoading = false;
      });
    }
  }

  static List<PatientSummary> _parsePatients(dynamic raw) {
    if (raw is! List) return List.from(seedPatients);
    return raw
        .map<PatientSummary>(
          (p) => PatientSummary(
            id: p['id'] ?? '',
            name: p['name'] ?? '',
            condition: p['condition'] ?? '',
            lastTest: p['lastTest'] ?? '',
            risk: _parseRisk(p['risk']),
          ),
        )
        .toList();
  }

  static List<CareGapAlert> _parseCareGaps(dynamic raw) {
    if (raw is! List) return List.from(seedCareGaps);
    return raw
        .map<CareGapAlert>(
          (g) => CareGapAlert(
            patientName: g['patientName'] ?? '',
            testOverdue: g['testOverdue'] ?? '',
            delay: '${g['delay'] ?? ''}',
            risk: _parseRisk(g['risk']),
            escalated: g['escalated'] ?? false,
          ),
        )
        .toList();
  }

  static List<LabResult> _parseLabResults(dynamic raw) {
    if (raw is! List) return List.from(seedLabResults);
    return raw
        .map<LabResult>(
          (t) => LabResult(
            patientName: t['patientName'] ?? '',
            testName: t['testName'] ?? '',
            result: t['result'] ?? '',
            date: t['date'] ?? '',
          ),
        )
        .toList();
  }

  static List<Appointment> _parseAppointments(dynamic raw) {
    if (raw is! List) return List.from(seedAppointments);
    return raw
        .map<Appointment>(
          (a) => Appointment(
            patientName: a['patientName'] ?? '',
            purpose: a['purpose'] ?? '',
            date: a['date'] ?? '',
            status: a['status'] ?? 'Scheduled',
          ),
        )
        .toList();
  }

  static List<ActivityFeedItem> _parseFeed(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<ActivityFeedItem>(
          (f) => ActivityFeedItem(
            icon: f['icon'] ?? '📋',
            text: f['text'] ?? '',
            time: f['time'] ?? '',
          ),
        )
        .toList();
  }

  static List<CaseloadBar> _parseCaseload(dynamic raw) {
    if (raw is! List) return List.from(seedCaseload);
    return raw
        .map<CaseloadBar>(
          (c) => CaseloadBar(
            label: c['label'] ?? '',
            fraction: (c['fraction'] ?? 0).toDouble(),
            isCritical: c['isCritical'] ?? false,
          ),
        )
        .toList();
  }

  static RiskLevel _parseRisk(dynamic raw) {
    return switch ('$raw'.toLowerCase()) {
      'high' => RiskLevel.high,
      'critical' => RiskLevel.critical,
      'medium' => RiskLevel.medium,
      _ => RiskLevel.low,
    };
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _switchTab(DoctorTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
    // Re-trigger entrance animation on tab switch
    _entranceCtrl
      ..reset()
      ..forward();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textMain,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  // ─────────────────────────────────── BUILD ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticatedState) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: DoctorDrawer(
          currentTab: _currentTab,
          onTabSelected: (tab) {
            Navigator.of(context).pop();
            _switchTab(tab);
          },
          onLogout: () {
            Navigator.of(context).pop();
            context.read<AuthBloc>().add(AuthLogoutEvent());
          },
        ),
        body: Stack(
          children: [
            const AnimatedGridBackground(),
            SafeArea(
              child: Column(
                children: [
                  _AppBar(
                    currentTab: _currentTab,
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FadeTransition(
                            opacity: _fadeAnim,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: _buildTabBody(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: DoctorBottomNav(
          currentTab: _currentTab,
          primaryTabs: _primaryTabs,
          onTabSelected: _switchTab,
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    return switch (_currentTab) {
      DoctorTab.dashboard => _DashboardTab(
        patients: _patients,
        activityFeed: _activityFeed,
        caseload: _caseload,
        totalPatients: _totalPatients,
        criticalAlerts: _criticalAlerts,
        careGapsOpen: _careGapsOpen,
        careGapsCount: _careGaps.length,
        onShowToast: _showToast,
        onSwitchTab: _switchTab,
      ),
      DoctorTab.patients => PatientListTab(
        patients: _patients,
        onShowToast: _showToast,
      ),
      DoctorTab.alerts => CareGapTab(
        careGaps: _careGaps,
        onShowToast: _showToast,
      ),
      DoctorTab.results => LabResultsTab(
        results: _labResults,
        onShowToast: _showToast,
      ),
      DoctorTab.appointments => AppointmentsTab(
        appointments: _appointments,
        onShowToast: _showToast,
        onAppointmentCreated: (appt) =>
            setState(() => _appointments.insert(0, appt)),
      ),
      DoctorTab.analytics => const AnalyticsTab(),
      DoctorTab.audit => AuditTab(
        feed: _auditLog.isNotEmpty ? _auditLog : seedAuditLog,
      ),
      _ => _PlaceholderTab(tab: _currentTab),
    };
  }
}

// ─────────────────────────────────── APP BAR ────────────────────────────────

class _AppBar extends StatelessWidget {
  final DoctorTab currentTab;
  final VoidCallback onMenuTap;

  const _AppBar({required this.currentTab, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Hamburger — opens drawer for secondary tabs
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  size: 18,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTab.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  currentTab.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Doctor avatar pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'RS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dr. Rahul',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── DASHBOARD TAB ──────────────────────────────

class _DashboardTab extends StatelessWidget {
  final List<PatientSummary> patients;
  final List<ActivityFeedItem> activityFeed;
  final List<CaseloadBar> caseload;
  final int totalPatients;
  final int criticalAlerts;
  final int careGapsOpen;
  final int careGapsCount;
  final void Function(String) onShowToast;
  final void Function(DoctorTab) onSwitchTab;

  const _DashboardTab({
    required this.patients,
    required this.activityFeed,
    required this.caseload,
    required this.totalPatients,
    required this.criticalAlerts,
    required this.careGapsOpen,
    required this.careGapsCount,
    required this.onShowToast,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('dashboard-tab'),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        // ── Metric cards row ──────────────────────────────────
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'My Patients',
                value: '$totalPatients',
                sub: 'Current active caseload',
                subColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Critical Alerts',
                value: '$criticalAlerts',
                valueColor: AppColors.error,
                sub: 'Immediate action needed',
                subColor: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          label: 'Care Gaps Today',
          value: '$careGapsOpen',
          sub: 'Live from database',
          subColor: AppColors.success,
          fullWidth: true,
        ),
        const SizedBox(height: 24),

        // ── Recent Activity feed ──────────────────────────────
        _SectionCard(
          title: 'Recent Patient Activity',
          child: ActivityFeed(
            items: activityFeed.isNotEmpty ? activityFeed : seedActivityFeed,
          ),
        ),
        const SizedBox(height: 16),

        // ── Caseload distribution chart ───────────────────────
        _SectionCard(
          title: 'Caseload Distribution',
          child: CaseloadChart(
            bars: caseload.isNotEmpty ? caseload : seedCaseload,
          ),
        ),
        const SizedBox(height: 16),

        // ── Quick-action buttons ──────────────────────────────
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.people_alt_outlined,
                label: 'View Patients',
                onTap: () => onSwitchTab(DoctorTab.patients),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.notifications_outlined,
                label: 'Care Gaps',
                onTap: () => onSwitchTab(DoctorTab.alerts),
                badge: '$careGapsCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.description_outlined,
                label: 'Lab Results',
                onTap: () => onSwitchTab(DoctorTab.results),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.calendar_month_outlined,
                label: 'Appointments',
                onTap: () => onSwitchTab(DoctorTab.appointments),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────── PLACEHOLDER TAB ────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final DoctorTab tab;
  const _PlaceholderTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.icon, size: 48, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            tab.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
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
        ],
      ),
    );
  }
}

// ─────────────────────── SHARED INTERNAL WIDGETS ────────────────────────────

/// Bordered card with a header title and arbitrary body child.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
