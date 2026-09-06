import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_sections.dart';

/// 当前选中的主导航区块。
final selectedAppSectionProvider =
    NotifierProvider<SelectedAppSection, AppSection>(
  SelectedAppSection.new,
);

class SelectedAppSection extends Notifier<AppSection> {
  @override
  AppSection build() => AppSection.garden;

  void select(AppSection section) => state = section;
}
