import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';

/// Mirrors the HTML "Assign Report Details" modal with all 8 fields.
class AssignReportSheet extends StatefulWidget {
  final CollectionTask task;
  final void Function(String) onToast;

  const AssignReportSheet({
    super.key,
    required this.task,
    required this.onToast,
  });

  static void show(
    BuildContext context,
    CollectionTask task,
    void Function(String) onToast,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignReportSheet(task: task, onToast: onToast),
    );
  }

  @override
  State<AssignReportSheet> createState() => _AssignReportSheetState();
}

class _AssignReportSheetState extends State<AssignReportSheet> {
  late final TextEditingController _pidCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _diseaseCtrl;
  late final TextEditingController _testCtrl;
  late final TextEditingController _lastResCtrl;
  late final TextEditingController _docIdCtrl;
  DateTime? _lastTestDate;

  @override
  void initState() {
    super.initState();
    _pidCtrl = TextEditingController(text: widget.task.patientId);
    _nameCtrl = TextEditingController(text: widget.task.patientName);
    _ageCtrl = TextEditingController(text: widget.task.age);
    _diseaseCtrl = TextEditingController(text: widget.task.condition);
    _testCtrl = TextEditingController(text: widget.task.testName);
    _lastResCtrl = TextEditingController();
    _docIdCtrl = TextEditingController(text: 'DOC-4920');
  }

  @override
  void dispose() {
    for (final c in [
      _pidCtrl,
      _nameCtrl,
      _ageCtrl,
      _diseaseCtrl,
      _testCtrl,
      _lastResCtrl,
      _docIdCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
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
              const SizedBox(height: 14),
              Text(
                'Assign Report Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Complete the diagnostic patient record details.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  children: [
                    // 2-col grid on wide screens, stack on narrow
                    LayoutBuilder(
                      builder: (_, bc) {
                        final twoCol = bc.maxWidth > 400;
                        final fields = [
                          _Field('Patient ID', _pidCtrl, readonly: true),
                          _Field('Patient Name', _nameCtrl, readonly: true),
                          _Field('Age', _ageCtrl, kbType: TextInputType.number),
                          _Field(
                            'Disease',
                            _diseaseCtrl,
                            hint: 'Primary condition',
                          ),
                          _Field(
                            'Test Required',
                            _testCtrl,
                            hint: 'Type of test',
                          ),
                          _Field(
                            'Last Result',
                            _lastResCtrl,
                            hint: 'Previous findings',
                          ),
                          _Field(
                            'Doctor ID',
                            _docIdCtrl,
                            hint: 'Assigned physician ID',
                          ),
                        ];
                        if (twoCol) {
                          final rows = <Widget>[];
                          for (var i = 0; i < fields.length; i += 2) {
                            rows.add(
                              Row(
                                children: [
                                  Expanded(
                                    child: fields[i].build(context, this),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: i + 1 < fields.length
                                        ? fields[i + 1].build(context, this)
                                        : _dateField(context),
                                  ),
                                ],
                              ),
                            );
                            rows.add(const SizedBox(height: 12));
                          }
                          if (fields.length.isEven) {
                            rows.add(_dateField(context));
                            rows.add(const SizedBox(height: 12));
                          }
                          return Column(children: rows);
                        } else {
                          return Column(
                            children: [
                              ...fields.map(
                                (f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: f.build(context, this),
                                ),
                              ),
                              _dateField(context),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TechPrimaryBtn(
                            label: 'Assign to Patient Record',
                            onTap: _submit,
                          ),
                        ),
                        const SizedBox(width: 10),
                        TechOutlineBtn(
                          label: 'Cancel',
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Test Date',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 30)),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (d != null) setState(() => _lastTestDate = d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _lastTestDate == null
                        ? 'Select date'
                        : '${_lastTestDate!.day}/${_lastTestDate!.month}/${_lastTestDate!.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: _lastTestDate == null
                          ? AppColors.textHint
                          : AppColors.textMain,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    Navigator.pop(context);
    widget.onToast(
      'Patient report finalized for ${widget.task.patientName}. Data synced to EMR.',
    );
  }
}

class _Field {
  final String label;
  final TextEditingController ctrl;
  final String? hint;
  final bool readonly;
  final TextInputType kbType;

  const _Field(
    this.label,
    this.ctrl, {
    this.hint,
    this.readonly = false,
    this.kbType = TextInputType.text,
  });

  Widget build(BuildContext context, State state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        readOnly: readonly,
        keyboardType: kbType,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: techInputDec(
          hint: hint,
        ).copyWith(fillColor: readonly ? AppColors.surface : null),
      ),
    ],
  );
}
