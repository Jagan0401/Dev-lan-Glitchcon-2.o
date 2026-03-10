import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/doctor_dashboard.dart';

class DoctorBottomNav extends StatelessWidget {
  final DoctorTab currentTab;
  final List<DoctorTab> primaryTabs;
  final void Function(DoctorTab) onTabSelected;

  const DoctorBottomNav({
    super.key,
    required this.currentTab,
    required this.primaryTabs,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
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
            children: primaryTabs.map((tab) {
              final isActive = currentTab == tab;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabSelected(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 36 : 28,
                          height: isActive ? 36 : 28,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            tab.icon,
                            size: isActive ? 18 : 20,
                            color: isActive
                                ? Colors.white
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _shortLabel(tab),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _shortLabel(DoctorTab tab) => switch (tab) {
    DoctorTab.dashboard => 'Home',
    DoctorTab.patients => 'Patients',
    DoctorTab.alerts => 'Alerts',
    DoctorTab.results => 'Results',
    DoctorTab.appointments => 'Schedule',
    _ => tab.title,
  };
}
