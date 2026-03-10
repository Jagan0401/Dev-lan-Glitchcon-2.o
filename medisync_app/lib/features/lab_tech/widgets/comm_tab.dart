import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lab_tech_models.dart';
import 'lab_tech_shared.dart';

class CommTab extends StatelessWidget {
  final List<CommLog> logs;
  final void Function(String) onToast;

  const CommTab({super.key, required this.logs, required this.onToast});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Patient Interaction Log',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            TechSmallBtn(
              label: '+ Compose',
              primary: true,
              onTap: () => _showComposeSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TechSectionCard(
          title: 'Recent Messages',
          child: Column(
            children: logs.asMap().entries.map((e) {
              final isLast = e.key == logs.length - 1;
              final log = e.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySubtle,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        log.patientName.substring(0, 1),
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
                            log.patientName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain,
                            ),
                          ),
                          Text(
                            log.lastMessage,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SampleStatusBadge(label: log.status),
                        const SizedBox(height: 3),
                        Text(
                          log.channel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showComposeSheet(BuildContext context) {
    final msgCtrl = TextEditingController();
    String patient = 'Ravi Kumar';
    String channel = 'WhatsApp';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TechSheet(
            title: 'Compose Patient Message',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Select Patient', style: _lbl),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: patient,
                  decoration: techInputDec(),
                  onChanged: (v) => setSt(() => patient = v!),
                  items: ['Ravi Kumar', 'Arjun Patel', 'Neha Sharma']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text('Channel', style: _lbl),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: channel,
                  decoration: techInputDec(),
                  onChanged: (v) => setSt(() => channel = v!),
                  items: ['WhatsApp', 'SMS']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text('Message Content', style: _lbl),
                const SizedBox(height: 6),
                TextField(
                  controller: msgCtrl,
                  maxLines: 3,
                  decoration: techInputDec(
                    hint: 'Hello, I will be arriving in 15 minutes…',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TechPrimaryBtn(
                        label: 'Send Message',
                        onTap: () {
                          if (msgCtrl.text.isEmpty) return;
                          Navigator.pop(context);
                          onToast('Message sent to $patient via AI Gateway.');
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
      ),
    );
  }

  TextStyle get _lbl => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );
}
