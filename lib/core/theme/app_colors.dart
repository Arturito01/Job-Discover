import 'package:flutter/material.dart';

/// Design system colors inspired by modern job platforms
/// Clean, professional palette with strong accent for CTAs
/// Supports both light and dark themes
abstract final class AppColors {
  // Primary brand colors (same for both themes)
  static const primary = Color(0xFF2563EB); // Blue 600
  static const primaryLight = Color(0xFF3B82F6); // Blue 500
  static const primaryDark = Color(0xFF1D4ED8); // Blue 700

  // Semantic colors (same for both themes)
  static const success = Color(0xFF10B981); // Emerald 500
  static const warning = Color(0xFFF59E0B); // Amber 500
  static const error = Color(0xFFEF4444); // Red 500

  // ============ LIGHT THEME ============
  // Neutral palette - Light
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF3F4F6);

  // Text colors - Light
  static const textPrimary = Color(0xFF111827); // Gray 900
  static const textSecondary = Color(0xFF6B7280); // Gray 500
  static const textTertiary = Color(0xFF9CA3AF); // Gray 400

  // Border and dividers - Light
  static const border = Color(0xFFE5E7EB); // Gray 200
  static const divider = Color(0xFFF3F4F6); // Gray 100

  // Job type badges - Light
  static const badgeRemote = Color(0xFFDCFCE7); // Green 100
  static const badgeRemoteText = Color(0xFF166534); // Green 800
  static const badgeFullTime = Color(0xFFDBEAFE); // Blue 100
  static const badgeFullTimeText = Color(0xFF1E40AF); // Blue 800
  static const badgeContract = Color(0xFFFEF3C7); // Amber 100
  static const badgeContractText = Color(0xFF92400E); // Amber 800

  // ============ DARK THEME ============
  // Neutral palette - Dark
  static const backgroundDark = Color(0xFF0F172A); // Slate 900
  static const surfaceDark = Color(0xFF1E293B); // Slate 800
  static const surfaceVariantDark = Color(0xFF334155); // Slate 700

  // Text colors - Dark
  static const textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const textTertiaryDark = Color(0xFF64748B); // Slate 500

  // Border and dividers - Dark
  static const borderDark = Color(0xFF334155); // Slate 700
  static const dividerDark = Color(0xFF1E293B); // Slate 800

  // Job type badges - Dark (more saturated for visibility)
  static const badgeRemoteDark = Color(0xFF064E3B); // Emerald 900
  static const badgeRemoteTextDark = Color(0xFF6EE7B7); // Emerald 300
  static const badgeFullTimeDark = Color(0xFF1E3A8A); // Blue 900
  static const badgeFullTimeTextDark = Color(0xFF93C5FD); // Blue 300
  static const badgeContractDark = Color(0xFF78350F); // Amber 900
  static const badgeContractTextDark = Color(0xFFFCD34D); // Amber 300
}

/// Extension to get theme-aware colors
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? AppColors.backgroundDark : AppColors.background;

  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surface;

  Color get surfaceVariantColor =>
      isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;

  Color get textPrimaryColor =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;

  Color get textSecondaryColor =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

  Color get textTertiaryColor =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiary;

  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.border;

  Color get dividerColor =>
      isDarkMode ? AppColors.dividerDark : AppColors.divider;
}
