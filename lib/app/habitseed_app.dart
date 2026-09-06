import 'package:flutter/material.dart';

import '../core/design/app_theme.dart';
import '../features/shell/app_shell.dart';

/// HabitSeed 应用根组件。
class HabitSeedApp extends StatelessWidget {
  const HabitSeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitSeed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
