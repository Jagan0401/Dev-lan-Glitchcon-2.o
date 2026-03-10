import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';

class TrackingTab extends StatefulWidget {
  final List<SampleRecord> samples;
  final void Function(String) onToast;

  const TrackingTab({super.key, required this.samples, required this.onToast});

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Collected Samples Log',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            Text(
              '${widget.samples.length} samples',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.samples.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SampleCard(
              sample: s,
              onUpdate: () {
                setState(() {
                  if (s.status == SampleStatus.collected) {
                    s.status = SampleStatus.inTransit;
                    widget.onToast(
                      'Status updated: Sample moving to central lab.',
                    );
                  } else if (s.status == SampleStatus.inTransit) {
                    s.status = SampleStatus.delivered;
                    widget.onToast(
                      'Status updated: Handed over to Lab Technician.',
                    );
                  }
                });
              },
              onReportIssue: () => _showIssueSheet(context, s),
            ),
          ),
        ),
      ],
    );
  }

  void _showIssueSheet(BuildContext context, SampleRecord sample) {
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TechSheet(
          title: 'Report Operational Issue',
          subtitle: '${sample.sampleId} · ${sample.patientName}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Description of Issue',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: techInputDec(
                  hint: 'Patient unavailable at location…',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TechPrimaryBtn(
                      label: 'Report Incident',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onToast('Incident reported to coordinator.');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  TechOutlineBtn(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  final SampleRecord sample;
  final VoidCallback onUpdate;
  final VoidCallback onReportIssue;

  const _SampleCard({
    required this.sample,
    required this.onUpdate,
    required this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final isArchived =
        sample.status == SampleStatus.delivered ||
        sample.status == SampleStatus.reportFinalised;
    final isPending = sample.status == SampleStatus.pending;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
              // Test-tube icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sample.patientName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sample.sampleId,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${sample.testName} · ${sample.collectedAt}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SampleStatusBadge(label: sample.status.label),
            ],
          ),

          // Progress track
          if (!isPending) ...[
            const SizedBox(height: 12),
            _StatusTrail(status: sample.status),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              if (!isArchived && !isPending) ...[
                TechSmallBtn(
                  label: sample.status == SampleStatus.collected
                      ? 'Mark In Transit'
                      : 'Mark Delivered',
                  onTap: onUpdate,
                  primary: true,
                ),
              ],
              if (isPending) ...[
                TechSmallBtn(label: 'Report Issue', onTap: onReportIssue),
              ],
              if (isArchived) ...[
                const TechSmallBtn(label: 'Archived', onTap: null),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTrail extends StatelessWidget {
  final SampleStatus status;
  const _StatusTrail({required this.status});

  static const _steps = ['Collected', 'In Transit', 'Delivered'];

  int get _activeIdx => switch (status) {
    SampleStatus.collected => 0,
    SampleStatus.inTransit => 1,
    SampleStatus.delivered => 2,
    SampleStatus.reportFinalised => 2,
    _ => -1,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _steps.asMap().entries.map((e) {
        final idx = e.key;
        final step = e.value;
        final done = idx <= _activeIdx;
        final isLast = idx == _steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              // Dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.primary : AppColors.divider,
                ),
              ),
              // Label
              if (!isLast) ...[
                Expanded(
                  child: Container(
                    height: 2,
                    color: done ? AppColors.primary : AppColors.divider,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                  ),
                ),
              ] else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      step,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: done ? AppColors.primary : AppColors.textLight,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
