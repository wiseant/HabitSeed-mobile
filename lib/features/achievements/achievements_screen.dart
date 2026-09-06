import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../data/models/achievement_definition.dart';
import '../../data/models/planted_seed.dart';
import '../../data/models/seed_definition.dart';
import '../../data/providers.dart';
import '../settings/open_settings.dart';

/// 成就花园（SRS 2.4）。
///
/// 页面分两层：
/// 1. **已开花植物**：每一株完整走完生长周期并成功开花的植物自动移入，
///    展示种子名称、稀有度、习惯名称、坚持总天数、开花日期与最终形态
///    （数据源 `bloomedPlantsProvider`，读取 planted_seeds 中 harvested 档案）。
/// 2. **成就**：系统依据种植记录自动判定解锁，定义来自 assets/achievements.json。
///
/// 页面尾部保留“纪念花园”子区说明（SRS 2.5）。
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blooms = ref.watch(bloomedPlantsProvider);
    final achievements = ref.watch(achievementCatalogProvider);
    final seeds = ref.watch(seedCatalogProvider);
    final seedsById = <String, SeedDefinition>{
      for (final seed in seeds.value ?? const <SeedDefinition>[])
        seed.id: seed,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就花园'),
        actions: const [SettingsAppBarAction()],
      ),
      body: ResponsiveBuilder(
        builder: (context, layout) => CustomScrollView(
          slivers: [
            // ── 区块 1：已开花植物收藏（SRS 2.4 自动移入）──
            _SectionHeader(
              title: '已开花植物',
              trailing: _countLabel(blooms, '株'),
            ),
            ..._bloomedSlivers(context, layout, blooms, seedsById),

            // ── 区块 2：成就解锁（同样来自 SRS 2.4）──
            const _SectionHeader(title: '成就'),
            ..._achievementSlivers(context, layout, achievements),

            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverToBoxAdapter(child: _MemorialHintCard()),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// 区块 1：已开花植物
// ──────────────────────────────────────────────────────────────────────────

List<Widget> _bloomedSlivers(
  BuildContext context,
  ResponsiveLayout layout,
  AsyncValue<List<PlantedSeed>> blooms,
  Map<String, SeedDefinition> seedsById,
) {
  return blooms.when(
    loading: () => const [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
        sliver: SliverToBoxAdapter(
          child: Center(child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ),
    ],
    error: (error, _) => [
      _InlineMessage(icon: Icons.error_outline, message: '收藏记录读取失败：$error'),
    ],
    data: (plants) {
      if (plants.isEmpty) {
        return const [
          _InlineMessage(
            icon: Icons.auto_awesome_outlined,
            title: '还没有已开花的植物',
            message: '植物完整走完生长周期并成功开花后，会自动移入这里，'
                '成为你的专属收藏档案。',
          ),
        ];
      }

      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.gridColumns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            delegate: SliverChildBuilderDelegate(
              childCount: plants.length,
              (context, index) {
                final plant = plants[index];
                return _BloomedPlantCard(
                  plant: plant,
                  seed: seedsById[plant.seedId],
                );
              },
            ),
          ),
        ),
      ];
    },
  );
}

/// 已开花（harvested）植物收藏卡片：种子名、稀有度、习惯名、坚持天数、
/// 开花日期、最终形态图标。最终形态图片资源（seed.finalStageImage）在
/// 资产就绪后替换此占位图标。
class _BloomedPlantCard extends StatelessWidget {
  const _BloomedPlantCard({required this.plant, this.seed});

  final PlantedSeed plant;
  final SeedDefinition? seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seedName = seed?.name ?? '未知种子';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _categoryIcon(seed?.category),
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const Spacer(),
                if (seed != null) _RarityTag(rarity: seed!.rarity),
              ],
            ),
            const Spacer(),
            Text(
              plant.habitName,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$seedName · 坚持 ${plant.totalWaterDays} 天',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_florist_outlined,
                  size: 14,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '开花于 ${_formatDate(plant.bloomedAt)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(SeedCategory? category) => switch (category) {
      SeedCategory.herb => Icons.eco,
      SeedCategory.flower => Icons.local_florist,
      SeedCategory.fruitVegetable => Icons.agriculture,
      SeedCategory.tree => Icons.park,
      SeedCategory.fantasy => Icons.auto_awesome,
      null => Icons.emoji_nature,
    };

/// 稀有度徽标（与商店页保持同套色板）。
class _RarityTag extends StatelessWidget {
  const _RarityTag({required this.rarity});

  final SeedRarity rarity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _rarityColor(rarity).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _rarityColor(rarity),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            rarity.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _rarityColor(rarity),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

Color _rarityColor(SeedRarity rarity) => switch (rarity) {
      SeedRarity.common => const Color(0xFF9E9E9E),
      SeedRarity.elegant => const Color(0xFF26A69A),
      SeedRarity.rare => const Color(0xFF42A5F5),
      SeedRarity.epic => const Color(0xFFAB47BC),
      SeedRarity.legendary => const Color(0xFFFFA726),
    };

String _formatDate(DateTime? time) {
  if (time == null) return '—';
  final local = time.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}';
}

// ──────────────────────────────────────────────────────────────────────────
// 区块 2：成就解锁
// ──────────────────────────────────────────────────────────────────────────

List<Widget> _achievementSlivers(
  BuildContext context,
  ResponsiveLayout layout,
  AsyncValue<List<AchievementDefinition>> achievements,
) {
  return achievements.when(
    loading: () => const [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
        sliver: SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    ],
    error: (error, _) => [
      _InlineMessage(icon: Icons.error_outline, message: '成就数据读取失败：$error'),
    ],
    data: (list) => [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        sliver: SliverToBoxAdapter(
          child: Text(
            '基于你的已开花植物与坚持记录，系统会自动判定并解锁成就。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: layout.gridColumns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          delegate: SliverChildBuilderDelegate(
            childCount: list.length,
            (context, index) => _AchievementCard(achievement: list[index]),
          ),
        ),
      ),
    ],
  );
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final AchievementDefinition achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconFor(achievement.icon),
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const Spacer(),
            Text(
              achievement.name,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(String token) => switch (token) {
      'spa' => Icons.spa,
      'eco' => Icons.eco,
      'local_fire_department' => Icons.local_fire_department,
      'auto_awesome' => Icons.auto_awesome,
      _ => Icons.emoji_events,
    };

// ──────────────────────────────────────────────────────────────────────────
// 公共小部件
// ──────────────────────────────────────────────────────────────────────────

/// 区块标题（含可选数量角标）。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

/// 区内空态 / 错误提示卡。
class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.icon, this.title, required this.message});

  final IconData icon;
  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            title!,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 纪念花园子区占位说明（SRS 2.5）。
class _MemorialHintCard extends StatelessWidget {
  const _MemorialHintCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(Icons.park_outlined, color: theme.colorScheme.primary),
        title: const Text('纪念花园'),
        subtitle: const Text('为已离开的植物保留一片回忆（后续里程碑接入）'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String? _countLabel<T>(AsyncValue<List<T>> value, String unit) =>
    switch (value) {
      AsyncData(:final value) => '共 ${value.length} $unit',
      _ => null,
    };
