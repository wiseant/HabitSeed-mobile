import 'package:hive_flutter/hive_flutter.dart';

import '../../core/storage/hive_box_names.dart';

/// 应用启动引导。
///
/// - SRS 1.4 / 4.1：动态业务数据使用 Hive 本地存储；
/// - 必须在 runApp 之前完成，保证首个 Widget 构建时即可读写各 Box。
Future<void> bootstrap() async {
  await Hive.initFlutter();
  for (final boxName in HiveBoxNames.all) {
    await Hive.openBox(boxName);
  }
}
