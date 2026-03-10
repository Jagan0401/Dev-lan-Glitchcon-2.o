import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';

class LogSampleSheet extends StatefulWidget {
  final CollectionTask task;
  final void Function(String) onToast;

  const LogSampleSheet({super.key, required this.task, required this.onToast});

  static void show(
    BuildContext context,
    CollectionTask task,
    void Function(String) onToast,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogSampleSheet(task: task, onToast: onToast),
    );
  }

  @override
  State<LogSampleSheet> createState() => _LogSampleSheetState();
}

class _LogSampleSheetState extends State<LogSampleSheet> {
  final _idCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _idCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TechSheet(
        title: 'Log Collection Sample',
        subtitle: '${widget.task.patientName} · ${widget.task.testName}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sample ID', style: _labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _idCtrl,
              decoration: techInputDec(hint: 'Scan barcode or type ID…'),
            ),
            const SizedBox(height: 14),
            Text('Collection Time', style: _labelStyle),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) setState(() => _selectedTime = t);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
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
                        _selectedTime == null
                            ? 'Select time'
                            : _selectedTime!.format(context),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: _selectedTime == null
                              ? AppColors.textHint
                              : AppColors.textMain,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Technician Notes', style: _labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: techInputDec(hint: 'Sample stored in ice pack…'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TechPrimaryBtn(
                    label: 'Log Sample',
                    onTap: () {
                      if (_idCtrl.text.isEmpty || _selectedTime == null) return;
                      Navigator.pop(context);
                      widget.onToast(
                        'Sample ${_idCtrl.text} logged and tracking initiated.',
                      );
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
    );
  }

  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );
}
