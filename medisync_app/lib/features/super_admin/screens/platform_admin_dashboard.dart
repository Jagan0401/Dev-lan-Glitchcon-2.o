import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/dashboard_service.dart';
import '../../auth/bloc/auth_bloc.dart';

// File-level API data cache for inner tab widgets
Map<String, dynamic> _superApiData = {};

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (mirrors hospitaladmin — single source of truth per project)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF0099BB);
  static const primaryGlow = Color(0x660099BB);
  static const bg = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF121212);
  static const textMuted = Color(0xFF64748B);
  static const border = Color(0x0F000000);
  static const shadow = Color(0x0D000000);

  // Status / plan pills
  static const activeBg = Color(0xFFDCFCE7);
  static const activeText = Color(0xFF166534);
  static const suspendedBg = Color(0xFFFEE2E2);
  static const suspendedText = Color(0xFF991B1B);
  static const proBg = Color(0xFFE0F2FE);
  static const proText = Color(0xFF0369A1);
  static const entBg = Color(0xFFF3E8FF);
  static const entText = Color(0xFF6B21A8);
  static const neutralBg = Color(0xFFF1F5F9);
  static const neutralText = textMuted;

  // Terminal (AI block)
  static const terminalBg = Color(0xFF0F172A);
  static const terminalBlue = Color(0xFF38BDF8);
  static const terminalGray = Color(0xFF64748B);
  static const terminalWhite = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ENUMS / NAV MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum _Tab {
  dashboard,
  tenants,
  users,
  patients,
  ai,
  messaging,
  bookings,
  analytics,
  system,
  billing,
  settings,
  audit,
}

class _NavItem {
  final _Tab tab;
  final String label;
  final IconData icon;
  const _NavItem(this.tab, this.label, this.icon);
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _Metric {
  final String label;
  final String value;
  final String sub;
  const _Metric(this.label, this.value, this.sub);
}

class _FeedItem {
  final String emoji;
  final String text;
  final String time;
  const _FeedItem(this.emoji, this.text, this.time);
}

class _SysStatus {
  final String service;
  final String status;
  const _SysStatus(this.service, this.status);
}

class _Tenant {
  final String name;
  final String tenantId;
  final String plan; // 'Enterprise' | 'Pro' | 'Starter'
  final String patients;
  final int doctors;
  final String status; // 'Active' | 'Suspended'
  const _Tenant(
    this.name,
    this.tenantId,
    this.plan,
    this.patients,
    this.doctors,
    this.status,
  );
}

class _User {
  final String name;
  final String role;
  final String hospital;
  final String lastLogin;
  const _User(this.name, this.role, this.hospital, this.lastLogin);
}

class _GlobalPatient {
  final String id;
  final String hospital;
  final String disease;
  final String lastTest;
  final String risk;
  final String gap;
  const _GlobalPatient(
    this.id,
    this.hospital,
    this.disease,
    this.lastTest,
    this.risk,
    this.gap,
  );
}

class _Upload {
  final String hospital;
  final String file;
  final String records;
  final String date;
  const _Upload(this.hospital, this.file, this.records, this.date);
}

class _AiDecision {
  final String patient;
  final String hospital;
  final String risk;
  final String action;
  const _AiDecision(this.patient, this.hospital, this.risk, this.action);
}

class _MsgRow {
  final String patient;
  final String hospital;
  final String channel;
  final String status;
  const _MsgRow(this.patient, this.hospital, this.channel, this.status);
}

class _BookingRow {
  final String patient;
  final String test;
  final String tech;
  final String status;
  const _BookingRow(this.patient, this.test, this.tech, this.status);
}

class _ServiceRow {
  final String service;
  final String status;
  final String ms;
  const _ServiceRow(this.service, this.status, this.ms);
}

class _ErrorRow {
  final String error;
  final String module;
  final String time;
  final String status;
  const _ErrorRow(this.error, this.module, this.time, this.status);
}

class _BillingRow {
  final String hospital;
  final String plan;
  final String limit;
  final String status;
  const _BillingRow(this.hospital, this.plan, this.limit, this.status);
}

class _AuditRow {
  final String user;
  final String action;
  final String hospital;
  final String time;
  const _AuditRow(this.user, this.action, this.hospital, this.time);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class PlatformAdminDashboard extends StatefulWidget {
  const PlatformAdminDashboard({super.key});

  @override
  State<PlatformAdminDashboard> createState() => _PlatformAdminDashboardState();
}

class _PlatformAdminDashboardState extends State<PlatformAdminDashboard> {
  _Tab _tab = _Tab.dashboard;
  bool _drawerOpen = false;
  bool _isLoading = true;

  // ── mutable state — populated from API ─────────────────────────────────────
  List<_Tenant> _tenants = [];
  List<_User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await getIt<DashboardService>().fetchSuperAdminDashboard();
      if (!mounted) return;
      _superApiData = data;
      setState(() {
        _tenants = _parseTenants(data['tenants']);
        _users = _parseUsers(data['users']);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      _superApiData = {};
      setState(() {
        _tenants = const [
          _Tenant(
            'Apollo Chennai',
            'apollo_ch',
            'Enterprise',
            '35,200',
            120,
            'Active',
          ),
          _Tenant(
            'Fortis Bangalore',
            'fortis_blr',
            'Pro',
            '21,500',
            82,
            'Active',
          ),
          _Tenant(
            'GlobalCare Delhi',
            'global_del',
            'Starter',
            '4,800',
            25,
            'Active',
          ),
          _Tenant(
            'MedLife Hyderabad',
            'medlife_hyd',
            'Pro',
            '17,200',
            60,
            'Suspended',
          ),
          _Tenant(
            'HealthFirst Pune',
            'health_pune',
            'Starter',
            '3,900',
            18,
            'Active',
          ),
        ];
        _users = const [
          _User('Dr. Meera Iyer', 'Hospital Admin', 'Apollo Chennai', 'Today'),
          _User('Dr. Rahul Sharma', 'Doctor', 'Fortis Bangalore', 'Today'),
          _User(
            'Kavya Nair',
            'Care Coordinator',
            'Apollo Chennai',
            'Yesterday',
          ),
          _User('Arjun Patel', 'Lab Technician', 'GlobalCare Delhi', 'Today'),
          _User('Amit Verma', 'Platform Admin', 'MediSynC', 'Today'),
        ];
        _isLoading = false;
      });
    }
  }

  static List<_Tenant> _parseTenants(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<_Tenant>(
          (t) => _Tenant(
            t['name'] ?? '',
            t['tenantId'] ?? '',
            t['plan'] ?? 'Starter',
            '${t['patients'] ?? 0}',
            (t['doctors'] ?? 0) as int,
            t['status'] ?? 'Active',
          ),
        )
        .toList();
  }

  static List<_User> _parseUsers(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<_User>(
          (u) => _User(
            u['name'] ?? '',
            u['role'] ?? '',
            u['hospital'] ?? '',
            u['lastLogin'] ?? '',
          ),
        )
        .toList();
  }

  // ── nav items ──────────────────────────────────────────────────────────────
  static const _navItems = [
    _NavItem(_Tab.dashboard, 'Dashboard', Icons.grid_view_rounded),
    _NavItem(_Tab.tenants, 'Tenants', Icons.store_mall_directory_outlined),
    _NavItem(_Tab.users, 'Users & Roles', Icons.people_alt_outlined),
    _NavItem(_Tab.patients, 'Patient Data', Icons.monitor_heart_outlined),
    _NavItem(_Tab.ai, 'AI Activity', Icons.auto_awesome_outlined),
    _NavItem(_Tab.messaging, 'Messaging', Icons.chat_bubble_outline_rounded),
    _NavItem(_Tab.bookings, 'Lab Bookings', Icons.calendar_month_outlined),
    _NavItem(_Tab.analytics, 'Analytics', Icons.bar_chart_rounded),
    _NavItem(_Tab.system, 'System Monitor', Icons.shield_outlined),
    _NavItem(_Tab.billing, 'Billing', Icons.credit_card_outlined),
    _NavItem(_Tab.settings, 'Settings', Icons.tune_rounded),
    _NavItem(_Tab.audit, 'Audit Logs', Icons.access_time_rounded),
  ];

  static const _tabMeta = {
    _Tab.dashboard: (
      'Dashboard',
      'Global platform overview for MediSynC ecosystem',
    ),
    _Tab.tenants: ('Tenants', 'Manage and onboard medical institutions'),
    _Tab.users: ('Users & Roles', 'Manage access across the entire platform'),
    _Tab.patients: (
      'Patient Monitor',
      'Observe patient data activity and uploads',
    ),
    _Tab.ai: (
      'AI Activity',
      'Monitoring decision-making and engine performance',
    ),
    _Tab.messaging: ('Messaging', 'WhatsApp and SMS outreach monitoring'),
    _Tab.bookings: (
      'Lab Operations',
      'Home collection and test booking status',
    ),
    _Tab.analytics: (
      'Analytics',
      'Deep insights into disease and risk distribution',
    ),
    _Tab.system: ('System Monitor', 'Infrastructure health and error logging'),
    _Tab.billing: (
      'Billing & Subs',
      'Manage SaaS plans and hospital subscriptions',
    ),
    _Tab.settings: (
      'Global Settings',
      'Configure protocols and platform rules',
    ),
    _Tab.audit: ('Audit Logs', 'Complete traceability of system actions'),
  };

  // ── helpers ────────────────────────────────────────────────────────────────
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        backgroundColor: _C.textMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final meta = _tabMeta[_tab]!;

    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // subtle grid bg
          const Positioned.fill(child: _GridBg()),

          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: meta.$1,
                  subtitle: meta.$2,
                  onMenu: () => setState(() => _drawerOpen = !_drawerOpen),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _Body(
                          tab: _tab,
                          tenants: _tenants,
                          users: _users,
                          onToast: _toast,
                          onTenantAdded: (t) =>
                              setState(() => _tenants = [t, ..._tenants]),
                          onUserAdded: (u) =>
                              setState(() => _users = [u, ..._users]),
                          onTenantStatusToggle: (idx) => setState(() {
                            final list = List<_Tenant>.from(_tenants);
                            final t = list[idx];
                            list[idx] = _Tenant(
                              t.name,
                              t.tenantId,
                              t.plan,
                              t.patients,
                              t.doctors,
                              t.status == 'Active' ? 'Suspended' : 'Active',
                            );
                            _tenants = list;
                          }),
                        ),
                ),
              ],
            ),
          ),

          // drawer
          if (_drawerOpen) ...[
            GestureDetector(
              onTap: () => setState(() => _drawerOpen = false),
              child: Container(color: Colors.black45),
            ),
            _Drawer(
              items: _navItems,
              current: _tab,
              onSelect: (t) => setState(() {
                _tab = t;
                _drawerOpen = false;
              }),
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

// ─────────────────────────────────────────────────────────────────────────────
//  GRID BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class _GridBg extends StatelessWidget {
  const _GridBg();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF0099BB).withOpacity(0.03)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMenu;
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          // hamburger
          GestureDetector(
            onTap: onMenu,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: _C.border),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 18,
                color: _C.textMain,
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
                    color: _C.textMain,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // user pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: _C.border),
              boxShadow: const [
                BoxShadow(
                  color: _C.shadow,
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
                    color: _C.neutralBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      'SA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _C.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _C.textMain,
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

// ─────────────────────────────────────────────────────────────────────────────
//  SIDE DRAWER
// ─────────────────────────────────────────────────────────────────────────────
class _Drawer extends StatelessWidget {
  final List<_NavItem> items;
  final _Tab current;
  final ValueChanged<_Tab> onSelect;
  final VoidCallback onLogout;
  const _Drawer({
    required this.items,
    required this.current,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      width: 272,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: _C.border)),
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
              // logo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _C.textMain,
                          letterSpacing: -1,
                        ),
                        children: [
                          TextSpan(text: 'Medi'),
                          TextSpan(
                            text: 'SynC.',
                            style: TextStyle(color: _C.primary),
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
                        color: _C.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: _C.border, height: 1),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final active = item.tab == current;
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
                          color: active ? _C.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: active
                              ? [
                                  const BoxShadow(
                                    color: _C.primaryGlow,
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
                              color: active ? Colors.white : _C.textMuted,
                            ),
                            const SizedBox(width: 11),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : _C.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: _C.border, height: 1),
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
                        color: _C.textMuted,
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

// ─────────────────────────────────────────────────────────────────────────────
//  BODY ROUTER
// ─────────────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final _Tab tab;
  final List<_Tenant> tenants;
  final List<_User> users;
  final void Function(String) onToast;
  final void Function(_Tenant) onTenantAdded;
  final void Function(_User) onUserAdded;
  final void Function(int) onTenantStatusToggle;

  const _Body({
    required this.tab,
    required this.tenants,
    required this.users,
    required this.onToast,
    required this.onTenantAdded,
    required this.onUserAdded,
    required this.onTenantStatusToggle,
  });

  @override
  Widget build(BuildContext context) => switch (tab) {
    _Tab.dashboard => const _DashboardTab(),
    _Tab.tenants => _TenantsTab(
      tenants: tenants,
      onAdded: onTenantAdded,
      onToggle: onTenantStatusToggle,
      onToast: onToast,
    ),
    _Tab.users => _UsersTab(
      users: users,
      onAdded: onUserAdded,
      onToast: onToast,
    ),
    _Tab.patients => const _PatientDataTab(),
    _Tab.ai => const _AiTab(),
    _Tab.messaging => const _MessagingTab(),
    _Tab.bookings => const _BookingsTab(),
    _Tab.analytics => const _AnalyticsTab(),
    _Tab.system => const _SystemTab(),
    _Tab.billing => const _BillingTab(),
    _Tab.settings => const _SettingsTab(),
    _Tab.audit => const _AuditTab(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED WIDGET LIBRARY
// ─────────────────────────────────────────────────────────────────────────────

/// Card with optional header action button
class _Card extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;
  const _Card({required this.title, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 20, offset: Offset(0, 6)),
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1, color: _C.border),
          child,
        ],
      ),
    );
  }
}

/// Compact metric tile — 2-per-row on mobile
class _MetricTile extends StatelessWidget {
  final _Metric m;
  const _MetricTile(this.m);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _C.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            m.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: _C.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            m.sub,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2-column responsive metric grid
class _MetricGrid extends StatelessWidget {
  final List<_Metric> metrics;
  const _MetricGrid(this.metrics);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: metrics.length,
      itemBuilder: (_, i) => _MetricTile(metrics[i]),
    );
  }
}

/// Pill badge — supports all plan/status variants
class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Pill({required this.label, required this.bg, required this.fg});

  factory _Pill.status(String s) => switch (s.toLowerCase()) {
    'active' ||
    'completed' ||
    'delivered' ||
    'resolved' ||
    'online' ||
    'healthy' ||
    'connected' ||
    'running' => _Pill(label: s, bg: _C.activeBg, fg: _C.activeText),
    'suspended' ||
    'failed' ||
    'pending' => _Pill(label: s, bg: _C.suspendedBg, fg: _C.suspendedText),
    'enterprise' => _Pill(label: s, bg: _C.entBg, fg: _C.entText),
    'pro' => _Pill(label: s, bg: _C.proBg, fg: _C.proText),
    'high' => _Pill(label: s, bg: _C.suspendedBg, fg: _C.suspendedText),
    'medium' => _Pill(
      label: s,
      bg: const Color(0xFFFEF3C7),
      fg: const Color(0xFF92400E),
    ),
    _ => _Pill(label: s, bg: _C.neutralBg, fg: _C.neutralText),
  };

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
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

/// Primary CTA button
class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _C.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: _C.primaryGlow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Secondary outline button
class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? borderColor;
  const _OutlineBtn({
    required this.label,
    required this.onTap,
    this.labelColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor ?? _C.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: labelColor ?? _C.textMain,
          ),
        ),
      ),
    );
  }
}

/// Feed item row (emoji + text + time)
class _FeedRow extends StatelessWidget {
  final _FeedItem item;
  final bool isLast;
  const _FeedRow(this.item, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isLast ? Colors.transparent : _C.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.neutralBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 14)),
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
                    color: _C.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 10, color: _C.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List tile used by most tabs
class _ListRow extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? trailing;
  final bool isLast;
  const _ListRow({
    required this.leading,
    required this.title,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isLast ? Colors.transparent : _C.border),
        ),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(child: title),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Generic avatar circle
class _Avatar extends StatelessWidget {
  final String initials;
  final Color? bg;
  final Color? fg;
  const _Avatar(this.initials, {this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg ?? _C.neutralBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _C.primary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM MODAL SHELL
// ─────────────────────────────────────────────────────────────────────────────
class _Modal extends StatelessWidget {
  final String title;
  final Widget body;
  final String confirmLabel;
  final void Function(BuildContext) onConfirm;
  const _Modal({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
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
          // handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
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
              color: _C.textMain,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          body,
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onConfirm(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: _C.primaryGlow,
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
                    border: Border.all(color: _C.border),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textMuted,
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
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
            color: _C.textMain,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: _C.textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _C.textMuted, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({
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
            color: _C.textMain,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _C.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: _C.textMain),
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

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  List<_Metric> get _metrics {
    final m = _superApiData['metrics'] as Map<String, dynamic>?;
    if (m != null && m.isNotEmpty) {
      return [
        _Metric(
          'Total Hospitals',
          '${m['total_hospitals'] ?? 0}',
          '${m['active_hospitals'] ?? 0} currently active',
        ),
        _Metric(
          'Patients Monitored',
          '${m['total_patients'] ?? 0}',
          'Live from database',
        ),
        _Metric(
          'Care Gaps Today',
          '${m['care_gaps_open'] ?? 0}',
          '${m['care_gaps_closed'] ?? 0} closed successfully',
        ),
        _Metric(
          'Daily Messages',
          '${m['total_messages'] ?? 0}',
          '${m['delivery_rate'] ?? 0}% delivery rate',
        ),
      ];
    }
    return const [
      _Metric('Total Hospitals', '5', '4 currently active'),
      _Metric('Patients Monitored', '92,340', '↑ 8% from last month'),
      _Metric('Care Gaps Today', '1,320', '860 closed successfully'),
      _Metric('Daily Messages', '3,240', '98.2% delivery rate'),
    ];
  }

  List<_FeedItem> get _feed {
    final raw = _superApiData['activity_feed'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_FeedItem>(
            (f) =>
                _FeedItem(f['emoji'] ?? '📋', f['text'] ?? '', f['time'] ?? ''),
          )
          .toList();
    }
    return const [
      _FeedItem(
        '📂',
        'Apollo Chennai uploaded 20,000 patient records',
        '2 mins ago',
      ),
      _FeedItem(
        '🤖',
        'AI sent 1,120 automated outreach messages',
        '12 mins ago',
      ),
      _FeedItem('✅', 'Fortis Bangalore closed 48 care gaps', '45 mins ago'),
      _FeedItem(
        '🏠',
        'Coordinator booked home test for Ravi Kumar',
        '1 hour ago',
      ),
      _FeedItem(
        '⚠️',
        'Doctor escalated critical CKD patient in GlobalCare',
        '2 hours ago',
      ),
    ];
  }

  List<_SysStatus> get _infra {
    final raw = _superApiData['infra'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_SysStatus>(
            (s) => _SysStatus(s['service'] ?? '', s['status'] ?? ''),
          )
          .toList();
    }
    return const [
      _SysStatus('Backend API', 'Online'),
      _SysStatus('MongoDB Database', 'Healthy'),
      _SysStatus('AI Engine', 'Running'),
      _SysStatus('Twilio Messaging', 'Connected'),
      _SysStatus('Scheduler Service', 'Active'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 2-column metrics grid
          _MetricGrid(_metrics),
          const SizedBox(height: 16),

          // Live Activity Feed
          _Card(
            title: 'Live Activity Feed',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  _feed.length,
                  (i) => _FeedRow(_feed[i], isLast: i == _feed.length - 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // System Infrastructure
          _Card(
            title: 'System Infrastructure',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(_infra.length, (i) {
                  final s = _infra[i];
                  final isLast = i == _infra.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isLast ? Colors.transparent : _C.border,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.service,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.textMain,
                          ),
                        ),
                        Text(
                          s.status,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: TENANTS
// ─────────────────────────────────────────────────────────────────────────────
class _TenantsTab extends StatelessWidget {
  final List<_Tenant> tenants;
  final void Function(_Tenant) onAdded;
  final void Function(int) onToggle;
  final void Function(String) onToast;
  const _TenantsTab({
    required this.tenants,
    required this.onAdded,
    required this.onToggle,
    required this.onToast,
  });

  void _showAdd(BuildContext context) {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    String plan = 'Starter';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => _Modal(
          title: 'Add New Tenant',
          body: Column(
            children: [
              _Field(
                controller: nameCtrl,
                label: 'Hospital Name',
                hint: 'e.g. Apollo Mumbai',
              ),
              const SizedBox(height: 12),
              _Field(
                controller: idCtrl,
                label: 'Tenant ID',
                hint: 'e.g. apollo_mum',
              ),
              const SizedBox(height: 12),
              _Dropdown(
                label: 'Plan',
                value: plan,
                items: const ['Starter', 'Pro', 'Enterprise'],
                onChanged: (v) => setSt(() => plan = v!),
              ),
            ],
          ),
          confirmLabel: 'Create Tenant',
          onConfirm: (ctx2) {
            if (nameCtrl.text.isNotEmpty && idCtrl.text.isNotEmpty) {
              onAdded(
                _Tenant(nameCtrl.text, idCtrl.text, plan, '0', 0, 'Active'),
              );
              Navigator.pop(ctx2);
              onToast('Tenant ${nameCtrl.text} created.');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Hospital Tenants',
        action: _Btn(label: '+ Add Tenant', onTap: () => _showAdd(context)),
        child: Column(
          children: List.generate(tenants.length, (i) {
            final t = tenants[i];
            final isLast = i == tenants.length - 1;
            return _ListRow(
              isLast: isLast,
              leading: _Avatar(
                t.name.substring(0, 2).toUpperCase(),
                bg: _C.primary.withOpacity(0.1),
                fg: _C.primary,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _C.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.tenantId}  ·  ${t.patients} pts  ·  ${t.doctors} drs',
                    style: const TextStyle(fontSize: 10, color: _C.textMuted),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _Pill.status(t.plan),
                      const SizedBox(width: 5),
                      _Pill.status(t.status),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _OutlineBtn(
                    label: 'View',
                    onTap: () => onToast('Viewing ${t.name}'),
                  ),
                  const SizedBox(height: 5),
                  _OutlineBtn(
                    label: t.status == 'Active' ? 'Suspend' : 'Restore',
                    onTap: () {
                      onToggle(i);
                      onToast(
                        '${t.name} ${t.status == 'Active' ? 'suspended' : 'restored'}.',
                      );
                    },
                    labelColor: t.status == 'Active'
                        ? _C.suspendedText
                        : _C.activeText,
                    borderColor: t.status == 'Active'
                        ? _C.suspendedText
                        : _C.activeText,
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

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: USERS & ROLES
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final List<_User> users;
  final void Function(_User) onAdded;
  final void Function(String) onToast;
  const _UsersTab({
    required this.users,
    required this.onAdded,
    required this.onToast,
  });

  void _showAdd(BuildContext context) {
    final nameCtrl = TextEditingController();
    final hospCtrl = TextEditingController();
    String role = 'Doctor';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => _Modal(
          title: 'Create User',
          body: Column(
            children: [
              _Field(
                controller: nameCtrl,
                label: 'Full Name',
                hint: 'e.g. Dr. Anita Roy',
              ),
              const SizedBox(height: 12),
              _Field(
                controller: hospCtrl,
                label: 'Hospital',
                hint: 'e.g. Apollo Chennai',
              ),
              const SizedBox(height: 12),
              _Dropdown(
                label: 'Role',
                value: role,
                items: const [
                  'Doctor',
                  'Hospital Admin',
                  'Care Coordinator',
                  'Lab Technician',
                  'Platform Admin',
                ],
                onChanged: (v) => setSt(() => role = v!),
              ),
            ],
          ),
          confirmLabel: 'Create Account',
          onConfirm: (ctx2) {
            if (nameCtrl.text.isNotEmpty && hospCtrl.text.isNotEmpty) {
              onAdded(_User(nameCtrl.text, role, hospCtrl.text, 'Just now'));
              Navigator.pop(ctx2);
              onToast('User ${nameCtrl.text} created.');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Platform Users',
        action: _Btn(label: '+ Create User', onTap: () => _showAdd(context)),
        child: Column(
          children: List.generate(users.length, (i) {
            final u = users[i];
            final isLast = i == users.length - 1;
            return _ListRow(
              isLast: isLast,
              leading: _Avatar(u.name.substring(0, 2).toUpperCase()),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                  Text(
                    '${u.role}  ·  ${u.hospital}',
                    style: const TextStyle(fontSize: 10, color: _C.textMuted),
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Pill(
                    label: 'Active',
                    bg: _C.activeBg,
                    fg: _C.activeText,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    u.lastLogin,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: PATIENT DATA
// ─────────────────────────────────────────────────────────────────────────────
class _PatientDataTab extends StatelessWidget {
  const _PatientDataTab();

  static List<_GlobalPatient> get _patients {
    final raw = _superApiData['global_patients'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_GlobalPatient>(
            (p) => _GlobalPatient(
              p['id'] ?? '',
              p['hospital'] ?? '',
              p['disease'] ?? '',
              p['lastTest'] ?? '',
              p['risk'] ?? 'Low',
              p['gap'] ?? 'Open',
            ),
          )
          .toList();
    }
    return const [
      _GlobalPatient(
        'P1001',
        'Apollo Chennai',
        'Diabetes',
        '120 days ago',
        'High',
        'Open',
      ),
      _GlobalPatient(
        'P1002',
        'Fortis Bangalore',
        'Hypertension',
        '45 days ago',
        'Medium',
        'Closed',
      ),
      _GlobalPatient(
        'P1003',
        'GlobalCare Delhi',
        'CKD',
        '200 days ago',
        'Critical',
        'Open',
      ),
      _GlobalPatient(
        'P1004',
        'MedLife Hyderabad',
        'Diabetes',
        '30 days ago',
        'Low',
        'Closed',
      ),
      _GlobalPatient(
        'P1005',
        'HealthFirst Pune',
        'Hypothyroidism',
        '160 days ago',
        'High',
        'Open',
      ),
    ];
  }

  static List<_Upload> get _uploads {
    final raw = _superApiData['uploads'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_Upload>(
            (u) => _Upload(
              u['hospital'] ?? '',
              u['file'] ?? '',
              u['records'] ?? '',
              u['date'] ?? '',
            ),
          )
          .toList();
    }
    return const [
      _Upload('Apollo Chennai', 'patients_apollo.csv', '20,000', 'Mar 10'),
      _Upload('Fortis Bangalore', 'dataset_fortis.csv', '15,000', 'Mar 9'),
      _Upload('GlobalCare Delhi', 'patients_delhi.csv', '5,000', 'Mar 8'),
      _Upload('MedLife Hyderabad', 'dataset_hyd.csv', '10,000', 'Mar 7'),
      _Upload('HealthFirst Pune', 'dataset_pune.csv', '4,000', 'Mar 6'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Patient list
          _Card(
            title: 'Global Patient Data Activity',
            child: Column(
              children: List.generate(_patients.length, (i) {
                final p = _patients[i];
                final isLast = i == _patients.length - 1;
                return _ListRow(
                  isLast: isLast,
                  leading: _Avatar(
                    p.id.substring(0, 2),
                    bg: _C.primary.withOpacity(0.08),
                    fg: _C.primary,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.id}  ·  ${p.hospital}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.textMain,
                        ),
                      ),
                      Text(
                        '${p.disease}  ·  ${p.lastTest}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _C.textMuted,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Pill.status(p.risk),
                      const SizedBox(height: 4),
                      _Pill.status(
                        p.gap == 'Open' ? 'Failed' : 'Active',
                      ), // re-uses red/green
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Dataset uploads
          _Card(
            title: 'Recent Dataset Uploads',
            child: Column(
              children: List.generate(_uploads.length, (i) {
                final u = _uploads[i];
                final isLast = i == _uploads.length - 1;
                return _ListRow(
                  isLast: isLast,
                  leading: const Icon(
                    Icons.upload_file_outlined,
                    size: 20,
                    color: _C.primary,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.hospital,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.textMain,
                        ),
                      ),
                      Text(
                        '${u.file}  ·  ${u.records} records  ·  ${u.date}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _C.textMuted,
                        ),
                      ),
                    ],
                  ),
                  trailing: const _Pill(
                    label: 'Completed',
                    bg: _C.activeBg,
                    fg: _C.activeText,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: AI ACTIVITY
// ─────────────────────────────────────────────────────────────────────────────
class _AiTab extends StatelessWidget {
  const _AiTab();

  static List<_AiDecision> get _decisions {
    final raw = _superApiData['ai_decisions'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_AiDecision>(
            (d) => _AiDecision(
              d['patient'] ?? '',
              d['hospital'] ?? '',
              d['risk'] ?? '',
              d['action'] ?? '',
            ),
          )
          .toList();
    }
    return const [
      _AiDecision('Ravi Kumar', 'Apollo', 'High', 'Send HbA1c reminder'),
      _AiDecision('Meena Iyer', 'Fortis', 'Critical', 'Escalate to doctor'),
      _AiDecision('Arjun Patel', 'GlobalCare', 'Medium', 'Send BP reminder'),
      _AiDecision('Neha Sharma', 'MedLife', 'Low', 'No action required'),
      _AiDecision('Karthik Rao', 'Apollo', 'High', 'Send creatinine reminder'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // AI Decision table
          _Card(
            title: 'AI Decision Table',
            child: Column(
              children: List.generate(_decisions.length, (i) {
                final d = _decisions[i];
                final isLast = i == _decisions.length - 1;
                return _ListRow(
                  isLast: isLast,
                  leading: _Avatar(
                    d.patient.substring(0, 1),
                    bg: _C.primary.withOpacity(0.08),
                    fg: _C.primary,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.patient,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.textMain,
                        ),
                      ),
                      Text(
                        '${d.hospital}  ·  ${d.action}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _C.textMuted,
                        ),
                      ),
                    ],
                  ),
                  trailing: _Pill.status(d.risk),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Decision Logic terminal
          _Card(
            title: 'Decision Logic Preview',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.terminalBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TermLine(
                      '>  Generating reminder for ',
                      highlight: '#RK4592...',
                    ),
                    const SizedBox(height: 6),
                    const _TermLine(
                      '>  Template: ',
                      highlight: 'Trial_Offer_Recall',
                    ),
                    const SizedBox(height: 10),
                    // message box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _C.terminalBlue.withOpacity(0.4),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '"Your HbA1c test is overdue. Your last result was 9.5%. '
                        'Please schedule a test to avoid complications."',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: _C.terminalBlue,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _TermLine(
                      '>  Conversion Probability: ',
                      highlight: '82.5%',
                    ),
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

class _TermLine extends StatelessWidget {
  final String prefix;
  final String highlight;
  const _TermLine(this.prefix, {required this.highlight});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          color: _C.terminalBlue,
        ),
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(color: _C.terminalGray),
          ),
          TextSpan(
            text: highlight,
            style: const TextStyle(
              color: _C.terminalWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: MESSAGING
// ─────────────────────────────────────────────────────────────────────────────
class _MessagingTab extends StatelessWidget {
  const _MessagingTab();

  static List<_MsgRow> get _msgs {
    final raw = _superApiData['messages'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_MsgRow>(
            (m) => _MsgRow(
              m['patient'] ?? '',
              m['hospital'] ?? '',
              m['channel'] ?? '',
              m['status'] ?? '',
            ),
          )
          .toList();
    }
    return const [
      _MsgRow('Ravi Kumar', 'Apollo', 'WhatsApp', 'Delivered'),
      _MsgRow('Meena Iyer', 'Fortis', 'WhatsApp', 'Delivered'),
      _MsgRow('Arjun Patel', 'GlobalCare', 'SMS', 'Sent'),
      _MsgRow('Neha Sharma', 'MedLife', 'WhatsApp', 'Delivered'),
      _MsgRow('Karthik Rao', 'Apollo', 'WhatsApp', 'Failed'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Messaging Log',
        child: Column(
          children: List.generate(_msgs.length, (i) {
            final m = _msgs[i];
            final isLast = i == _msgs.length - 1;
            return _ListRow(
              isLast: isLast,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: _C.primary,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.patient,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                  Text(
                    '${m.hospital}  ·  ${m.channel}',
                    style: const TextStyle(fontSize: 10, color: _C.textMuted),
                  ),
                ],
              ),
              trailing: _Pill.status(m.status),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: LAB BOOKINGS
// ─────────────────────────────────────────────────────────────────────────────
class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  static List<_BookingRow> get _bookings {
    final raw = _superApiData['bookings'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_BookingRow>(
            (b) => _BookingRow(
              b['patient'] ?? '',
              b['test'] ?? '',
              b['tech'] ?? '',
              b['status'] ?? '',
            ),
          )
          .toList();
    }
    return const [
      _BookingRow('Ravi Kumar', 'HbA1c', 'Arjun Patel', 'Scheduled'),
      _BookingRow('Meena Iyer', 'Creatinine', 'Rahul Singh', 'Completed'),
      _BookingRow('Arjun Patel', 'BP Test', 'Kavya Nair', 'Completed'),
      _BookingRow('Neha Sharma', 'TSH', 'Ankit Kumar', 'Scheduled'),
      _BookingRow('Karthik Rao', 'Creatinine', 'Arjun Patel', 'Scheduled'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Lab Operations',
        child: Column(
          children: List.generate(_bookings.length, (i) {
            final b = _bookings[i];
            final isLast = i == _bookings.length - 1;
            return _ListRow(
              isLast: isLast,
              leading: _Avatar(
                b.patient.substring(0, 1),
                bg: _C.neutralBg,
                fg: _C.primary,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.patient,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                  Text(
                    '${b.test}  ·  ${b.tech}',
                    style: const TextStyle(fontSize: 10, color: _C.textMuted),
                  ),
                ],
              ),
              trailing: _Pill.status(b.status),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: ANALYTICS
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  static const _metrics = [
    _Metric('Diabetes', '45%', 'Most prevalent disease'),
    _Metric('Hypertension', '30%', 'Second highest'),
    _Metric('CKD', '15%', 'Chronic kidney'),
    _Metric('Critical Tier', '10%', 'Highest risk patients'),
  ];

  // bar chart data: label, heightFactor
  static const _bars = [('SENT', 1.0), ('REPLIED', 0.6), ('BOOKED', 0.38)];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _MetricGrid(_metrics),
          const SizedBox(height: 16),

          _Card(
            title: 'Outreach Performance',
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // bar chart
                  SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _bars.map((b) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: b.$2,
                                    child: Container(
                                      width: 54,
                                      decoration: BoxDecoration(
                                        color: _C.primary.withOpacity(b.$2),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(8),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b.$1,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // conversion label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _C.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Conversion Rate: 38%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _C.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: SYSTEM MONITOR
// ─────────────────────────────────────────────────────────────────────────────
class _SystemTab extends StatelessWidget {
  const _SystemTab();

  static List<_ServiceRow> get _services {
    final raw = _superApiData['services'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_ServiceRow>(
            (x) => _ServiceRow(
              x['service']?.toString() ?? 'Unknown',
              x['status']?.toString() ?? 'Unknown',
              x['ms']?.toString() ?? '0 ms',
            ),
          )
          .toList();
    }
    return const [
      _ServiceRow('Django Backend', 'Online', '120 ms'),
      _ServiceRow('MongoDB', 'Healthy', '80 ms'),
      _ServiceRow('AI Engine', 'Online', '310 ms'),
      _ServiceRow('Twilio API', 'Connected', '150 ms'),
      _ServiceRow('Scheduler', 'Running', '90 ms'),
    ];
  }

  static List<_ErrorRow> get _errors {
    final raw = _superApiData['errors'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_ErrorRow>(
            (x) => _ErrorRow(
              x['error']?.toString() ?? 'Unknown',
              x['module']?.toString() ?? 'Unknown',
              x['time']?.toString() ?? '',
              x['status']?.toString() ?? 'Pending',
            ),
          )
          .toList();
    }
    return const [
      _ErrorRow('Database Timeout', 'API', 'Today', 'Resolved'),
      _ErrorRow('Twilio Failure', 'Messaging', 'Today', 'Pending'),
      _ErrorRow('AI Engine Timeout', 'Risk Engine', 'Yesterday', 'Resolved'),
      _ErrorRow('Webhook Delay', 'Messaging', 'Yesterday', 'Resolved'),
      _ErrorRow('Cache Error', 'API', 'Today', 'Pending'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Service status
          _Card(
            title: 'Service Status',
            child: Column(
              children: List.generate(_services.length, (i) {
                final s = _services[i];
                final isLast = i == _services.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isLast ? Colors.transparent : _C.border,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // status dot
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          s.service,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.textMain,
                          ),
                        ),
                      ),
                      Text(
                        s.ms,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _C.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Pill.status(s.status),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Error logs
          _Card(
            title: 'System Error Logs',
            child: Column(
              children: List.generate(_errors.length, (i) {
                final e = _errors[i];
                final isLast = i == _errors.length - 1;
                return _ListRow(
                  isLast: isLast,
                  leading: Icon(
                    e.status == 'Pending'
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 20,
                    color: e.status == 'Pending'
                        ? _C.suspendedText
                        : _C.activeText,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.error,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.textMain,
                        ),
                      ),
                      Text(
                        '${e.module}  ·  ${e.time}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _C.textMuted,
                        ),
                      ),
                    ],
                  ),
                  trailing: _Pill.status(e.status),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: BILLING
// ─────────────────────────────────────────────────────────────────────────────
class _BillingTab extends StatelessWidget {
  const _BillingTab();

  static List<_BillingRow> get _rows {
    final raw = _superApiData['billing'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_BillingRow>(
            (x) => _BillingRow(
              x['hospital']?.toString() ?? 'Unknown',
              x['plan']?.toString() ?? 'Starter',
              x['limit']?.toString() ?? '0',
              x['status']?.toString() ?? 'Active',
            ),
          )
          .toList();
    }
    return const [
      _BillingRow('Apollo Chennai', 'Enterprise', 'Unlimited', 'Active'),
      _BillingRow('Fortis Bangalore', 'Pro', '50,000', 'Active'),
      _BillingRow('GlobalCare Delhi', 'Starter', '5,000', 'Active'),
      _BillingRow('MedLife Hyderabad', 'Pro', '50,000', 'Suspended'),
      _BillingRow('HealthFirst Pune', 'Starter', '5,000', 'Active'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Subscriptions',
        child: Column(
          children: List.generate(_rows.length, (i) {
            final r = _rows[i];
            final isLast = i == _rows.length - 1;
            return _ListRow(
              isLast: isLast,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  size: 16,
                  color: _C.primary,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.hospital,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain,
                    ),
                  ),
                  Text(
                    'Limit: ${r.limit}',
                    style: const TextStyle(fontSize: 10, color: _C.textMuted),
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Pill.status(r.plan),
                  const SizedBox(height: 4),
                  _Pill.status(r.status),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  static const _protocols = [
    ['Diabetes', 'HbA1c', '90 days'],
    ['CKD', 'Creatinine', '180 days'],
    ['Hypothyroidism', 'TSH', '180 days'],
    ['Hypertension', 'BP Check', '90 days'],
    ['Diabetes', 'Kidney Panel', '180 days'],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Care Protocol Rules',
        child: Column(
          children: [
            // header row
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
                        color: _C.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Test',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _C.border),
            ...List.generate(_protocols.length, (i) {
              final p = _protocols[i];
              final isLast = i == _protocols.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isLast ? Colors.transparent : _C.border,
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
                          color: _C.textMain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p[1],
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p[2],
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.textMuted,
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

// ─────────────────────────────────────────────────────────────────────────────
//  TAB: AUDIT LOGS
// ─────────────────────────────────────────────────────────────────────────────
class _AuditTab extends StatelessWidget {
  const _AuditTab();

  static List<_AuditRow> get _logs {
    final raw = _superApiData['audit_log'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map<_AuditRow>(
            (x) => _AuditRow(
              x['user']?.toString() ?? 'Unknown',
              x['action']?.toString() ?? '',
              x['hospital']?.toString() ?? '',
              x['time']?.toString() ?? '',
            ),
          )
          .toList();
    }
    return const [
      _AuditRow('SuperAdmin', 'Created tenant Apollo', 'MediSynC', 'Today'),
      _AuditRow('Dr. Meera Iyer', 'Escalated patient Ravi', 'Apollo', 'Today'),
      _AuditRow('Kavya Nair', 'Booked home test', 'Apollo', 'Today'),
      _AuditRow('System AI', 'Sent outreach messages', 'GlobalCare', 'Today'),
      _AuditRow('Admin Rahul', 'Updated hospital plan', 'Fortis', 'Yesterday'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Card(
        title: 'Global Audit Trail',
        child: Column(
          children: List.generate(_logs.length, (i) {
            final l = _logs[i];
            final isLast = i == _logs.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLast ? Colors.transparent : _C.border,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5, right: 12),
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.action,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _C.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l.user}  ·  ${l.hospital}  ·  ${l.time}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _C.textMuted,
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
