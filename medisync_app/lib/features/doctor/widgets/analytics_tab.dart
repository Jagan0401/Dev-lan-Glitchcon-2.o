import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'metric_card.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('analytics-tab'),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Text(
          'Performance Metrics',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Response Rate',
                value: '84%',
                sub: 'Patient engagement',
                subColor: AppColors.success,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Care Closure',
                value: '62%',
                sub: 'Gap resolution rate',
                subColor: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const MetricCard(
          label: 'Patient NPS',
          value: '9.2',
          sub: 'Satisfaction score',
          subColor: AppColors.success,
          fullWidth: true,
        ),
      ],
    );
  }
}
