# HabitSeed（移动端）

面向初中生的习惯养成移动应用：把"坚持一件事"变成种下一颗种子，按时浇灌，看它发芽、开花。

本仓库为 Flutter 客户端工程。软件需求规格见 `docs/SRS/HabitSeed_SRS.md`（SRS，Markdown 单一事实源，版本基线由 git 管理；历史 docx 快照留存于 git 历史）。

## 里程碑 M1/M2：可运行空壳 + 数据层

已就绪的基础设施：

| 关注点 | 方案 | 位置 |
| --- | --- | --- |
| 状态管理 | Riverpod 3（`Provider` / `FutureProvider` / `Notifier`） | `lib/data/providers.dart`、`lib/features/**` |
| 本地存储 | Hive（5 个 Box：planted_seeds / water_logs / achievement_records / memorial_plants / app_settings） | `lib/core/storage/` |
| 静态 JSON 资源 | `assets/seeds.json`（种子目录）、`assets/achievements.json`（成就定义） | `assets/` |
| 资源读取 | Repository 模式 + `JsonAssetLoader`（rootBundle），后续可无缝换远端 API | `lib/data/repositories/`、`lib/core/json/` |
| 成就花园收藏（SRS 2.4 链路预置） | 已收获（`harvested`）种植档案保留于 `planted_seeds`，成就花园页按状态过滤读取；不另设 Box（与 4.1 五 Box / 导入导出快照一致） | `bloomedPlantsProvider`、`achievements_screen.dart` |
| 响应式壳 | `<600` 手机、`600–839` 小平板、`>=840` 平板：底部 3-Tab ↔ NavigationRail | `lib/core/responsive/`、`lib/features/shell/` |

## 页面现状（空壳阶段）

- 花园页：空态 + "去种子商店"引导；顶部"环境自检"面板（Hive Box / Provider / 系统时间），`kDebugMode` 下可见。
- 成就花园页（SRS 2.4 双区）：
  - "已开花植物"区由 `bloomedPlantsProvider` 读取 `planted_seeds` 中的 `harvested` 档案，展示习惯名、种子稀有度、坚持天数、开花日期、最终形态；当前无写入方（M4 收获动作落地后自动出数），页面空态即真实状态；
  - "成就"区渲染 `assets/achievements.json`，解锁判定随种植记录产生后实现。
- 种子商店 / 设置：路由可达的占位页，进入后续里程碑后实现功能。

## 目录结构

```
lib/
├── main.dart                       # 入口：bootstrap(Hive) -> ProviderScope
├── app/
│   ├── habitseed_app.dart          # MaterialApp + 主题
│   └── bootstrap/                  # 启动引导
├── core/                           # 与业务无关的基建
│   ├── async/                      # AsyncValue 摘要等
│   ├── constants/                  # 资源路径
│   ├── design/                     # 主题
│   ├── json/                       # JSON asset 加载
│   ├── responsive/                 # 断点 / FormFactor / 响应式构建器
│   └── storage/                    # Hive Box 常量 + HiveStore
├── data/                           # 数据层
│   ├── models/                     # SeedDefinition / AchievementDefinition / PlantedSeed（种植档案）
│   ├── repositories/               # 抽象数据源 + JSON 实现
│   └── providers.dart              # 数据 Provider（含 bloomedPlantsProvider）
└── features/
    ├── shell/                      # 响应式导航空壳
    ├── garden/  shop/  achievements/  settings/
    └── settings/open_settings.dart # 全屏设置路由
```

## 常用命令

```bash
flutter pub get          # 拉取依赖
flutter run              # 运行（-d chrome / windows 可预览响应式）
flutter test             # 冒烟测试（注入内存 fixtures，不依赖真实 assets 通道）
flutter analyze          # 静态检查
dart run build_runner build   # M2 接入业务模型后生成 Hive TypeAdapter
```

## 设计约定

- 响应式断点与网格列数见 `lib/core/responsive/responsive_layout.dart`（对齐 SRS 9.1）。
- 数据优先走抽象 Repository（`SeedDataSource` / `AchievementDataSource`）。
- 成就花园遵循 SRS 2.4 / 4.1：不另设成就 Box，以 `planted_seeds` 内 `harvested` 记录为收藏数据源（见 `hive_box_names.dart` 注释），与导入导出快照结构保持一致。
- 空壳阶段仅花园页保留"环境自检/数据源调试"面板，便于联调；`kDebugMode` 下可见。
