import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/auth_user.dart';

class RoleDropdown extends StatelessWidget {
  final UserRole? value;
  final ValueChanged<UserRole?> onChanged;

  const RoleDropdown({super.key, required this.value, required this.onChanged});

  static const _roles = UserRole.values;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      initialValue: value,
      onChanged: onChanged,
      hint: Text(
        'Select Role',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.textHint,
        ),
      ),
      icon: const Icon(
        Icons.expand_more_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.badge_outlined,
          size: 18,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppColors.textMain,
        fontWeight: FontWeight.w500,
      ),
      validator: (v) => v == null ? 'Please select your role' : null,
      items: _roles.map((role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _roleColor(role),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(role.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _roleColor(UserRole role) => switch (role) {
    UserRole.doctor => AppColors.doctorColor,
    UserRole.coordinator => AppColors.coordinatorColor,
    UserRole.hospitalAdmin => AppColors.adminColor,
    UserRole.labTechnician => AppColors.technicianColor,
    UserRole.superAdmin => AppColors.superAdminColor,
  };
}
