import 'package:flutter/material.dart';

/// 主导航区块（SRS 5：围绕花园 / 种子商店 / 成就花园展开）。
enum AppSection {
  garden('garden', '花园', Icons.local_florist_outlined, Icons.local_florist),
  shop('shop', '种子商店', Icons.storefront_outlined, Icons.storefront),
  achievements(
    'achievements',
    '成就花园',
    Icons.emoji_events_outlined,
    Icons.emoji_events,
  );

  const AppSection(this.key, this.label, this.icon, this.selectedIcon);

  final String key;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
