import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../data/models/seed_definition.dart';
import '../../data/providers.dart';
import '../settings/open_settings.dart';

/// 种子商店（空壳版本）。
///
/// 以响应式网格预览 JSON 种子目录，验证“Repository 读取静态资源”与
/// “网格列数随宽度连续变化”两条链路（正式购买流程在后续里程碑接入）。
class SeedShopScreen extends ConsumerWidget {
  const SeedShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(seedCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('种子商店'),
        actions: const [SettingsAppBarAction()],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('种子目录读取失败：$error')),
        data: (seeds) => seeds.isEmpty
            ? const Center(child: Text('暂无可售种子'))
            : ResponsiveBuilder(
                builder: (context, layout) => CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          '共 ${seeds.length} 种种子，选一颗开启养成之旅。',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: layout.gridColumns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          childCount: seeds.length,
                          (context, index) => _SeedCard(seed: seeds[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SeedCard extends StatelessWidget {
  const _SeedCard({required this.seed});

  final SeedDefinition seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 正式购买 / 详情流程：M3 接入。
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _categoryIcon(seed.category),
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const Spacer(),
                  _RarityBadge(rarity: seed.rarity),
                ],
              ),
              const Spacer(),
              Text(
                seed.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${seed.category.label} · 周期 ${seed.growthDays} 天',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分类 -> 图标。
IconData _categoryIcon(SeedCategory category) => switch (category) {
      SeedCategory.herb => Icons.spa,
      SeedCategory.flower => Icons.local_florist,
      SeedCategory.fruitVegetable => Icons.eco,
      SeedCategory.tree => Icons.forest,
      SeedCategory.fantasy => Icons.auto_awesome,
    };

class _RarityBadge extends StatelessWidget {
  const _RarityBadge({required this.rarity});

  final SeedRarity rarity;

  static const Map<SeedRarity, Color> _colors = {
    SeedRarity.common: Color(0xFF9E9E9E),
    SeedRarity.elegant: Color(0xFF42A5F5),
    SeedRarity.rare: Color(0xFF7E57C2),
    SeedRarity.epic: Color(0xFFFFA726),
    SeedRarity.legendary: Color(0xFFEF5350),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _colors[rarity],
          ),
        ),
        const SizedBox(width: 6),
        Text(rarity.label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
