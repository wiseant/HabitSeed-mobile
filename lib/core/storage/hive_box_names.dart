/// Hive Box 命名清单（与 SRS 4.1 保持一致）。
abstract final class HiveBoxNames {
  /// 种植档案（动态数据）。
  ///
  /// 含全部种植记录：当前花园（growing/stopped，上限 3）与已收获
  /// （harvested）档案；成就花园展示其中 harvested 子集（SRS 2.4 自动移入），
  /// 避免为成就花园另建 Box 而偏离 SRS 4.1 定稿的 5 Box 结构。
  static const String plantedSeeds = 'planted_seeds';

  /// 浇水打卡日志（动态数据）。
  static const String waterLogs = 'water_logs';

  /// 成就解锁记录（动态数据）。
  static const String achievementRecords = 'achievement_records';

  /// 纪念花园记录（动态数据）。
  static const String memorialPlants = 'memorial_plants';

  /// 应用设置（浇水提醒开关等）。
  static const String appSettings = 'app_settings';

  /// 启动时需预先打开的 Box（顺序即展示顺序）。
  static const List<String> all = [
    plantedSeeds,
    waterLogs,
    achievementRecords,
    memorialPlants,
    appSettings,
  ];
}
