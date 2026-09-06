import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_assets.dart';
import '../core/json/json_asset_loader.dart';
import '../core/storage/hive_box_names.dart';
import '../core/storage/hive_store.dart';
import 'models/achievement_definition.dart';
import 'models/planted_seed.dart';
import 'models/seed_definition.dart';
import 'repositories/catalog_repository.dart';

/// assets JSON 加载器。
final jsonAssetLoaderProvider =
    Provider<JsonAssetLoader>((ref) => const JsonAssetLoader());

/// 目录数据仓库（本地 JSON 实现）。
final catalogRepositoryProvider = Provider<JsonCatalogRepository>(
  (ref) => JsonCatalogRepository(
    assetLoader: ref.watch(jsonAssetLoaderProvider),
    seedsAssetPath: AppAssets.seedsJson,
    achievementsAssetPath: AppAssets.achievementsJson,
  ),
);

/// 种子目录（首次启动从 assets/seeds.json 读取）。
final seedCatalogProvider = FutureProvider<List<SeedDefinition>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchSeeds(),
);

/// 成就定义（从 assets/achievements.json 读取）。
final achievementCatalogProvider = FutureProvider<List<AchievementDefinition>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchAchievements(),
);

/// 成就花园收藏（SRS 2.4）：读取 planted_seeds 中所有 harvested 档案。
///
/// 每株完整走完生长周期并成功开花的植物在收获瞬间被标记为 harvested，
/// 自动“移入”成就花园；本 Provider 即成就花园的已开花植物数据源。
/// 空壳阶段无写入方，恒为空列表；M4 收获动作落地后无需改此处即可出数。
final bloomedPlantsProvider = FutureProvider<List<PlantedSeed>>((ref) async {
  final store = ref.watch(hiveStoreProvider);
  final box = store.maybeOpenBox(HiveBoxNames.plantedSeeds);
  if (box == null) return const <PlantedSeed>[];

  final blooms = <PlantedSeed>[];
  for (final raw in box.values) {
    if (raw is! Map) continue;
    final record =
        PlantedSeed.tryFromMap(Map<String, dynamic>.from(raw));
    if (record != null && record.status == PlantStatus.harvested) {
      blooms.add(record);
    }
  }
  // 开花时间倒序（缺失时退回种植时间），最新收藏排最前。
  blooms.sort((a, b) {
    final aTime = a.bloomedAt ?? a.plantedDate;
    final bTime = b.bloomedAt ?? b.plantedDate;
    return bTime.compareTo(aTime);
  });
  return List<PlantedSeed>.unmodifiable(blooms);
});
