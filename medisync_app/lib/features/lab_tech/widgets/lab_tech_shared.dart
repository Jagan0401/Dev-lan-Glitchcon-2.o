/// Shared primitives reused across all lab-tech tab widgets.
/// Avoids copy-pasting the same _PrimaryBtn / _OutlineBtn / _inputDec
/// that appear in the doctor tabs — keeping the codebase DRY.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

// ─── Buttons ─────────────────────────────────────────────────────────────────

class TechPrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool fullWidth;

  const TechPrimaryBtn({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    final darkColor = isDestructive
        ? const Color(0xFFDC2626)
        : AppColors.primaryDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, darkColor]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TechOutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const TechOutlineBtn({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
    ),
  );
}

class TechSmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  const TechSmallBtn({
    super.key,
    required this.label,
    this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: primary ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primary ? AppColors.primary : AppColors.divider,
        ),
        boxShadow: primary
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: primary ? Colors.white : AppColors.textMain,
        ),
      ),
    ),
  );
}

// ─── Input decoration ─────────────────────────────────────────────────────────

InputDecoration techInputDec({String? hint, Widget? suffix}) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: AppColors.surface,
  suffixIcon: suffix,
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

// ─── Bottom sheet container ───────────────────────────────────────────────────

class TechSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const TechSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
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
          // Handle bar
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
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textMain,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Info row (label + value) ─────────────────────────────────────────────────

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: mono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMain,
                  )
                : GoogleFonts.plusJakartaSans(
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

// ─── Section card (header + divider + body) ───────────────────────────────────

class TechSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const TechSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.textMain,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

// ─── Sample / collection status badge ────────────────────────────────────────

class SampleStatusBadge extends StatelessWidget {
  final String label;

  const SampleStatusBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _palette(label.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  (Color, Color) _palette(String s) => switch (s) {
    'completed' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    'collected' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    'report finalised' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    'delivered' => (const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
    'in transit' => (const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),
    'in progress' => (const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
    'scheduled' => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
    'confirmed' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    'sent' => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
    _ => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
  };
}
