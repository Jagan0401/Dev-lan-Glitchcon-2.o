import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/doctor_dashboard_models.dart';
import 'risk_badge.dart';

class AppointmentsTab extends StatelessWidget {
  final List<Appointment> appointments;
  final void Function(String) onShowToast;
  final void Function(Appointment) onAppointmentCreated;

  const AppointmentsTab({
    super.key,
    required this.appointments,
    required this.onShowToast,
    required this.onAppointmentCreated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('appointments-tab'),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Appointments & Follow-ups',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            GestureDetector(
              onTap: () => _showCreateSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Create',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...appointments.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AppointmentCard(appointment: a),
          ),
        ),
      ],
    );
  }

  void _showCreateSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
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
                  'Create Appointment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                _Label('Patient Name'),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: _dec('Search patient...'),
                ),
                const SizedBox(height: 14),
                _Label('Purpose'),
                const SizedBox(height: 6),
                TextField(
                  controller: purposeCtrl,
                  decoration: _dec('e.g. Clinical Review'),
                ),
                const SizedBox(height: 14),
                _Label('Date'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      dateCtrl.text = '${picked.day} ${_month(picked.month)}';
                      setSt(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateCtrl.text.isEmpty
                                ? 'Select date'
                                : dateCtrl.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: dateCtrl.text.isEmpty
                                  ? AppColors.textHint
                                  : AppColors.textMain,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _GradBtn(
                        label: 'Schedule',
                        onTap: () {
                          if (nameCtrl.text.isEmpty || dateCtrl.text.isEmpty)
                            return;
                          onAppointmentCreated(
                            Appointment(
                              patientName: nameCtrl.text,
                              purpose: purposeCtrl.text.isEmpty
                                  ? 'Consultation'
                                  : purposeCtrl.text,
                              date: dateCtrl.text,
                              status: 'Scheduled',
                            ),
                          );
                          Navigator.pop(context);
                          onShowToast(
                            'Appointment booked for ${nameCtrl.text}',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    _OutBtn(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _month(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isCompleted = appointment.status == 'Completed';
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.successBg
                  : AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: isCompleted ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  appointment.purpose,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: appointment.status),
              const SizedBox(height: 4),
              Text(
                appointment.date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _Label(String text) => Text(
  text,
  style: GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  ),
);

InputDecoration _dec(String hint) => InputDecoration(
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
