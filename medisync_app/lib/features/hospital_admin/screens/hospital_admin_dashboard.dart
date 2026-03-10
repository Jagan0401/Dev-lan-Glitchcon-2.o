import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/dashboard_service.dart';
import '../../auth/bloc/auth_bloc.dart';

// File-level API data cache for inner tab widgets
Map<String, dynamic> _adminApiData = {};

// ─────────────────────────────────────────
//  MediSynC Design Tokens
// ─────────────────────────────────────────
class MediColors {
  static const primary = Color(0xFF0099BB);
  static const primaryGlow = Color(0x660099BB);
  static const bg = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF121212);
  static const textMuted = Color(0xFF64748B);
  static const border = Color(0x0F000000);
  static const cardShadowColor = Color(0x0D000000);

  // Status pills
  static const pillActiveBg = Color(0xFFDCFCE7);
  static const pillActiveText = Color(0xFF166534);
  static const pillCriticalBg = Color(0xFFFEE2E2);
  static const pillCriticalText = Color(0xFF991B1B);
  static const pillMediumBg = Color(0xFFFEF3C7);
  static const pillMediumText = Color(0xFF92400E);
  static const pillDeliveredBg = Color(0xFFE0F2FE);
  static const pillDeliveredText = Color(0xFF0369A1);
}

// ─────────────────────────────────────────
//  Data Models
// ─────────────────────────────────────────
class MetricData {
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;
  const MetricData(this.label, this.value, this.sub, {this.valueColor});
}

class ActivityFeedItem {
  final String icon;
  final String text;
  final String time;
  const ActivityFeedItem(this.icon, this.text, this.time);
}

class PatientRow {
  final String id;
  final String name;
  final String disease;
  final String lastTest;
  final String risk;
  final String status;
  const PatientRow(
    this.id,
    this.name,
    this.disease,
    this.lastTest,
    this.risk,
    this.status,
  );
}

class DoctorRow {
  final String name;
  final String specialty;
  final int patients;
  const DoctorRow(this.name, this.specialty, this.patients);
}

class TechRow {
  final String name;
  final String area;
  const TechRow(this.name, this.area);
}

class CareGapRow {
  final String patient;
  final String test;
  final String delay;
  final String risk;
  const CareGapRow(this.patient, this.test, this.delay, this.risk);
}

class BookingRow {
  final String patient;
  final String test;
  final String technician;
  final String date;
  final String status;
  const BookingRow(
    this.patient,
    this.test,
    this.technician,
    this.date,
    this.status,
  );
}

class MessageRow {
  final String patient;
  final String channel;
  final String message;
  final String status;
  const MessageRow(this.patient, this.channel, this.message, this.status);
}

// ─────────────────────────────────────────
//  Nav Item Model
// ─────────────────────────────────────────
enum AdminTab {
  dashboard,
  patients,
  doctors,
  coordinators,
  technicians,
  caregap,
  outreach,
  bookings,
  analytics,
  reports,
  settings,
  audit,
}

class NavItemData {
  final AdminTab tab;
  final String label;
  final IconData icon;
  const NavItemData(this.tab, this.label, this.icon);
}

// ─────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────
class HospitalAdminDashboard extends StatefulWidget {
  const HospitalAdminDashboard({super.key});

  @override
  State<HospitalAdminDashboard> createState() => _HospitalAdminDashboardState();
}

class _HospitalAdminDashboardState extends State<HospitalAdminDashboard> {
  AdminTab _currentTab = AdminTab.dashboard;
  bool _drawerOpen = false;
  bool _isLoading = true;

  // Mutable state — populated from API
  List<DoctorRow> _doctors = [];
  List<TechRow> _technicians = [];
  List<MessageRow> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await getIt<DashboardService>()
          .fetchHospitalAdminDashboard();
      if (!mounted) return;
      _adminApiData = data;
      setState(() {
        _doctors = _parseDoctors(data['doctors']);
        _technicians = _parseTechs(data['technicians']);
        _messages = _parseMessages(data['messages']);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      _adminApiData = {};
      setState(() {
        _doctors = const [
          DoctorRow('Dr. Rahul Sharma', 'Endocrinology', 420),
          DoctorRow('Dr. Meera Iyer', 'Nephrology', 280),
          DoctorRow('Dr. Arjun Singh', 'Cardiology', 310),
          DoctorRow('Dr. Kavita Rao', 'Internal Med', 190),
          DoctorRow('Dr. Amit Verma', 'Endocrinology', 260),
        ];
        _technicians = const [
          TechRow('Arjun Patel', 'South Zone'),
          TechRow('Rahul Singh', 'North Zone'),
          TechRow('Ankit Kumar', 'East Zone'),
          TechRow('Vikas Jain', 'West Zone'),
          TechRow('Rohit Sinha', 'Central Zone'),
        ];
        _messages = const [
          MessageRow('Ravi Kumar', 'WhatsApp', 'HbA1c reminder', 'Delivered'),
          MessageRow('Meena Iyer', 'WhatsApp', 'Creatinine alert', 'Delivered'),
          MessageRow('Arjun Patel', 'SMS', 'BP Check alert', 'Sent'),
          MessageRow('Neha Sharma', 'WhatsApp', 'TSH reminder', 'Delivered'),
          MessageRow('Karthik Rao', 'WhatsApp', 'CKD alert', 'Failed'),
        ];
        _isLoading = false;
      });
    }
  }

  static List<DoctorRow> _parseDoctors(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<DoctorRow>(
          (d) => DoctorRow(
            d['name'] ?? '',
            d['specialty'] ?? '',
            (d['patients'] ?? 0) as int,
          ),
        )
        .toList();
  }

  static List<TechRow> _parseTechs(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<TechRow>((t) => TechRow(t['name'] ?? '', t['area'] ?? ''))
        .toList();
  }

  static List<MessageRow> _parseMessages(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<MessageRow>(
          (m) => MessageRow(
            m['patient'] ?? '',
            m['channel'] ?? 'WhatsApp',
            m['message'] ?? '',
            m['status'] ?? 'Sent',
          ),
        )
        .toList();
  }

  final List<NavItemData> _navItems = const [
    NavItemData(AdminTab.dashboard, 'Dashboard', Icons.grid_view_rounded),
    NavItemData(AdminTab.patients, 'Patients', Icons.people_alt_outlined),
    NavItemData(AdminTab.doctors, 'Doctors', Icons.medical_services_outlined),
    NavItemData(
      AdminTab.coordinators,
      'Care Coordinators',
      Icons.assignment_ind_outlined,
    ),
    NavItemData(
      AdminTab.technicians,
      'Lab Technicians',
      Icons.biotech_outlined,
    ),
    NavItemData(
      AdminTab.caregap,
      'Care Gap Monitor',
      Icons.warning_amber_outlined,
    ),
    NavItemData(
      AdminTab.outreach,
      'Messaging',
      Icons.chat_bubble_outline_rounded,
    ),
    NavItemData(
      AdminTab.bookings,
      'Lab Bookings',
      Icons.calendar_month_outlined,
    ),
    NavItemData(AdminTab.analytics, 'Analytics', Icons.bar_chart_rounded),
    NavItemData(AdminTab.reports, 'Reports', Icons.description_outlined),
    NavItemData(AdminTab.settings, 'Settings', Icons.tune_rounded),
    NavItemData(AdminTab.audit, 'Activity Logs', Icons.access_time_rounded),
  ];

  Map<AdminTab, Map<String, String>> get _tabTitles => {
    AdminTab.dashboard: {
      'title': 'Dashboard',
      'sub': 'Overview of Apollo Chennai activity',
    },
    AdminTab.patients: {
      'title': 'Patients',
      'sub': 'Manage hospital patient records and datasets',
    },
    AdminTab.doctors: {
      'title': 'Doctors',
      'sub': 'Manage medical staff and patient assignments',
    },
    AdminTab.coordinators: {
      'title': 'Care Coordinators',
      'sub': 'Patient engagement staff monitoring',
    },
    AdminTab.technicians: {
      'title': 'Lab Technicians',
      'sub': 'Home sample collection logistics',
    },
    AdminTab.caregap: {
      'title': 'Care Gap Monitor',
      'sub': 'Real-time tracking of overdue medical tests',
    },
    AdminTab.outreach: {
      'title': 'Messaging',
      'sub': 'Automated and manual patient communication',
    },
    AdminTab.bookings: {
      'title': 'Lab Bookings',
      'sub': 'Home collection scheduling and status',
    },
    AdminTab.analytics: {
      'title': 'Analytics',
      'sub': 'Clinical performance and outreach metrics',
    },
    AdminTab.reports: {
      'title': 'Reports',
      'sub': 'Generate and download hospital data',
    },
    AdminTab.settings: {
      'title': 'Settings',
      'sub': 'Configure hospital protocols and rules',
    },
    AdminTab.audit: {
      'title': 'Activity Logs',
      'sub': 'Audit trail of all administrative actions',
    },
  };

  void _switchTab(AdminTab tab) {
    setState(() {
      _currentTab = tab;
      _drawerOpen = false;
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        backgroundColor: MediColors.textMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _tabTitles[_currentTab]!;

    return Scaffold(
      backgroundColor: MediColors.bg,
      body: Stack(
        children: [
          // Grid background
          const _GridBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: title['title']!,
                  subtitle: title['sub']!,
                  onMenuTap: () => setState(() => _drawerOpen = !_drawerOpen),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _TabContent(
                          tab: _currentTab,
                          doctors: _doctors,
                          technicians: _technicians,
                          messages: _messages,
                          onShowToast: _showToast,
                          onDoctorAdded: (d) =>
                              setState(() => _doctors = [d, ..._doctors]),
                          onTechAreaChanged: (idx, area) => setState(() {
                            final updated = List<TechRow>.from(_technicians);
                            updated[idx] = TechRow(updated[idx].name, area);
                            _technicians = updated;
                          }),
                          onDoctorAssigned: (idx, count) => setState(() {
                            final updated = List<DoctorRow>.from(_doctors);
                            final d = updated[idx];
                            updated[idx] = DoctorRow(
                              d.name,
                              d.specialty,
                              d.patients + count,
                            );
                            _doctors = updated;
                          }),
                          onAiReminderSent: (name) => setState(() {
                            _messages = [
                              MessageRow(
                                name,
                                'WhatsApp',
                                'HbA1c Reminder',
                                'Delivered',
                              ),
                              ..._messages,
                            ];
                            _showToast('AI reminder triggered for $name');
                          }),
                        ),
                ),
              ],
            ),
          ),

          // Drawer overlay
          if (_drawerOpen) ...[
            GestureDetector(
              onTap: () => setState(() => _drawerOpen = false),
              child: Container(color: Colors.black45),
            ),
            _SideDrawer(
              navItems: _navItems,
              currentTab: _currentTab,
              onSelect: _switchTab,
              onLogout: () {
                context.read<AuthBloc>().add(AuthLogoutEvent());
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Grid Background
// ─────────────────────────────────────────
class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0099BB).withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 50.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────
//  Top App Bar
// ─────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMenuTap;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: MediColors.border, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: MediColors.border),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 18,
                color: MediColors.textMain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: MediColors.textMain,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: MediColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // User avatar pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: MediColors.border),
              boxShadow: const [
                BoxShadow(
                  color: MediColors.cardShadowColor,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      'HA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: MediColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Hospital Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: MediColors.textMain,
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

// ─────────────────────────────────────────
//  Side Drawer
// ─────────────────────────────────────────
class _SideDrawer extends StatelessWidget {
  final List<NavItemData> navItems;
  final AdminTab currentTab;
  final ValueChanged<AdminTab> onSelect;
  final VoidCallback onLogout;

  const _SideDrawer({
    required this.navItems,
    required this.currentTab,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      width: 270,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: MediColors.border)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 30,
                offset: Offset(8, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MediColors.textMain,
                          letterSpacing: -1,
                        ),
                        children: [
                          TextSpan(text: 'Medi'),
                          TextSpan(
                            text: 'SynC.',
                            style: TextStyle(color: MediColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'by DevÉlan.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: MediColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: MediColors.border, height: 1),
              const SizedBox(height: 8),

              // Nav items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  itemCount: navItems.length,
                  itemBuilder: (context, i) {
                    final item = navItems[i];
                    final isActive = item.tab == currentTab;
                    return GestureDetector(
                      onTap: () => onSelect(item.tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? MediColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActive
                              ? [
                                  const BoxShadow(
                                    color: MediColors.primaryGlow,
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 17,
                              color: isActive
                                  ? Colors.white
                                  : MediColors.textMuted,
                            ),
                            const SizedBox(width: 11),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : MediColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Footer
              const Divider(color: MediColors.border, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'DevÉlan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: MediColors.textMuted,
                      ),
                      tooltip: 'Logout',
                      onPressed: onLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Tab Content Router
// ─────────────────────────────────────────
class _TabContent extends StatelessWidget {
  final AdminTab tab;
  final List<DoctorRow> doctors;
  final List<TechRow> technicians;
  final List<MessageRow> messages;
  final void Function(String) onShowToast;
  final void Function(DoctorRow) onDoctorAdded;
  final void Function(int, String) onTechAreaChanged;
  final void Function(int, int) onDoctorAssigned;
  final void Function(String) onAiReminderSent;

  const _TabContent({
    required this.tab,
    required this.doctors,
    required this.technicians,
    required this.messages,
    required this.onShowToast,
    required this.onDoctorAdded,
    required this.onTechAreaChanged,
    required this.onDoctorAssigned,
    required this.onAiReminderSent,
  });

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      AdminTab.dashboard => const _DashboardTab(),
      AdminTab.patients => _PatientsTab(onShowToast: onShowToast),
      AdminTab.doctors => _DoctorsTab(
        doctors: doctors,
        onDoctorAdded: onDoctorAdded,
        onDoctorAssigned: onDoctorAssigned,
        onShowToast: onShowToast,
      ),
      AdminTab.coordinators => const _CoordinatorsTab(),
      AdminTab.technicians => _TechniciansTab(
        technicians: technicians,
        onAreaChanged: onTechAreaChanged,
        onShowToast: onShowToast,
      ),
      AdminTab.caregap => _CareGapTab(
        onAiReminderSent: onAiReminderSent,
        onShowToast: onShowToast,
      ),
      AdminTab.outreach => _MessagingTab(messages: messages),
      AdminTab.bookings => _BookingsTab(onShowToast: onShowToast),
      AdminTab.analytics => const _AnalyticsTab(),
      AdminTab.reports => _ReportsTab(onShowToast: onShowToast),
      AdminTab.settings => const _SettingsTab(),
      AdminTab.audit => const _AuditTab(),
    };
  }
}

// ─────────────────────────────────────────
//  Reusable Widgets
// ─────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MediColors.border),
        boxShadow: const [
          BoxShadow(
            color: MediColors.cardShadowColor,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: MediColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: data.valueColor ?? MediColors.textMain,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.sub,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const _ContentCard({required this.title, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MediColors.border),
        boxShadow: const [
          BoxShadow(
            color: MediColors.cardShadowColor,
            blurRadius: 20,
            offset: Offset(0, 6),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: MediColors.textMain,
                    letterSpacing: -0.5,
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1, color: MediColors.border),
          child,
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;

  const _StatusPill({
    required this.label,
    required this.bg,
    required this.text,
  });

  factory _StatusPill.fromRisk(String risk) {
    return switch (risk.toLowerCase()) {
      'critical' || 'failed' => _StatusPill(
        label: risk,
        bg: MediColors.pillCriticalBg,
        text: MediColors.pillCriticalText,
      ),
      'high' => _StatusPill(
        label: risk,
        bg: MediColors.pillCriticalBg,
        text: MediColors.pillCriticalText,
      ),
      'medium' => _StatusPill(
        label: risk,
        bg: MediColors.pillMediumBg,
        text: MediColors.pillMediumText,
      ),
      'active' || 'completed' || 'delivered' => _StatusPill(
        label: risk,
        bg: MediColors.pillActiveBg,
        text: MediColors.pillActiveText,
      ),
      _ => _StatusPill(
        label: risk,
        bg: const Color(0xFFF1F5F9),
        text: MediColors.textMuted,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? fontSize;
  final EdgeInsets? padding;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: MediColors.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: MediColors.primaryGlow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? borderColor;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor ?? MediColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor ?? MediColors.textMain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Dashboard Tab
// ─────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  List<MetricData> get _metrics {
    final m = _adminApiData['metrics'] as Map<String, dynamic>?;
    if (m != null && m.isNotEmpty) {
      return [
        MetricData(
          'Total Patients',
          '${m['total_patients'] ?? 0}',
          'Active in system',
        ),
        MetricData(
          'Care Gaps Today',
          '${m['care_gaps_open'] ?? 0}',
          '${m['care_gaps_closed'] ?? 0} closed',
        ),
        MetricData('Home Bookings', '${m['bookings'] ?? 0}', 'For next 24h'),
      ];
    }
    return const [
      MetricData('Total Patients', '21,530', 'Active in system'),
      MetricData('Care Gaps Today', '420', '210 closed'),
      MetricData('Home Bookings', '92', 'For next 24h'),
    ];
  }

  List<ActivityFeedItem> get _feed {
    final raw = _adminApiData['activity_feed'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<ActivityFeedItem>(
            (f) => ActivityFeedItem(
              f['icon'] ?? '📋',
              f['text'] ?? '',
              f['time'] ?? '',
            ),
          )
          .toList();
    }
    return const [
      ActivityFeedItem(
        '🤖',
        'AI sent 320 reminders for overdue HbA1c tests',
        '2 mins ago',
      ),
      ActivityFeedItem(
        '⚠️',
        'Dr. Rahul Sharma escalated CKD patient #P1002',
        '15 mins ago',
      ),
      ActivityFeedItem(
        '🏠',
        'Coordinator booked test for Ravi Kumar',
        '1 hour ago',
      ),
      ActivityFeedItem(
        '✅',
        'Lab technician completed 12 home collections',
        '2 hours ago',
      ),
      ActivityFeedItem(
        '📂',
        'New patient dataset uploaded (500 records)',
        '4 hours ago',
      ),
    ];
  }

  List<Map<String, dynamic>> get _chartBars {
    final raw = _adminApiData['disease_data'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map<Map<String, dynamic>>((d) {
        final pct = d['pct'] ?? 0;
        return {
          'label': d['label'] ?? '',
          'value': pct / 100.0,
          'pct': '$pct%',
        };
      }).toList();
    }
    return const [
      {'label': 'Diabetes', 'value': 0.9, 'pct': '45%'},
      {'label': 'Hyper', 'value': 0.6, 'pct': '30%'},
      {'label': 'CKD', 'value': 0.3, 'pct': '15%'},
      {'label': 'Thyroid', 'value': 0.2, 'pct': '10%'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics row
          Row(
            children: _metrics
                .map(
                  (m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _MetricCard(data: m),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Recent Activity
          _ContentCard(
            title: 'Recent Hospital Activity',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _feed
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  item.icon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.text,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: MediColors.textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.time,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: MediColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Disease Trends Chart
          _ContentCard(
            title: 'Disease Trends',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 130,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: (_chartBars as List<Map<String, dynamic>>)
                          .map(
                            (bar) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      bar['pct'] as String,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: MediColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: FractionallySizedBox(
                                        heightFactor: bar['value'] as double,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: MediColors.primary
                                                .withOpacity(
                                                  bar['value'] as double,
                                                ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: (_chartBars as List<Map<String, dynamic>>)
                        .map(
                          (bar) => Expanded(
                            child: Text(
                              bar['label'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: MediColors.textMuted,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Patients Tab
// ─────────────────────────────────────────
class _PatientsTab extends StatefulWidget {
  final void Function(String) onShowToast;

  const _PatientsTab({required this.onShowToast});

  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  late final List<PatientRow> _patients = () {
    final raw = _adminApiData['patients'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<PatientRow>(
            (p) => PatientRow(
              p['id'] ?? '',
              p['name'] ?? '',
              p['disease'] ?? '',
              p['lastTest'] ?? '',
              p['risk'] ?? 'Low',
              p['status'] ?? 'Active',
            ),
          )
          .toList();
    }
    return <PatientRow>[
      const PatientRow(
        'P1001',
        'Ravi Kumar',
        'Diabetes',
        '120 days ago',
        'High',
        'Active',
      ),
      const PatientRow(
        'P1002',
        'Meena Iyer',
        'CKD',
        '200 days ago',
        'Critical',
        'Active',
      ),
      const PatientRow(
        'P1003',
        'Arjun Patel',
        'Hypertension',
        '60 days ago',
        'Medium',
        'Active',
      ),
      const PatientRow(
        'P1004',
        'Neha Sharma',
        'Diabetes',
        '30 days ago',
        'Low',
        'Active',
      ),
      const PatientRow(
        'P1005',
        'Karthik Rao',
        'Hypothyroidism',
        '150 days ago',
        'High',
        'Active',
      ),
    ];
  }();

  void _showAddPatientDialog() {
    final nameCtrl = TextEditingController();
    String disease = 'Diabetes';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomModal(
        title: 'Add New Patient',
        onConfirm: (context) {
          if (nameCtrl.text.isNotEmpty) {
            setState(() {
              _patients.insert(
                0,
                PatientRow(
                  'P${1000 + _patients.length + 1}',
                  nameCtrl.text,
                  disease,
                  'New',
                  'Low',
                  'Active',
                ),
              );
            });
            Navigator.pop(context);
            widget.onShowToast('Patient ${nameCtrl.text} onboarded.');
          }
        },
        confirmLabel: 'Save Patient',
        child: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            children: [
              _ModalField(
                controller: nameCtrl,
                label: 'Full Name',
                hint: 'e.g. John Doe',
              ),
              const SizedBox(height: 12),
              _ModalDropdown(
                label: 'Disease Type',
                value: disease,
                items: const [
                  'Diabetes',
                  'Hypertension',
                  'CKD',
                  'Hypothyroidism',
                ],
                onChanged: (v) => setSt(() => disease = v!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientDetail(PatientRow p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomModal(
        title: p.name,
        onConfirm: (ctx) => Navigator.pop(ctx),
        confirmLabel: 'Close Profile',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'Clinical Data',
                    items: {'ID': p.id, 'Disease': p.disease, 'Risk': p.risk},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    label: 'Engagement',
                    items: {
                      'Last Contact': '2 days ago',
                      'Channel': 'WhatsApp',
                      'Response': 'High',
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MediColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Test History',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: MediColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 12-Feb-2026: HbA1c result 9.5 (High)',
                    style: TextStyle(fontSize: 11, color: MediColors.textMuted),
                  ),
                  const Text(
                    '• 10-Nov-2025: BP checked 140/90',
                    style: TextStyle(fontSize: 11, color: MediColors.textMuted),
                  ),
                  const Text(
                    '• 05-Sep-2025: Lipid Profile completed',
                    style: TextStyle(fontSize: 11, color: MediColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Patient Records',
        action: Row(
          children: [
            _ActionButton(
              label: 'Import',
              onTap: () => widget.onShowToast('Dataset processing started...'),
            ),
            const SizedBox(width: 8),
            _PrimaryButton(
              label: '+ Add Patient',
              onTap: _showAddPatientDialog,
            ),
          ],
        ),
        child: Column(
          children: _patients
              .map(
                (p) => _PatientListItem(patient: p, onView: _showPatientDetail),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _PatientListItem extends StatelessWidget {
  final PatientRow patient;
  final ValueChanged<PatientRow> onView;

  const _PatientListItem({required this.patient, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MediColors.border)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                patient.name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: MediColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MediColors.textMain,
                  ),
                ),
                Text(
                  '${patient.disease} · ${patient.id}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: MediColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusPill.fromRisk(patient.risk),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => onView(patient),
                child: const Text(
                  'View →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: MediColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Doctors Tab
// ─────────────────────────────────────────
class _DoctorsTab extends StatelessWidget {
  final List<DoctorRow> doctors;
  final void Function(DoctorRow) onDoctorAdded;
  final void Function(int, int) onDoctorAssigned;
  final void Function(String) onShowToast;

  const _DoctorsTab({
    required this.doctors,
    required this.onDoctorAdded,
    required this.onDoctorAssigned,
    required this.onShowToast,
  });

  void _showAddDoctorDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomModal(
        title: 'Add Medical Professional',
        onConfirm: (ctx) {
          if (nameCtrl.text.isNotEmpty && specCtrl.text.isNotEmpty) {
            onDoctorAdded(DoctorRow(nameCtrl.text, specCtrl.text, 0));
            Navigator.pop(ctx);
            onShowToast('Doctor profile created for ${nameCtrl.text}');
          }
        },
        confirmLabel: 'Create Account',
        child: Column(
          children: [
            _ModalField(
              controller: nameCtrl,
              label: 'Doctor Name',
              hint: 'Dr. Firstname Lastname',
            ),
            const SizedBox(height: 12),
            _ModalField(
              controller: specCtrl,
              label: 'Specialization',
              hint: 'e.g. Cardiology',
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, int idx, DoctorRow doc) {
    final countCtrl = TextEditingController(text: '10');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomModal(
        title: 'Assign to ${doc.name}',
        onConfirm: (ctx) {
          final count = int.tryParse(countCtrl.text) ?? 0;
          if (count > 0) {
            onDoctorAssigned(idx, count);
            Navigator.pop(ctx);
            onShowToast('Assignment completed for ${doc.name}');
          }
        },
        confirmLabel: 'Confirm Assignment',
        child: _ModalField(
          controller: countCtrl,
          label: 'Number of Patients to Assign',
          hint: 'e.g. 15',
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Medical Staff',
        action: _PrimaryButton(
          label: '+ Add Doctor',
          onTap: () => _showAddDoctorDialog(context),
        ),
        child: Column(
          children: List.generate(doctors.length, (i) {
            final doc = doctors[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i < doctors.length - 1
                        ? MediColors.border
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: MediColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: MediColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MediColors.textMain,
                          ),
                        ),
                        Text(
                          '${doc.specialty} · ${doc.patients} patients',
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const _StatusPill(
                        label: 'Active',
                        bg: MediColors.pillActiveBg,
                        text: MediColors.pillActiveText,
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Assign',
                        onTap: () => _showAssignDialog(context, i, doc),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Coordinators Tab
// ─────────────────────────────────────────
class _CoordinatorsTab extends StatelessWidget {
  const _CoordinatorsTab();

  static const _coords = [
    ['Kavya Nair', '820'],
    ['Ankit Sharma', '640'],
    ['Priya Patel', '710'],
    ['Rohit Mehta', '520'],
    ['Sneha Kapoor', '430'],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Care Coordinators',
        child: Column(
          children: List.generate(_coords.length, (i) {
            final c = _coords[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i < _coords.length - 1
                        ? MediColors.border
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c[0],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MediColors.textMain,
                          ),
                        ),
                        Text(
                          '${c[1]} assigned patients',
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _StatusPill(
                    label: 'Active',
                    bg: MediColors.pillActiveBg,
                    text: MediColors.pillActiveText,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Technicians Tab
// ─────────────────────────────────────────
class _TechniciansTab extends StatelessWidget {
  final List<TechRow> technicians;
  final void Function(int, String) onAreaChanged;
  final void Function(String) onShowToast;

  const _TechniciansTab({
    required this.technicians,
    required this.onAreaChanged,
    required this.onShowToast,
  });

  void _showAreaDialog(BuildContext context, int idx, TechRow tech) {
    final areaCtrl = TextEditingController(text: tech.area);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomModal(
        title: 'Update ${tech.name}',
        onConfirm: (ctx) {
          if (areaCtrl.text.isNotEmpty) {
            onAreaChanged(idx, areaCtrl.text);
            Navigator.pop(ctx);
            onShowToast('Coverage area updated to ${areaCtrl.text}');
          }
        },
        confirmLabel: 'Update Region',
        child: _ModalField(
          controller: areaCtrl,
          label: 'New Assigned Zone',
          hint: 'e.g. Northeast Region',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Lab Technicians (Home Collection)',
        child: Column(
          children: List.generate(technicians.length, (i) {
            final t = technicians[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i < technicians.length - 1
                        ? MediColors.border
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MediColors.textMain,
                          ),
                        ),
                        Text(
                          t.area,
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const _StatusPill(
                        label: 'Active',
                        bg: MediColors.pillActiveBg,
                        text: MediColors.pillActiveText,
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Change Area',
                        onTap: () => _showAreaDialog(context, i, t),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Care Gap Tab
// ─────────────────────────────────────────
class _CareGapTab extends StatelessWidget {
  final void Function(String) onAiReminderSent;
  final void Function(String) onShowToast;

  const _CareGapTab({
    required this.onAiReminderSent,
    required this.onShowToast,
  });

  static List<CareGapRow> get _gaps {
    final raw = _adminApiData['care_gaps'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<CareGapRow>(
            (g) => CareGapRow(
              g['patient'] ?? '',
              g['test'] ?? '',
              '${g['delay'] ?? ''}',
              g['risk'] ?? 'Low',
            ),
          )
          .toList();
    }
    return const [
      CareGapRow('Ravi Kumar', 'HbA1c', '120 days', 'High'),
      CareGapRow('Meena Iyer', 'Creatinine', '200 days', 'Critical'),
      CareGapRow('Arjun Patel', 'BP Check', '95 days', 'Medium'),
      CareGapRow('Neha Sharma', 'Lipid Profile', '30 days', 'Low'),
      CareGapRow('Karthik Rao', 'TSH', '150 days', 'High'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Open Care Gaps',
        child: Column(
          children: List.generate(_gaps.length, (i) {
            final g = _gaps[i];
            final isLast = i == _gaps.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : MediColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.patient,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MediColors.textMain,
                          ),
                        ),
                        Text(
                          '${g.test} · Overdue ${g.delay}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusPill.fromRisk(g.risk),
                      const SizedBox(height: 6),
                      if (g.risk == 'Critical')
                        _ActionButton(
                          label: 'Escalate',
                          onTap: () => onShowToast(
                            'Patient ${g.patient} escalated to Physician.',
                          ),
                          textColor: Colors.red,
                          borderColor: Colors.red,
                        )
                      else if (g.risk == 'Low')
                        _ActionButton(
                          label: 'Schedule',
                          onTap: () =>
                              onShowToast('Scheduling sequence initiated...'),
                        )
                      else
                        _PrimaryButton(
                          label: 'AI Reminder',
                          onTap: () => onAiReminderSent(g.patient),
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Messaging Tab
// ─────────────────────────────────────────
class _MessagingTab extends StatelessWidget {
  final List<MessageRow> messages;
  const _MessagingTab({required this.messages});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Messaging History',
        child: Column(
          children: List.generate(messages.length, (i) {
            final m = messages[i];
            final isLast = i == messages.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : MediColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.patient,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MediColors.textMain,
                          ),
                        ),
                        Text(
                          '${m.channel} · ${m.message}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill.fromRisk(m.status),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Bookings Tab
// ─────────────────────────────────────────
class _BookingsTab extends StatefulWidget {
  final void Function(String) onShowToast;
  const _BookingsTab({required this.onShowToast});

  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  late List<BookingRow> _bookings = () {
    final raw = _adminApiData['bookings'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<BookingRow>(
            (b) => BookingRow(
              b['patient'] ?? '',
              b['test'] ?? '',
              b['technician'] ?? '',
              b['date'] ?? '',
              b['status'] ?? 'Scheduled',
            ),
          )
          .toList();
    }
    return <BookingRow>[
      const BookingRow(
        'Ravi Kumar',
        'HbA1c',
        'Arjun Patel',
        'Mar 12',
        'Scheduled',
      ),
      const BookingRow(
        'Meena Iyer',
        'Creatinine',
        'Rahul Singh',
        'Mar 11',
        'Completed',
      ),
      const BookingRow(
        'Arjun Patel',
        'BP Check',
        'Kavya Nair',
        'Mar 10',
        'Completed',
      ),
      const BookingRow(
        'Neha Sharma',
        'TSH',
        'Ankit Kumar',
        'Mar 14',
        'Scheduled',
      ),
      const BookingRow(
        'Karthik Rao',
        'Creatinine',
        'Arjun Patel',
        'Mar 13',
        'Scheduled',
      ),
    ];
  }();

  void _showCreateBooking() {
    final patCtrl = TextEditingController();
    final testCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomModal(
        title: 'Schedule Sample Collection',
        onConfirm: (ctx) {
          if (patCtrl.text.isNotEmpty) {
            setState(() {
              _bookings = [
                BookingRow(
                  patCtrl.text,
                  testCtrl.text,
                  'Pending',
                  'TBD',
                  'Scheduled',
                ),
                ..._bookings,
              ];
            });
            Navigator.pop(ctx);
            widget.onShowToast('Lab collection booked for ${patCtrl.text}');
          }
        },
        confirmLabel: 'Book Slot',
        child: Column(
          children: [
            _ModalField(
              controller: patCtrl,
              label: 'Patient Name',
              hint: 'Name',
            ),
            const SizedBox(height: 12),
            _ModalField(
              controller: testCtrl,
              label: 'Test Type',
              hint: 'e.g. HbA1c',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Sample Collection Bookings',
        action: _PrimaryButton(
          label: '+ Create Booking',
          onTap: _showCreateBooking,
        ),
        child: Column(
          children: List.generate(_bookings.length, (i) {
            final b = _bookings[i];
            final isLast = i == _bookings.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : MediColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.patient,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MediColors.textMain,
                          ),
                        ),
                        Text(
                          '${b.test} · ${b.technician} · ${b.date}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill.fromRisk(b.status),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Analytics Tab
// ─────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  static const _metrics = [
    MetricData('Outreach Success', '62%', 'Conversion rate'),
    MetricData('Gap Closure', '38%', 'Of open gaps'),
    MetricData('Patient Retention', '94%', 'This quarter'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: _metrics
                .map(
                  (m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _MetricCard(data: m),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Reports Tab
// ─────────────────────────────────────────
class _ReportsTab extends StatelessWidget {
  final void Function(String) onShowToast;
  const _ReportsTab({required this.onShowToast});

  static const _reports = [
    ['Care Gap Report', 'Patient risk analysis data.'],
    ['Lab Analytics', 'Home collection performance.'],
    ['Outreach Success', 'AI messaging conversion metrics.'],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Generate Hospital Reports',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: _reports
                .map(
                  (r) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: MediColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: MediColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r[0],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: MediColors.textMain,
                                ),
                              ),
                              Text(
                                r[1],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: MediColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _PrimaryButton(
                          label: 'Generate',
                          onTap: () =>
                              onShowToast('Generating ${r[0]} report...'),
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Settings Tab
// ─────────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  static List<List<String>> get _protocols {
    final raw = _adminApiData['protocols'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<List<String>>((p) => [p['name'] ?? '', p['status'] ?? ''])
          .toList();
    }
    return const [
      ['Diabetes', 'HbA1c', '90 days'],
      ['CKD', 'Creatinine', '180 days'],
      ['Hypothyroidism', 'TSH', '180 days'],
      ['Hypertension', 'BP', '90 days'],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Hospital Care Protocols',
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFFAFAFA),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Disease',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: MediColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Test',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: MediColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: MediColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: MediColors.border),
            ...List.generate(_protocols.length, (i) {
              final p = _protocols[i];
              final isLast = i == _protocols.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isLast ? Colors.transparent : MediColors.border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p[0],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p[1],
                        style: const TextStyle(
                          fontSize: 12,
                          color: MediColors.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p[2],
                        style: const TextStyle(
                          fontSize: 12,
                          color: MediColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Audit Tab
// ─────────────────────────────────────────
class _AuditTab extends StatelessWidget {
  const _AuditTab();

  static List<List<String>> get _logs {
    final raw = _adminApiData['audit_log'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<List<String>>(
            (a) => [a['actor'] ?? '', a['action'] ?? '', a['time'] ?? ''],
          )
          .toList();
    }
    return const [
      ['Admin', 'Added doctor Dr. Rahul Sharma', 'Today'],
      ['Coordinator', 'Booked home test #B4920', 'Today'],
      ['Doctor', 'Escalated CKD patient #P1002', 'Today'],
      ['AI Engine', 'Sent 320 automated reminders', 'Today'],
      ['Admin', 'Uploaded dataset (Apollo_Mar_09.csv)', 'Yesterday'],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _ContentCard(
        title: 'Activity Trail',
        child: Column(
          children: List.generate(_logs.length, (i) {
            final l = _logs[i];
            final isLast = i == _logs.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : MediColors.border,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5, right: 10),
                    decoration: BoxDecoration(
                      color: MediColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l[1],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: MediColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l[0]} · ${l[2]}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: MediColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Shared Modal Widgets
// ─────────────────────────────────────────
class _BottomModal extends StatelessWidget {
  final String title;
  final Widget child;
  final void Function(BuildContext) onConfirm;
  final String confirmLabel;

  const _BottomModal({
    required this.title,
    required this.child,
    required this.onConfirm,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MediColors.textMain,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onConfirm(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: MediColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: MediColors.primaryGlow,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MediColors.border),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MediColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _ModalField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: MediColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: MediColors.textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: MediColors.textMuted,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: MediColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: MediColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: MediColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModalDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModalDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: MediColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: MediColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: MediColors.textMain),
              onChanged: onChanged,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final Map<String, String> items;

  const _InfoBox({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MediColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: MediColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...items.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: MediColors.textMuted,
                  ),
                  children: [
                    TextSpan(
                      text: '${e.key}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: MediColors.textMain,
                      ),
                    ),
                    TextSpan(text: e.value),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
