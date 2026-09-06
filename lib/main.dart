import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'app/habitseed_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 先完成本地存储（Hive）初始化，再启动 UI（SRS 1.4）。
  await bootstrap();

  runApp(const ProviderScope(child: HabitSeedApp()));
}
