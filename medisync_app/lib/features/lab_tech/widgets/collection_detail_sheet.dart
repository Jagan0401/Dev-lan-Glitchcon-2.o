import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';
import 'log_sample_sheet.dart';
import 'assign_report_sheet.dart';

/// Full-screen-height modal bottom-sheet showing patient details
/// and test specs — mirrors the HTML "details" tab panel.
class CollectionDetailSheet extends StatelessWidget {
  final CollectionTask task;
  final void Function(String) onToast;
  final void Function() onVisitStarted;

  const CollectionDetailSheet({
    super.key,
    required this.task,
    required this.onToast,
    required this.onVisitStarted,
  });

  static void show(
    BuildContext context,
    CollectionTask task,
    void Function(String) onToast,
    VoidCallback onVisitStarted,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollectionDetailSheet(
        task: task,
        onToast: onToast,
        onVisitStarted: onVisitStarted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collection Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          task.timeSlot,
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
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Scrollable body
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  // ── Patient Information ───────────────────────────
                  TechSectionCard(
                    title: 'Patient Information',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Column(
                        children: [
                          InfoRow(label: 'Name', value: task.patientName),
                          InfoRow(
                            label: 'Patient ID',
                            value: task.patientId,
                            mono: true,
                          ),
                          InfoRow(label: 'Age', value: '${task.age} yrs'),
                          InfoRow(label: 'Condition', value: task.condition),
                          InfoRow(label: 'Doctor', value: task.assignedDoctor),
                          InfoRow(label: 'Address', value: task.address),
                          const SizedBox(height: 8),
                          TechPrimaryBtn(
                            label: 'Start Collection',
                            onTap: () {
                              onVisitStarted();
                              Navigator.pop(context);
                              onToast(
                                'Visit started. Please proceed to patient address.',
                              );
                            },
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Test & Sample Specs ───────────────────────────
                  TechSectionCard(
                    title: 'Test & Sample Specs',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Column(
                        children: [
                          InfoRow(label: 'Test Name', value: task.testName),
                          const InfoRow(
                            label: 'Sample Type',
                            value: 'Venous Blood (EDTA Tube)',
                          ),
                          const InfoRow(
                            label: 'Instructions',
                            value: 'Fasting not required. Invert tube 8 times.',
                          ),
                          InfoRow(
                            label: 'Preferred Window',
                            value:
                                '${task.timeSlot} – ${_addHour(task.timeSlot)}',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    LogSampleSheet.show(context, task, onToast);
                                  },
                                  icon: const Icon(
                                    Icons.science_outlined,
                                    size: 14,
                                  ),
                                  label: const Text('Log Sample'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TechPrimaryBtn(
                                  label: 'Assign Report',
                                  onTap: () {
                                    Navigator.pop(context);
                                    AssignReportSheet.show(
                                      context,
                                      task,
                                      onToast,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
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

  String _addHour(String time) {
    // Very simple — just shows "next hour" as the window end
    final parts = time.split(':');
    final hr = (int.tryParse(parts[0]) ?? 0) + 1;
    final suffix = hr >= 12 ? 'PM' : 'AM';
    final displayHr = hr > 12 ? hr - 12 : hr;
    return '$displayHr:${parts[1].split(' ')[0]} $suffix';
  }
}
