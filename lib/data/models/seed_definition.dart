import 'package:flutter/foundation.dart';

/// 种子分类（对应 seeds.json 的 `category` 字段）。
enum SeedCategory {
  herb('herb', '草本'),
  flower('flower', '花卉'),
  fruitVegetable('fruit_vegetable', '果蔬'),
  tree('tree', '树木'),
  fantasy('fantasy', '幻境');

  const SeedCategory(this.storageValue, this.label);

  /// JSON 中的存储值。
  final String storageValue;

  /// UI 展示文案。
  final String label;

  static SeedCategory fromValue(String? value) => values.firstWhere(
        (category) => category.storageValue == value,
        orElse: () => SeedCategory.herb,
      );
}

/// 种子稀有度（对应 seeds.json 的 `rarity` 字段）。
enum SeedRarity {
  common('common', '寻常'),
  elegant('elegant', '清雅'),
  rare('rare', '珍奇'),
  epic('epic', '史诗'),
  legendary('legendary', '传说');

  const SeedRarity(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static SeedRarity fromValue(String? value) => values.firstWhere(
        (rarity) => rarity.storageValue == value,
        orElse: () => SeedRarity.common,
      );
}

/// 种子定义（SRS 2.1：静态目录数据，来源 assets/seeds.json）。
@immutable
class SeedDefinition {
  const SeedDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.growthDays,
    required this.stopThreshold,
    required this.deadThreshold,
    required this.finalStageImage,
  });

  final String id;
  final String name;
  final SeedCategory category;
  final SeedRarity rarity;

  /// 生长周期（天）。
  final int growthDays;

  /// 连续未浇灌到达该天数 -> 停长。
  final int stopThreshold;

  /// 连续未浇灌到达该天数 -> 枯萎。
  final int deadThreshold;

  /// 最终开花形态图片资源路径。
  final String finalStageImage;

  /// 宽容解析：字段非法/缺失返回 null（由调用方过滤脏数据）。
  static SeedDefinition? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final growthDays = _asInt(json['growthDays']);
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.isEmpty) return null;
    if (growthDays == null || growthDays <= 0) return null;

    final stop = _asInt(json['stopThreshold']) ?? 3;
    // 枯萎阈值必须严格大于停长阈值（SRS 2.1 约束下的最小宽松值）。
    final rawDead = _asInt(json['deadThreshold']) ?? (stop + 2);
    final dead = rawDead > stop ? rawDead : stop + 2;

    return SeedDefinition(
      id: id,
      name: name,
      category: SeedCategory.fromValue(json['category'] as String?),
      rarity: SeedRarity.fromValue(json['rarity'] as String?),
      growthDays: growthDays,
      stopThreshold: stop,
      deadThreshold: dead,
      finalStageImage: json['finalStageImage'] as String? ?? '',
    );
  }

  static int? _asInt(Object? value) => value is int ? value : null;
}
