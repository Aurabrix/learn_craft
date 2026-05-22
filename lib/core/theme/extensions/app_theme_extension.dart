import 'package:flutter/material.dart';
import 'package:learn_craft/core/theme/app_colors.dart';

// Holds brand-specific tokens that don't map to Material's ColorScheme.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.brandAccent,
    required this.surface2,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color brandAccent;
  final Color surface2;
  final Color border;
  final Color success;
  final Color warning;
  final Color info;

  static const light = AppThemeExtension(
    brandAccent: AppColors.brandAccent,
    surface2: AppColors.lightSurface2,
    border: AppColors.lightBorder,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  static const dark = AppThemeExtension(
    brandAccent: AppColors.brandAccent,
    surface2: AppColors.darkSurface2,
    border: AppColors.darkBorder,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  @override
  AppThemeExtension copyWith({
    Color? brandAccent,
    Color? surface2,
    Color? border,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppThemeExtension(
      brandAccent: brandAccent ?? this.brandAccent,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// Convenience accessor on BuildContext.
extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
