import 'package:flutter/material.dart';

/// Consistent spacing system based on 4px grid
abstract final class AppSpacing {
  // Base unit
  static const double unit = 4.0;

  // Spacing values
  static const double xxs = unit; // 4
  static const double xs = unit * 2; // 8
  static const double sm = unit * 3; // 12
  static const double md = unit * 4; // 16
  static const double lg = unit * 6; // 24
  static const double xl = unit * 8; // 32
  static const double xxl = unit * 12; // 48

  // Common padding configurations
  static const screenPadding = EdgeInsets.symmetric(horizontal: md);
  static const cardPadding = EdgeInsets.all(md);
  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // Border radius
  static const radiusSm = 6.0;
  static const radiusMd = 10.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
  static const radiusFull = 999.0;
}

/// SizedBox shortcuts for spacing
class Gap extends StatelessWidget {
  final double size;

  const Gap.xxs({super.key}) : size = AppSpacing.xxs;
  const Gap.xs({super.key}) : size = AppSpacing.xs;
  const Gap.sm({super.key}) : size = AppSpacing.sm;
  const Gap.md({super.key}) : size = AppSpacing.md;
  const Gap.lg({super.key}) : size = AppSpacing.lg;
  const Gap.xl({super.key}) : size = AppSpacing.xl;
  const Gap.xxl({super.key}) : size = AppSpacing.xxl;

  const Gap(this.size, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
