import 'package:flutter/material.dart';
import 'package:learn_craft/core/theme/app_colors.dart';

// ── Label above input field (ALL CAPS, Duolingo style) ───────
class DuoLabel extends StatelessWidget {
  const DuoLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.labelGrey,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Input field (rounded, light-gray fill, 2px border) ───────
class DuoTextField extends StatelessWidget {
  const DuoTextField({
    super.key,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.chevronGrey,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true,
        fillColor: AppColors.greyBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyLight, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
    );
  }
}

// ── Green 3D button (Duolingo signature style) ─────────────
class DuoGreenButton extends StatelessWidget {
  const DuoGreenButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.greyLight : AppColors.green,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDisabled ? AppColors.chevronGrey : AppColors.greenShadow,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDisabled ? AppColors.labelGrey : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ── Outlined button (Duolingo 3D style) ─────────────────────
class DuoOutlinedButton extends StatelessWidget {
  const DuoOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.borderGrey,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ── Back button (chevron, bordered) ──────────────────────────
class DuoBackButton extends StatelessWidget {
  const DuoBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyLight, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.greyLight,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          color: AppColors.dark,
          size: 26,
        ),
      ),
    );
  }
}
