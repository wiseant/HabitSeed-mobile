import 'package:flutter/material.dart';

import 'settings_screen.dart';

/// 打开全屏设置页（手机 AppBar 操作与平板 Rail 入口共用此路由）。
void openSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
  );
}

/// 设置页入口图标按钮（放在各页 AppBar actions 中）。
class SettingsAppBarAction extends StatelessWidget {
  const SettingsAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: '设置',
      onPressed: () => openSettings(context),
    );
  }
}
