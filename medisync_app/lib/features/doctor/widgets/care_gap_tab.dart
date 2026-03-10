import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/doctor_dashboard_models.dart';
import 'risk_badge.dart';

class CareGapTab extends StatefulWidget {
  final List<CareGapAlert> careGaps;
  final void Function(String) onShowToast;

  const CareGapTab({
    super.key,
    required this.careGaps,
    required this.onShowToast,
  });

  @override
  State<CareGapTab> createState() => _CareGapTabState();
}

class _CareGapTabState extends State<CareGapTab> {
  late final List<CareGapAlert> _gaps;

  @override
  void initState() {
    super.initState();
    _gaps = List.from(widget.careGaps);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('care-gap-tab'),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _SectionHeader(
          title: 'AI-Detected Care Gaps',
          subtitle: '${_gaps.length} gaps identified',
        ),
        const SizedBox(height: 12),
        ..._gaps.map(
          (gap) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CareGapCard(
              gap: gap,
              onRemind: () {
                widget.onShowToast(
                  'AI reminder sequence initiated for ${gap.patientName}',
                );
              },
              onEscalate: () {
                setState(() => gap.escalated = true);
                widget.onShowToast(
                  'Patient ${gap.patientName} escalated and flagged critical.',
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CareGapCard extends StatelessWidget {
  final CareGapAlert gap;
  final VoidCallback onRemind;
  final VoidCallback onEscalate;

  const _CareGapCard({
    required this.gap,
    required this.onRemind,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = gap.risk == RiskLevel.critical;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? AppColors.error.withOpacity(0.2)
              : AppColors.cardBorder,
          width: isCritical ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCritical
                      ? AppColors.error.withOpacity(0.08)
                      : AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: isCritical ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gap.patientName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      '${gap.testOverdue} overdue · ${gap.delay}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              RiskBadge(risk: gap.escalated ? RiskLevel.critical : gap.risk),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!gap.escalated) ...[
                Expanded(
                  child: _ActionButton(
                    label: 'Send Reminder',
                    onTap: onRemind,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (isCritical && !gap.escalated)
                Expanded(
                  child: _ActionButton(
                    label: 'Escalate',
                    onTap: onEscalate,
                    isPrimary: true,
                    isDestructive: true,
                  ),
                )
              else if (!gap.escalated)
                const SizedBox()
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ESCALATED',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF991B1B),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive
        ? AppColors.error
        : isPrimary
        ? AppColors.primary
        : AppColors.surface;
    final fg = (isPrimary || isDestructive) ? Colors.white : AppColors.textMain;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: (!isPrimary && !isDestructive)
              ? Border.all(color: AppColors.divider)
              : null,
          boxShadow: (isPrimary || isDestructive)
              ? [
                  BoxShadow(
                    color: bg.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
        ),
      ),
      if (subtitle != null)
        Text(
          subtitle!,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
    ],
  );
}
