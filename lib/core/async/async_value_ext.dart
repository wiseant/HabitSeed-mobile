import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AsyncValue 便捷文案扩展（空壳演示期使用）。
extension AsyncValueSummary on AsyncValue {
  /// 将 List 类数据的结果转成“N 项 / 加载中… / 读取失败”的简短文案。
  String get countSummary => switch (this) {
        AsyncData(:final value) => '${(value as List).length} 项',
        AsyncError() => '读取失败',
        AsyncLoading() => '加载中…',
      };
}
