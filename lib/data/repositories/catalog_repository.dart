import '../../core/json/json_asset_loader.dart';
import '../models/achievement_definition.dart';
import '../models/seed_definition.dart';

/// 种子目录数据源抽象（SRS 2.7 Repository 模式）。
///
/// MVP 阶段实现为本地 JSON；后续若接入远端 API，
/// 新增实现类即可，UI 层无需改动。
abstract interface class SeedDataSource {
  Future<List<SeedDefinition>> fetchSeeds();
}

/// 成就定义数据源抽象。
abstract interface class AchievementDataSource {
  Future<List<AchievementDefinition>> fetchAchievements();
}

/// 本地 JSON 实现：解析 assets 下的静态目录配置。
class JsonCatalogRepository
    implements SeedDataSource, AchievementDataSource {
  const JsonCatalogRepository({
    required this.assetLoader,
    required this.seedsAssetPath,
    required this.achievementsAssetPath,
  });

  final JsonAssetLoader assetLoader;
  final String seedsAssetPath;
  final String achievementsAssetPath;

  @override
  Future<List<SeedDefinition>> fetchSeeds() async {
    final root = await assetLoader.loadObject(seedsAssetPath);
    final rawSeeds = root['seeds'];
    if (rawSeeds is! List) return const [];

    return rawSeeds
        .whereType<Map<String, dynamic>>()
        .map(SeedDefinition.tryFromJson)
        .whereType<SeedDefinition>()
        .toList(growable: false);
  }

  @override
  Future<List<AchievementDefinition>> fetchAchievements() async {
    final root = await assetLoader.loadObject(achievementsAssetPath);
    final rawAchievements = root['achievements'];
    if (rawAchievements is! List) return const [];

    return rawAchievements
        .whereType<Map<String, dynamic>>()
        .map(AchievementDefinition.tryFromJson)
        .whereType<AchievementDefinition>()
        .toList(growable: false);
  }
}
