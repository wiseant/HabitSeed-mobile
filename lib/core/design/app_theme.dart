import 'package:flutter/material.dart';

/// HabitSeed 品牌色（植物 / 成长主题）。
abstract final class AppColors {
  /// 主色：破土新芽绿。
  static const Color seedGreen = Color(0xFF4CAF50);

  /// 辅助色：土壤棕。
  static const Color soilBrown = Color(0xFF8D6E63);

  /// 辅助色：晨光蓝。
  static const Color morningSky = Color(0xFF4FC3F7);
}

/// 应用主题：Material 3 + 品牌绿色调（SRS 9.2 无深色/跟随系统主题）。
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.seedGreen);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
