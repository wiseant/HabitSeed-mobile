import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habitseed/app/habitseed_app.dart';
import 'package:habitseed/core/responsive/responsive_layout.dart';
import 'package:habitseed/data/models/achievement_definition.dart';
import 'package:habitseed/data/models/seed_definition.dart';
import 'package:habitseed/data/providers.dart';

/// 目录数据 fixtures：注入内存数据，避免 widget 测试依赖真实 assets
/// （flutter_test 的 asset 通道在同一进程多次加载存在挂起/转圈常驻问题，
/// 会导致后续用例的 pumpAndSettle 超时）。
const _seedFixtures = <SeedDefinition>[
  SeedDefinition(
    id: 'mint',
    name: '小薄荷',
    category: SeedCategory.herb,
    rarity: SeedRarity.common,
    growthDays: 5,
    stopThreshold: 2,
    deadThreshold: 4,
    finalStageImage: 'assets/images/mint_bloom.png',
  ),
  SeedDefinition(
    id: 'sunflower',
    name: '向日葵',
    category: SeedCategory.flower,
    rarity: SeedRarity.epic,
    growthDays: 8,
    stopThreshold: 3,
    deadThreshold: 5,
    finalStageImage: 'assets/images/sunflower_bloom.png',
  ),
];

const _achievementFixtures = <AchievementDefinition>[
  AchievementDefinition(
    id: 'first_bloom',
    name: '初次绽放',
    description: '收获第一株已开花植物',
    icon: 'spa',
    criteria: {},
  ),
];

Widget _appUnderTest({required Widget child}) => ProviderScope(
      overrides: [
        seedCatalogProvider
            .overrideWith((ref) async => List.unmodifiable(_seedFixtures)),
        achievementCatalogProvider
            .overrideWith((ref) async => List.unmodifiable(_achievementFixtures)),
      ],
      child: child,
    );

void main() {
  group('ResponsiveLayout：断点与网格列数', () {
    test('手机（<600）单列 + 底部导航', () {
      const phone = ResponsiveLayout(390);
      expect(phone.useBottomNavigation, isTrue);
      expect(phone.gridColumns, 1);
    });

    test('小平板（600–839）双列 + 底部导航', () {
      const smallTablet = ResponsiveLayout(800);
      expect(smallTablet.useBottomNavigation, isTrue);
      expect(smallTablet.gridColumns, 2);
    });

    test('平板（>=840）三列起 + NavigationRail', () {
      const tablet = ResponsiveLayout(840);
      expect(tablet.useNavigationRail, isTrue);
      expect(tablet.gridColumns, 3);

      // 列数随宽度连续增加。
      const wide = ResponsiveLayout(1500);
      expect(wide.gridColumns, greaterThanOrEqualTo(4));
    });
  });

  testWidgets('手机形态：默认花园页，底部 3-Tab 可切到种子商店', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appUnderTest(child: const HabitSeedApp()));
    await tester.pumpAndSettle();

    // 默认落在花园页空态。
    expect(find.text('去种子商店'), findsOneWidget);

    // 手机宽度使用底部导航。
    final navBar = find.byType(NavigationBar);
    expect(navBar, findsOneWidget);
    expect(
      find.descendant(of: navBar, matching: find.text('花园')),
      findsOneWidget,
    );

    // 切换到种子商店：JSON 种子目录渲染成功。
    await tester.tap(
      find.descendant(of: navBar, matching: find.text('种子商店')),
    );
    await tester.pumpAndSettle();
    expect(find.text('小薄荷'), findsOneWidget);
  });

  testWidgets('平板形态：NavigationRail 导航并展示种子目录', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appUnderTest(child: const HabitSeedApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('种子商店'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('小薄荷'), findsOneWidget);
  });
}
