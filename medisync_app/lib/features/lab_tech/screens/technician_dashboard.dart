import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/widgets/animated_grid_background.dart';

// Reused from doctor feature
import '../../doctor/widgets/metric_card.dart';
import '../../doctor/widgets/activity_feed.dart';
import '../../doctor/models/doctor_dashboard_models.dart' show ActivityFeedItem;

// Lab-tech-specific
import '../models/lab_tech_models.dart';
import '../widgets/lab_tech_shared.dart';
import '../widgets/collections_tab.dart';
import '../widgets/collection_detail_sheet.dart';
import '../widgets/tracking_tab.dart';
import '../widgets/route_tab.dart';
import '../widgets/comm_tab.dart';
import '../widgets/tech_audit_tab.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/dashboard_service.dart';

// ─── Tab enum ─────────────────────────────────────────────────────────────────

enum TechTab {
  dashboard,
  collections,
  tracking,
  schedule,
  communication,
  reports,
  profile,
  audit,
}

extension TechTabExt on TechTab {
  String get title => switch (this) {
    TechTab.dashboard => 'Dashboard',
    TechTab.collections => 'Assigned Tasks',
    TechTab.tracking => 'Sample Tracking',
    TechTab.schedule => 'Route & Schedule',
    TechTab.communication => 'Communication',
    TechTab.reports => 'My Reports',
    TechTab.profile => 'Settings',
    TechTab.audit => 'Activity Logs',
  };

  String get subtitle => switch (this) {
    TechTab.dashboard =>
      'Overview of technician workload and collection status',
    TechTab.collections => 'Active tasks for home sample pickups',
    TechTab.tracking => 'Monitor the journey from pickup to lab delivery',
    TechTab.schedule => 'Traffic-optimised navigation plan',
    TechTab.communication => 'Direct messaging with patients on route',
    TechTab.reports => 'Personal performance and logistics metrics',
    TechTab.profile => 'Manage personal credentials and zone preferences',
    TechTab.audit => 'History of completed tasks and logs',
  };

  IconData get icon => switch (this) {
    TechTab.dashboard => Icons.grid_view_rounded,
    TechTab.collections => Icons.assignment_outlined,
    TechTab.tracking => Icons.location_on_outlined,
    TechTab.schedule => Icons.calendar_month_outlined,
    TechTab.communication => Icons.chat_bubble_outline_rounded,
    TechTab.reports => Icons.bar_chart_rounded,
    TechTab.profile => Icons.settings_outlined,
    TechTab.audit => Icons.history_rounded,
  };
}

const _primaryTabs = [
  TechTab.dashboard,
  TechTab.collections,
  TechTab.tracking,
  TechTab.schedule,
  TechTab.communication,
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class TechnicianDashboard extends StatefulWidget {
  const TechnicianDashboard({super.key});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard>
    with TickerProviderStateMixin {
  TechTab _currentTab = TechTab.dashboard;

  List<CollectionTask> _tasks = [];
  List<SampleRecord> _samples = [];
  List<RouteStop> _stops = [];
  List<CommLog> _commLogs = [];
  List<AuditEntry> _auditEntries = [];
  List<ActivityFeedItem> _activityFeed = [];
  int _followups = 0;
  bool _isLoading = true;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
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
      final data = await getIt<DashboardService>().fetchTechnicianDashboard();
      if (!mounted) return;
      setState(() {
        _tasks = _parseTasks(data['tasks']);
        _samples = _parseSamples(data['samples']);
        _stops = _parseStops(data['route_stops']);
        _commLogs = _parseCommLogs(data['comm_logs']);
        _auditEntries = _parseAuditEntries(data['audit_log']);
        _activityFeed = _parseFeed(data['activity_feed']);
        final m = data['metrics'] as Map<String, dynamic>? ?? {};
        _followups = m['followups'] ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tasks = List.from(seedTasks);
        _samples = List.from(seedSamples);
        _stops = List.from(seedRouteStops);
        _commLogs = List.from(seedCommLogs);
        _auditEntries = List.from(seedAuditLog);
        _activityFeed = seedActivityFeed
            .map(
              (a) => ActivityFeedItem(icon: a.icon, text: a.text, time: a.time),
            )
            .toList();
        _followups = 2;
        _isLoading = false;
      });
    }
  }

  static List<CollectionTask> _parseTasks(dynamic raw) {
    if (raw is! List) return List.from(seedTasks);
    return raw
        .map<CollectionTask>(
          (t) => CollectionTask(
            patientName: t['patientName'] ?? '',
            testName: t['testName'] ?? '',
            address: t['address'] ?? '',
            timeSlot: t['timeSlot'] ?? '',
            patientId: t['patientId'] ?? '',
            age: '${t['age'] ?? ''}',
            assignedDoctor: t['assignedDoctor'] ?? '',
            condition: t['condition'] ?? '',
            status: _parseCollectionStatus(t['status']),
          ),
        )
        .toList();
  }

  static List<SampleRecord> _parseSamples(dynamic raw) {
    if (raw is! List) return List.from(seedSamples);
    return raw
        .map<SampleRecord>(
          (s) => SampleRecord(
            sampleId: s['sampleId'] ?? '',
            patientName: s['patientName'] ?? '',
            testName: s['testName'] ?? '',
            collectedAt: s['collectedAt'] ?? '',
            status: _parseSampleStatus(s['status']),
          ),
        )
        .toList();
  }

  static List<RouteStop> _parseStops(dynamic raw) {
    if (raw is! List) return List.from(seedRouteStops);
    return raw
        .map<RouteStop>(
          (r) => RouteStop(
            timeSlot: r['timeSlot'] ?? '',
            patientName: r['patientName'] ?? '',
            location: r['location'] ?? '',
            confirmed: r['confirmed'] ?? false,
          ),
        )
        .toList();
  }

  static List<CommLog> _parseCommLogs(dynamic raw) {
    if (raw is! List) return List.from(seedCommLogs);
    return raw
        .map<CommLog>(
          (c) => CommLog(
            patientName: c['patientName'] ?? '',
            lastMessage: c['lastMessage'] ?? '',
            channel: c['channel'] ?? 'WhatsApp',
            status: c['status'] ?? 'Sent',
          ),
        )
        .toList();
  }

  static List<AuditEntry> _parseAuditEntries(dynamic raw) {
    if (raw is! List) return List.from(seedAuditLog);
    return raw
        .map<AuditEntry>(
          (a) => AuditEntry(
            actor: a['actor'] ?? '',
            action: a['action'] ?? '',
            timestamp: a['timestamp'] ?? '',
          ),
        )
        .toList();
  }

  static List<ActivityFeedItem> _parseFeed(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map<ActivityFeedItem>(
          (f) => ActivityFeedItem(
            icon: f['icon'] ?? '\ud83d\udccb',
            text: f['text'] ?? '',
            time: f['time'] ?? '',
          ),
        )
        .toList();
  }

  static CollectionStatus _parseCollectionStatus(dynamic raw) {
    return switch ('$raw'.toLowerCase()) {
      'inprogress' || 'in_progress' => CollectionStatus.inProgress,
      'completed' => CollectionStatus.completed,
      'cancelled' => CollectionStatus.cancelled,
      _ => CollectionStatus.scheduled,
    };
  }

  static SampleStatus _parseSampleStatus(dynamic raw) {
    return switch ('$raw'.toLowerCase()) {
      'collected' => SampleStatus.collected,
      'intransit' || 'in_transit' => SampleStatus.inTransit,
      'delivered' => SampleStatus.delivered,
      'reportfinalised' || 'report_finalised' => SampleStatus.reportFinalised,
      _ => SampleStatus.pending,
    };
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _switchTab(TechTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
    _entranceCtrl
      ..reset()
      ..forward();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.textMain,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, state) {
        if (state is AuthUnauthenticatedState) context.go(AppRoutes.login);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _TechDrawer(
          currentTab: _currentTab,
          onTabSelected: (tab) {
            Navigator.pop(context);
            _switchTab(tab);
          },
          onLogout: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(AuthLogoutEvent());
          },
        ),
        body: Stack(
          children: [
            const AnimatedGridBackground(),
            SafeArea(
              child: Column(
                children: [
                  _TechAppBar(tab: _currentTab),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FadeTransition(
                            opacity: _fadeAnim,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: _buildBody(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _TechBottomNav(
          currentTab: _currentTab,
          onTap: _switchTab,
        ),
      ),
    );
  }

  Widget _buildBody() => switch (_currentTab) {
    TechTab.dashboard => _DashboardTab(
      tasks: _tasks,
      samples: _samples,
      activityFeed: _activityFeed,
      followups: _followups,
      onToast: _showToast,
      onNavigate: _switchTab,
    ),
    TechTab.collections => CollectionsTab(
      tasks: _tasks,
      onToast: _showToast,
      onViewDetails: (task) => CollectionDetailSheet.show(
        context,
        task,
        _showToast,
        () => setState(() => task.status = CollectionStatus.inProgress),
      ),
    ),
    TechTab.tracking => TrackingTab(samples: _samples, onToast: _showToast),
    TechTab.schedule => RouteTab(stops: _stops, onToast: _showToast),
    TechTab.communication => CommTab(
      logs: _commLogs.isNotEmpty ? _commLogs : seedCommLogs,
      onToast: _showToast,
    ),
    TechTab.reports => _ReportsTab(onToast: _showToast),
    TechTab.profile => const _ProfileTab(),
    TechTab.audit => TechAuditTab(
      entries: _auditEntries.isNotEmpty ? _auditEntries : seedAuditLog,
    ),
  };
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _TechAppBar extends StatelessWidget {
  final TechTab tab;
  const _TechAppBar({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tab.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  tab.subtitle,
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
                  decoration: BoxDecoration(
                    color: AppColors.technicianColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.technicianColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Arjun P.',
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

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _TechBottomNav extends StatelessWidget {
  final TechTab currentTab;
  final void Function(TechTab) onTap;
  const _TechBottomNav({required this.currentTab, required this.onTap});

  String _short(TechTab t) => switch (t) {
    TechTab.dashboard => 'Home',
    TechTab.collections => 'Tasks',
    TechTab.tracking => 'Track',
    TechTab.schedule => 'Route',
    TechTab.communication => 'Comms',
    _ => t.title,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: _primaryTabs.map((tab) {
              final active = currentTab == tab;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(tab),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active ? 36 : 28,
                        height: active ? 36 : 28,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.technicianColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tab.icon,
                          size: active ? 17 : 20,
                          color: active ? Colors.white : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _short(tab),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: active
                              ? AppColors.technicianColor
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Drawer ───────────────────────────────────────────────────────────────────

class _TechDrawer extends StatelessWidget {
  final TechTab currentTab;
  final void Function(TechTab) onTabSelected;
  final VoidCallback onLogout;
  const _TechDrawer({
    required this.currentTab,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Medi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: AppColors.textMain,
                          ),
                        ),
                        TextSpan(
                          text: 'SynC.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Lab Technician Panel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20, color: AppColors.divider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: TechTab.values.map((tab) {
                  final active = currentTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onTabSelected(tab),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.technicianColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.technicianColor
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                tab.icon,
                                size: 17,
                                color: active
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                tab.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.technicianColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.technicianColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arjun Patel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          'Lab Technician',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.textMuted,
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
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final List<CollectionTask> tasks;
  final List<SampleRecord> samples;
  final List<ActivityFeedItem> activityFeed;
  final int followups;
  final void Function(String) onToast;
  final void Function(TechTab) onNavigate;

  const _DashboardTab({
    required this.tasks,
    required this.samples,
    required this.activityFeed,
    required this.followups,
    required this.onToast,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final completed = tasks
        .where((t) => t.status == CollectionStatus.completed)
        .length;
    final pending = tasks
        .where((t) => t.status != CollectionStatus.completed)
        .length;
    final delivered = samples
        .where((s) => s.status == SampleStatus.delivered)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: "Today's Collections",
                value: '${tasks.length}',
                sub: 'Assigned today',
                subColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Completed',
                value: '$completed',
                sub: 'Done',
                subColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Pending',
                value: '$pending',
                sub: 'Remaining',
                subColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Delivered',
                value: '$delivered',
                sub: 'In lab',
                subColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        MetricCard(
          label: 'Follow-ups',
          value: '$followups',
          sub: 'Require attention',
          subColor: AppColors.warning,
          fullWidth: true,
        ),
        const SizedBox(height: 20),
        TechSectionCard(
          title: 'Recent Activity',
          child: ActivityFeed(
            items: activityFeed.isNotEmpty
                ? activityFeed
                : seedActivityFeed
                      .map(
                        (a) => ActivityFeedItem(
                          icon: a.icon,
                          text: a.text,
                          time: a.time,
                        ),
                      )
                      .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _ProximityCard(onNavigate: () => onNavigate(TechTab.schedule)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickBtn(
                icon: Icons.assignment_outlined,
                label: 'View Tasks',
                count: '$pending left',
                onTap: () => onNavigate(TechTab.collections),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickBtn(
                icon: Icons.science_outlined,
                label: 'Track Samples',
                count: '${samples.length} logged',
                onTap: () => onNavigate(TechTab.tracking),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProximityCard extends StatelessWidget {
  final VoidCallback onNavigate;
  const _ProximityCard({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Closest Appointment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Meena Iyer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '2.4 km away',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNavigate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Navigate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final VoidCallback onTap;
  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
              color: AppColors.technicianColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.technicianColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  count,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Reports Tab ──────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  final void Function(String) onToast;
  const _ReportsTab({required this.onToast});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        const Row(
          children: [
            Expanded(
              child: MetricCard(label: "Today's Collections", value: '12'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Success Rate',
                value: '92%',
                sub: 'Above target',
                subColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const MetricCard(
          label: 'Avg. Transit Time',
          value: '45m',
          sub: 'Per sample',
          subColor: AppColors.primary,
          fullWidth: true,
        ),
        const SizedBox(height: 20),
        TechSectionCard(
          title: 'Performance Export',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TechPrimaryBtn(
                  label: 'Export CSV',
                  fullWidth: true,
                  onTap: () => onToast('Downloading CSV Report…'),
                ),
                const SizedBox(height: 10),
                TechPrimaryBtn(
                  label: 'Export Excel',
                  fullWidth: true,
                  onTap: () => onToast('Downloading Excel Data…'),
                ),
                const SizedBox(height: 10),
                TechPrimaryBtn(
                  label: 'Export PDF',
                  fullWidth: true,
                  onTap: () => onToast('Generating PDF Report…'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Profile Tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _phoneCtrl = TextEditingController(text: '+91 91234 56789');
  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        TechSectionCard(
          title: 'Technician Credentials',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _readOnly('Full Name', 'Arjun Patel'),
                const SizedBox(height: 12),
                _editable('Phone', _phoneCtrl, TextInputType.phone),
                const SizedBox(height: 12),
                _readOnly('Assigned Zone', 'South Chennai / East Zone'),
                const SizedBox(height: 12),
                _readOnly('Hospital', 'Apollo Chennai'),
                const SizedBox(height: 20),
                TechPrimaryBtn(
                  label: 'Update Profile',
                  fullWidth: true,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile settings saved.')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnly(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ),
    ],
  );

  Widget _editable(
    String label,
    TextEditingController ctrl,
    TextInputType kb,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 6),
      TextField(controller: ctrl, keyboardType: kb, decoration: techInputDec()),
    ],
  );
}
