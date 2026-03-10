import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/doctor_dashboard_models.dart';

class LabResultsTab extends StatelessWidget {
  final List<LabResult> results;
  final void Function(String) onShowToast;

  const LabResultsTab({
    super.key,
    required this.results,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('lab-results-tab'),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Text(
          'Recent Lab Reports',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        ...results.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ResultCard(
              result: r,
              onAddNotes: () => _showNotesSheet(context, r),
            ),
          ),
        ),
      ],
    );
  }

  void _showNotesSheet(BuildContext context, LabResult result) {
    final obsCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Doctor Recommendations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${result.patientName} · ${result.testName} · ${result.result}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Clinical Observations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: obsCtrl,
                maxLines: 3,
                decoration: _inputDec(hint: 'Enter clinical observations...'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _GradBtn(
                      label: 'Save Notes',
                      onTap: () {
                        Navigator.pop(context);
                        onShowToast('Observations saved.');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  _OutBtn(label: 'Cancel', onTap: () => Navigator.pop(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final LabResult result;
  final VoidCallback onAddNotes;

  const _ResultCard({required this.result, required this.onAddNotes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.science_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.patientName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  '${result.testName} · ${result.date}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result.result,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAddNotes,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Notes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDec({String? hint}) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: AppColors.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.cardBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.cardBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  ),
);

class _GradBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}

class _OutBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
    ),
  );
}
