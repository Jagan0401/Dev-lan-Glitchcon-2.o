import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/doctor_dashboard_models.dart';
import 'risk_badge.dart';

class PatientListTab extends StatelessWidget {
  final List<PatientSummary> patients;
  final void Function(String) onShowToast;

  const PatientListTab({
    super.key,
    required this.patients,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('patient-list-tab'),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _Header(count: patients.length),
        const SizedBox(height: 12),
        ...patients.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PatientCard(
              patient: p,
              onDetails: () => _showPatientSheet(context, p),
              onMessage: () => _showMessageSheet(context, p.name, onShowToast),
            ),
          ),
        ),
      ],
    );
  }

  void _showPatientSheet(BuildContext context, PatientSummary patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PatientDetailSheet(patient: patient),
    );
  }

  void _showMessageSheet(
    BuildContext context,
    String name,
    void Function(String) onToast,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageSheet(
        patientName: name,
        onSent: (msg) {
          Navigator.pop(context);
          onToast('Message queued for AI WhatsApp Gateway delivery.');
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Assigned Caseload',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count patients',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientSummary patient;
  final VoidCallback onDetails;
  final VoidCallback onMessage;

  const _PatientCard({
    required this.patient,
    required this.onDetails,
    required this.onMessage,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  patient.name.substring(0, 1),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      patient.condition,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              RiskBadge(risk: patient.risk),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                'Last test: ${patient.lastTest}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                patient.id,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(label: 'Details', onTap: onDetails),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(label: 'Message', onTap: onMessage),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message bottom sheet ─────────────────────────────────────────────────────

class _MessageSheet extends StatefulWidget {
  final String patientName;
  final void Function(String) onSent;

  const _MessageSheet({required this.patientName, required this.onSent});

  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
  final _ctrl = TextEditingController();
  String _channel = 'WhatsApp';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetFrame(
      title: 'Message to ${widget.patientName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetLabel('Channel'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _channel,
            onChanged: (v) => setState(() => _channel = v!),
            decoration: _inputDec(),
            items: [
              'WhatsApp',
              'SMS',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          ),
          const SizedBox(height: 14),
          const _SheetLabel('Message Text'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _ctrl,
            maxLines: 4,
            decoration: _inputDec(hint: 'Type instructions...'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PrimaryBtn(
                  label: 'Send via AI Gateway',
                  onTap: () {
                    if (_ctrl.text.isNotEmpty) widget.onSent(_ctrl.text);
                  },
                ),
              ),
              const SizedBox(width: 10),
              _OutlineBtn(label: 'Cancel', onTap: () => Navigator.pop(context)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Patient detail bottom sheet ───────────────────────────────────────────────

class _PatientDetailSheet extends StatelessWidget {
  final PatientSummary patient;
  const _PatientDetailSheet({required this.patient});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetFrame(
      title: 'Patient Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row('Name', patient.name),
          _Row('Condition', patient.condition),
          _Row('Last Test', patient.lastTest),
          _Row('Patient ID', patient.id),
          _Row('Risk Level', patient.risk.label),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _PrimaryBtn(
              label: 'Mark Patient Stable',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Patient risk profile updated to STABLE.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _Row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
    ),
  );
}

class _BottomSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;
  const _BottomSheetFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
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
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textMain,
    ),
  );
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

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

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
