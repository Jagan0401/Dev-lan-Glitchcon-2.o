import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;
  final Color? subColor;
  final bool fullWidth;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
    this.subColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: fullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(label),
                    const SizedBox(height: 6),
                    _value(value, valueColor),
                  ],
                ),
                if (sub != null) _sub(sub!, subColor),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(label),
                const SizedBox(height: 8),
                _value(value, valueColor),
                if (sub != null) ...[
                  const SizedBox(height: 4),
                  _sub(sub!, subColor),
                ],
              ],
            ),
    );
  }

  Widget _label(String text) => Text(
    text.toUpperCase(),
    style: GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
      letterSpacing: 0.8,
    ),
  );

  Widget _value(String text, Color? color) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: color ?? AppColors.textMain,
    ),
  );

  Widget _sub(String text, Color? color) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textMuted,
    ),
  );
}
