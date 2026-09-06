import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async/async_value_ext.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/storage/hive_box_names.dart';
import '../../core/storage/hive_store.dart';
import '../../data/providers.dart';
import '../settings/open_settings.dart';
import '../shell/app_sections.dart';
import '../shell/selected_app_section.dart';

/// 花园首页（空壳版本）。
///
/// 尚未接入种植逻辑，先提供：
/// - 空态引导（去种子商店）；
/// - 调试期“环境自检”面板，直观验证 Hive / JSON / 响应式引擎均已打通。
class GardenHomeScreen extends ConsumerWidget {
  const GardenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('花园'),
        actions: const [SettingsAppBarAction()],
      ),
      body: ResponsiveBuilder(
        builder: (context, layout) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _EmptyGardenCard(
              onGoShop: () => ref
                  .read(selectedAppSectionProvider.notifier)
                  .select(AppSection.shop),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              _EnvironmentPanel(ref: ref, layout: layout),
            ],
          ],
        ),
      ),
    );
  }
}

/// 空态卡片：引导用户前往种子商店。
class _EmptyGardenCard extends StatelessWidget {
  const _EmptyGardenCard({required this.onGoShop});

  final VoidCallback onGoShop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(Icons.spa_outlined, size: 56, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text('花园还是空的', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '选一颗种子，把想坚持的事种下去；\n按时浇灌，让它慢慢长大。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onGoShop,
              icon: const Icon(Icons.add),
              label: const Text('去种子商店'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 环境自检面板（仅调试构建显示）。
class _EnvironmentPanel extends StatelessWidget {
  const _EnvironmentPanel({required this.ref, required this.layout});

  final WidgetRef ref;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    final hive = ref.watch(hiveStoreProvider);
    final openCount =
        HiveBoxNames.all.where(hive.isBoxOpen).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('环境自检（仅调试）',
                    style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(
              label: '本地存储',
              value:
                  'Hive $openCount/${HiveBoxNames.all.length} 个 Box 已就绪',
            ),
            _InfoLine(
              label: '种子目录',
              value: ref.watch(seedCatalogProvider).countSummary,
            ),
            _InfoLine(
              label: '成就定义',
              value: ref.watch(achievementCatalogProvider).countSummary,
            ),
            _InfoLine(
              label: '当前布局',
              value:
                  '${layout.formFactor.name} · 网格 ${layout.gridColumns} 列 · '
                  '可用宽 ${layout.maxWidth.round()}px',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
