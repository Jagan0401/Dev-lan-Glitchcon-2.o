import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';

class RouteTab extends StatefulWidget {
  final List<RouteStop> stops;
  final void Function(String) onToast;

  const RouteTab({super.key, required this.stops, required this.onToast});

  @override
  State<RouteTab> createState() => _RouteTabState();
}

class _RouteTabState extends State<RouteTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Optimized Route",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            TechSmallBtn(
              label: 'Optimize',
              primary: true,
              onTap: () =>
                  widget.onToast('Route re-optimized for current traffic.'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Timeline-style route stops
        ...widget.stops.asMap().entries.map((e) {
          final idx = e.key;
          final stop = e.value;
          final isLast = idx == widget.stops.length - 1;
          return _RouteStopRow(
            stop: stop,
            isLast: isLast,
            onConfirm: () {
              setState(() => stop.confirmed = true);
              widget.onToast('Confirmation WhatsApp sent.');
            },
          );
        }),
      ],
    );
  }
}

class _RouteStopRow extends StatelessWidget {
  final RouteStop stop;
  final bool isLast;
  final VoidCallback onConfirm;

  const _RouteStopRow({
    required this.stop,
    required this.isLast,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stop.confirmed
                        ? AppColors.success
                        : AppColors.primary,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (stop.confirmed
                                    ? AppColors.success
                                    : AppColors.primary)
                                .withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: stop.confirmed
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.cardBorder,
                ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.patientName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              stop.location,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              stop.timeSlot,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  stop.confirmed
                      ? const SampleStatusBadge(label: 'Confirmed')
                      : TechSmallBtn(
                          label: 'Confirm',
                          primary: true,
                          onTap: onConfirm,
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
