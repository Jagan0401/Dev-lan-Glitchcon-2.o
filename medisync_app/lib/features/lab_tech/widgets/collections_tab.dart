import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';

class CollectionsTab extends StatefulWidget {
  final List<CollectionTask> tasks;
  final void Function(String) onToast;
  final void Function(CollectionTask) onViewDetails;

  const CollectionsTab({
    super.key,
    required this.tasks,
    required this.onToast,
    required this.onViewDetails,
  });

  @override
  State<CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  @override
  Widget build(BuildContext context) {
    final pending = widget.tasks
        .where(
          (t) =>
              t.status == CollectionStatus.scheduled ||
              t.status == CollectionStatus.inProgress,
        )
        .length;
    final completed = widget.tasks
        .where((t) => t.status == CollectionStatus.completed)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        // Mini progress strip
        Row(
          children: [
            Text(
              "Today's Queue",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const Spacer(),
            _CountPill(
              '$completed done',
              AppColors.successBg,
              AppColors.success,
            ),
            const SizedBox(width: 8),
            _CountPill('$pending left', AppColors.warningBg, AppColors.warning),
          ],
        ),
        const SizedBox(height: 14),
        ...widget.tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TaskCard(
              task: task,
              onStartVisit: () {
                setState(() => task.status = CollectionStatus.inProgress);
                widget.onToast('Visit started. Destination logged.');
              },
              onViewDetails: () => widget.onViewDetails(task),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final CollectionTask task;
  final VoidCallback onStartVisit;
  final VoidCallback onViewDetails;

  const _TaskCard({
    required this.task,
    required this.onStartVisit,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == CollectionStatus.completed;
    final isInProgress = task.status == CollectionStatus.inProgress;
    final accentColor = isCompleted
        ? AppColors.success
        : isInProgress
        ? AppColors.primary
        : AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          top: const BorderSide(color: AppColors.cardBorder),
          right: const BorderSide(color: AppColors.cardBorder),
          bottom: const BorderSide(color: AppColors.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    task.patientName.substring(0, 1),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.patientName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        task.testName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SampleStatusBadge(label: task.status.label),
              ],
            ),
            const SizedBox(height: 10),
            // Address + time row
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.address,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 3),
                Text(
                  task.timeSlot,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                TechSmallBtn(label: 'Details', onTap: onViewDetails),
                const SizedBox(width: 8),
                if (!isCompleted)
                  TechSmallBtn(
                    label: isInProgress ? 'In Progress' : 'Start Visit',
                    onTap: isInProgress ? null : onStartVisit,
                    primary: !isInProgress,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _CountPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _CountPill(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}
