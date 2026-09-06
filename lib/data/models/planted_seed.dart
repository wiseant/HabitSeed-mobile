import 'package:flutter/foundation.dart';

/// 植物状态机（SRS 2.3 / 2.4 / 2.5，对应 SRS 4.2 的 `PlantStatus`）。
///
/// 流转：
/// - growing / stopped：仍在花园中的当前种植植物（上限 3 株）；
/// - dead：枯萎后铲除，移入纪念花园（memorial_plants Box）；
/// - harvested：完整走完生长周期、成功开花，**自动移入成就花园**，
///   作为收藏档案展示（种子、稀有度、习惯、坚持天数、开花日期、最终形态）。
enum PlantStatus {
  growing('growing', '生长中'),
  stopped('stopped', '停止生长'),
  dead('dead', '枯萎'),
  harvested('harvested', '已开花');

  const PlantStatus(this.storageValue, this.label);

  /// JSON / Hive 中的存储值。
  final String storageValue;

  /// UI 展示文案。
  final String label;

  static PlantStatus fromValue(Object? value) => values.firstWhere(
        (status) => status.storageValue == value,
        orElse: () => PlantStatus.growing,
      );
}

/// 种植记录（SRS 4.2 `PlantedSeed` 核心模型）。
///
/// 存储位置说明：SRS 4.1 的 Hive Box 清单未为成就花园单独建 Box，
/// 且 `PlantStatus` 含 `harvested` 状态，因此本工程采用：
/// **已开花的记录保留在 planted_seeds Box（视为“种植档案”），
/// 成就花园 / 花园首页分别过滤 harvested 与非 harvested 子集**。
/// 这样既不新增 Box（保持 v1.2 的 5 Box 与导入导出快照一致），
/// 也能让每一株成熟植物都有可回溯的收藏记录。
///
/// 空壳阶段尚无写入方（M4 收获动作写入），当前仅提供读取所需的结构。
@immutable
class PlantedSeed {
  const PlantedSeed({
    required this.id,
    required this.seedId,
    required this.habitName,
    required this.plantedDate,
    this.lastWateredDate,
    this.totalWaterDays = 0,
    this.consecutiveMissDays = 0,
    this.status = PlantStatus.growing,
    this.bloomedAt,
  });

  /// 记录唯一标识（Hive key）。
  final String id;

  /// 关联种子配置（assets/seeds.json 中的 seedId）。
  final String seedId;

  /// 用户为习惯起的名字。
  final String habitName;

  /// 种植日期。
  final DateTime plantedDate;

  /// 最近一次浇水日期（状态判定用）。
  final DateTime? lastWateredDate;

  /// 累计坚持（浇水）天数，即成就花园展示的“坚持总天数”。
  final int totalWaterDays;

  /// 连续未浇水天数（每次打开 App / 浇水后计算）。
  final int consecutiveMissDays;

  /// 当前状态。
  final PlantStatus status;

  /// 开花（移入成就花园）日期，仅 harvested 记录有值（SRS 2.4 展示“开花日期”）。
  final DateTime? bloomedAt;

  /// 宽容解析 Hive 中存储的 Map；字段缺失 / 非法时返回 null。
  static PlantedSeed? tryFromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final seedId = map['seedId'];
    final habitName = map['habitName'];
    final planted = map['plantedDate'];

    if (id is! String || id.isEmpty) return null;
    if (seedId is! String || seedId.isEmpty) return null;
    if (habitName is! String || habitName.isEmpty) return null;
    final plantedDate = DateTime.tryParse(planted is String ? planted : '');
    if (plantedDate == null) return null;

    final rawWatered = map['lastWateredDate'];
    final rawBloomed = map['bloomedAt'];

    return PlantedSeed(
      id: id,
      seedId: seedId,
      habitName: habitName,
      plantedDate: plantedDate,
      lastWateredDate:
          rawWatered is String ? DateTime.tryParse(rawWatered) : null,
      totalWaterDays: map['totalWaterDays'] is int
          ? map['totalWaterDays'] as int
          : 0,
      consecutiveMissDays: map['consecutiveMissDays'] is int
          ? map['consecutiveMissDays'] as int
          : 0,
      status: PlantStatus.fromValue(map['status']),
      bloomedAt: rawBloomed is String ? DateTime.tryParse(rawBloomed) : null,
    );
  }

  /// 编码为可存 Hive 的 Map（M4 写入方使用；日期存 ISO-8601 字符串）。
  Map<String, Object?> toMap() => {
        'id': id,
        'seedId': seedId,
        'habitName': habitName,
        'plantedDate': plantedDate.toIso8601String(),
        'lastWateredDate': lastWateredDate?.toIso8601String(),
        'totalWaterDays': totalWaterDays,
        'consecutiveMissDays': consecutiveMissDays,
        'status': status.storageValue,
        if (bloomedAt != null) 'bloomedAt': bloomedAt!.toIso8601String(),
      };
}
