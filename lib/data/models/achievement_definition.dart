import 'package:flutter/foundation.dart';

/// 成就定义（SRS 2.6 静态数据，来源 assets/achievements.json）。
@immutable
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.criteria,
  });

  final String id;
  final String name;
  final String description;

  /// UI 图标标识（Material Icons 名称，后续接入图标映射）。
  final String icon;

  /// 达成条件（type/target/rarity 等字段，解锁判定在 M5 消费）。
  final Map<String, Object?> criteria;

  /// 宽容解析：字段非法/缺失返回 null。
  static AchievementDefinition? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.isEmpty) return null;

    return AchievementDefinition(
      id: id,
      name: name,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      criteria: Map<String, Object?>.unmodifiable(
        json['criteria'] is Map
            ? Map<String, Object?>.from(json['criteria'] as Map)
            : const <String, Object?>{},
      ),
    );
  }
}
