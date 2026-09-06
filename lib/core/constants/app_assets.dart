/// 静态资源路径（SRS 4.3 JSON 文件清单，图片后续放入 images/）。
abstract final class AppAssets {
  /// 种子目录配置（首次启动由 Repository 从本地读取）。
  static const String seedsJson = 'assets/seeds.json';

  /// 成就定义配置。
  static const String achievementsJson = 'assets/achievements.json';
}
