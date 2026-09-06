import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_box_names.dart';

/// Hive 顶层门面（通过 Provider 注入，便于测试替换）。
///
/// 空壳阶段只使用原生类型读写；M2 引入业务模型后，
/// 配合 hive_generator 注册 TypeAdapter 即可存入自定义对象。
class HiveStore {
  const HiveStore();

  /// 初始化 Hive 并打开全部业务 Box。
  Future<void> initialize() async {
    await Hive.initFlutter();
    for (final boxName in HiveBoxNames.all) {
      await Hive.openBox(boxName);
    }
  }

  /// 该 Box 当前是否已打开。
  bool isBoxOpen(String boxName) => Hive.isBoxOpen(boxName);

  /// 若 Box 已打开则返回其引用，否则返回 null（避免未初始化时报错）。
  Box<dynamic>? maybeOpenBox(String boxName) =>
      Hive.isBoxOpen(boxName) ? Hive.box(boxName) : null;

  /// Box 内记录条数（未打开时返回 0）。
  int itemCount(String boxName) => maybeOpenBox(boxName)?.length ?? 0;
}

/// 全局 Hive 门面（默认访问真机本地存储）。
final hiveStoreProvider = Provider<HiveStore>((ref) => const HiveStore());
