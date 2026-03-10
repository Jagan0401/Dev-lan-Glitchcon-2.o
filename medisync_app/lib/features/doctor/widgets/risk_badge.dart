import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_dashboard_models.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel risk;

  const RiskBadge({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        risk.label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  (Color bg, Color fg) _colors(RiskLevel r) => switch (r) {
    RiskLevel.critical => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    RiskLevel.high => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    RiskLevel.medium => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
    RiskLevel.low => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
  };
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  (Color bg, Color fg) _colors(String s) => switch (s.toLowerCase()) {
    'completed' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    'scheduled' => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
    'cancelled' => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    _ => (const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
  };
}
