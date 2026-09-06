import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive/responsive_layout.dart';
import '../achievements/achievements_screen.dart';
import '../garden/garden_home_screen.dart';
import '../settings/open_settings.dart';
import '../shop/seed_shop_screen.dart';
import 'app_sections.dart';
import 'selected_app_section.dart';

/// 响应式导航空壳（SRS 5 / 9.1）：
///
/// - 宽度 < 840dp：底部 NavigationBar（3-Tab）；
/// - 宽度 >= 840dp：左侧 NavigationRail + 内容区。
///
/// 内容区使用 IndexedStack 常驻各页，避免切换时重建
/// （等价于 SRS 9.3 提出的页面保活要求）。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveBuilder(
      builder: _buildByWidth,
    );
  }

  static Widget _buildByWidth(BuildContext context, ResponsiveLayout layout) {
    return layout.useNavigationRail
        ? const _RailShell()
        : const _TabShell();
  }
}

/// 底部 3-Tab 形态（手机 / 小平板）。
class _TabShell extends ConsumerWidget {
  const _TabShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedAppSectionProvider);
    return Scaffold(
      body: _SectionBody(section: section),
      bottomNavigationBar: NavigationBar(
        selectedIndex: section.index,
        onDestinationSelected: (index) => ref
            .read(selectedAppSectionProvider.notifier)
            .select(AppSection.values[index]),
        destinations: [
          for (final item in AppSection.values)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

/// NavigationRail 形态（平板 / 横屏）。
class _RailShell extends ConsumerWidget {
  const _RailShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedAppSectionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            selectedIndex: section.index,
            onDestinationSelected: (index) => ref
                .read(selectedAppSectionProvider.notifier)
                .select(AppSection.values[index]),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.grass, size: 28, color: colorScheme.primary),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: '设置',
                onPressed: () => openSettings(context),
              ),
            ),
            destinations: [
              for (final item in AppSection.values)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _SectionBody(section: section)),
        ],
      ),
    );
  }
}

/// 常驻的内容宿主：IndexedStack 保持各页状态。
class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.section});

  final AppSection section;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: section.index,
      children: const [
        GardenHomeScreen(),
        SeedShopScreen(),
        AchievementsScreen(),
      ],
    );
  }
}
