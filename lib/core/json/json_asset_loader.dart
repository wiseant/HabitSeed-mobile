import 'dart:convert';

import 'package:flutter/services.dart';

/// 从 Flutter assets 读取并解码 JSON 的轻量加载器。
class JsonAssetLoader {
  const JsonAssetLoader();

  /// 加载一个顶层为 JSON 对象的资源（如 seeds.json / achievements.json）。
  Future<Map<String, dynamic>> loadObject(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$assetPath 顶层必须是 JSON 对象');
    }
    return decoded;
  }
}
