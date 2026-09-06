import 'package:flutter/widgets.dart';

/// SRS 9.1 响应式断点约定。
abstract final class AppBreakpoints {
  /// 手机宽上限（<600 为手机；600–839 为小平板/竖屏平板）。
  static const double phoneMaxWidth = 600;

  /// 平板宽下限（>=840 使用 NavigationRail + 内容区布局）。
  static const double tabletMinWidth = 840;

  /// 弹窗 / 长表单等浮层推荐最大宽度（SRS 9.3）。
  static const double modalMaxWidth = 600;
}

/// 设备档位（SRS 9.1）。
enum FormFactor {
  phone,
  smallTablet,
  tablet,
}

/// 依据宽度判定设备档位。
FormFactor formFactorFor(double width) {
  if (width < AppBreakpoints.phoneMaxWidth) return FormFactor.phone;
  if (width < AppBreakpoints.tabletMinWidth) return FormFactor.smallTablet;
  return FormFactor.tablet;
}

/// 由当前可用宽度推导的响应式布局信息。
class ResponsiveLayout {
  const ResponsiveLayout(this.maxWidth);

  /// 当前可用（内容区）宽度。
  final double maxWidth;

  FormFactor get formFactor => formFactorFor(maxWidth);

  /// SRS 5：<840 使用底部 3-Tab，>=840 使用左侧 NavigationRail。
  bool get useBottomNavigation => maxWidth < AppBreakpoints.tabletMinWidth;
  bool get useNavigationRail => !useBottomNavigation;

  /// 页面内容网格列数：随宽度连续变化，而非在整页间硬切换（SRS 9.1）。
  int get gridColumns {
    switch (formFactor) {
      case FormFactor.phone:
        return 1;
      case FormFactor.smallTablet:
        return 2;
      case FormFactor.tablet:
        // 840 起至少 3 列，每约 +220dp 增 1 列，封顶 5 列。
        final columns = 3 + ((maxWidth - AppBreakpoints.tabletMinWidth) ~/ 220);
        return columns > 5 ? 5 : columns;
    }
  }
}

/// LayoutBuilder + [ResponsiveLayout] 的便捷封装。
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ResponsiveLayout layout) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, ResponsiveLayout(constraints.maxWidth)),
    );
  }
}
