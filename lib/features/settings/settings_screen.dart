import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async/async_value_ext.dart';
import '../../core/storage/hive_box_names.dart';
import '../../core/storage/hive_store.dart';
import '../../data/providers.dart';

/// 设置页（空壳版本）。
///
/// - 浇水提醒：开关占位（M4 实现）；
/// - 数据管理：导入 / 导出占位（M5 实现）；
/// - 数据源与存储：显示 JSON 静态目录与 Hive Box 就绪状态（调试数据）。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hive = ref.watch(hiveStoreProvider);
    final theme = Theme.of(context);
    final sectionHeaderStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: '浇水提醒', style: sectionHeaderStyle),
          const SwitchListTile(
            secondary: Icon(Icons.notifications_outlined),
            title: Text('开启浇灌提醒'),
            subtitle: Text('预留：M4 接入系统通知'),
            value: false,
            onChanged: null,
          ),
          const Divider(),
          _SectionHeader(title: '数据管理', style: sectionHeaderStyle),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.file_download_outlined),
            title: Text('导出备份'),
            subtitle: Text('预留：M5 实现本地 JSON 备份'),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.file_upload_outlined),
            title: Text('导入恢复'),
            subtitle: Text('预留：M5 实现'),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.delete_forever_outlined),
            title: Text('清除全部数据'),
            subtitle: Text('预留：危险操作，M5 实现'),
          ),
          const Divider(),
          _SectionHeader(title: '数据源 · 存储（调试）', style: sectionHeaderStyle),
          _StatusRow(
            icon: Icons.data_object,
            title: '种子目录（JSON）',
            trailing: ref.watch(seedCatalogProvider).countSummary,
          ),
          _StatusRow(
            icon: Icons.data_object,
            title: '成就定义（JSON）',
            trailing: ref.watch(achievementCatalogProvider).countSummary,
          ),
          for (final boxName in HiveBoxNames.all)
            _HiveBoxRow(hive: hive, boxName: boxName),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.style});

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: style),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: Text(trailing),
    );
  }
}

class _HiveBoxRow extends StatelessWidget {
  const _HiveBoxRow({required this.hive, required this.boxName});

  final HiveStore hive;
  final String boxName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = hive.isBoxOpen(boxName);
    final dimColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.storage_outlined,
        size: 20,
        color: isOpen ? theme.colorScheme.primary : dimColor,
      ),
      title: Text(boxName),
      trailing: Text(
        isOpen ? '已打开 · ${hive.itemCount(boxName)} 条' : '未初始化',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isOpen ? null : dimColor,
        ),
      ),
    );
  }
}
