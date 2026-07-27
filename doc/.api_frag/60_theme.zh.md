## 主题、配色与动效 Theme, Colors & Motion

本章涵盖 flutter_miuix 的主题基础设施：[MiuixTheme]/[MiuixSystemTheme] 提供静态主题，[MiuixThemeController] 提供完整的动态取色（Monet）；[MiuixColors] 定义 50+ 个 HyperOS 语义角色，[MiuixTextStyles] 定义 14 种预设字号；[MiuixMotion] 与 `folmeSpring` 提供与原版一致的弹簧与缓动曲线。

### MiuixThemeData

不可变的 Miuix 主题数据，聚合 [MiuixColors]、[MiuixTextStyles] 与 [Brightness]。

| 字段 / 方法 | 类型 | 说明 |
|---|---|---|
| `colors` | `MiuixColors` | 配色方案 |
| `textStyles` | `MiuixTextStyles` | 文本样式集 |
| `brightness` | `Brightness` | 当前亮度模式 |
| `MiuixThemeData.light({colors, textStyles})` | 工厂 | 浅色主题；默认 [lightColorScheme] + [defaultTextStyles] |
| `MiuixThemeData.dark({colors, textStyles})` | 工厂 | 深色主题；默认 [darkColorScheme] + [defaultTextStyles] |
| `MiuixThemeData.of(brightness, {lightColors, darkColors, textStyles})` | 工厂 | 跟随系统亮度自动选择 |
| `copyWith({colors, textStyles, brightness})` | `MiuixThemeData` | 复制并覆盖部分字段 |

**示例：**
```dart
final data = MiuixThemeData.light(
  colors: lightColorScheme().copy(primary: Color(0xFFFF6B35)),
);
```

### MiuixTheme

向子树提供 [MiuixThemeData] 的 [InheritedWidget]。

| 参数 / 方法 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `data` | `MiuixThemeData` | 必填 | 主题数据 |
| `child` | `Widget` | 必填 | 子树 |
| `MiuixTheme.of(context)` | `MiuixThemeData` | — | 取当前主题；未包裹时回退到 `MiuixThemeData.light()` |
| `MiuixTheme.maybeOf(context)` | `MiuixThemeData?` | — | 不建立依赖的读取；未包裹返回 null |

**示例：**
```dart
MiuixTheme(
  data: MiuixThemeData.light(),
  child: MyApp(),
)
```

### MiuixSystemTheme

根据 `MediaQuery.platformBrightnessOf` 自动套用浅色/深色主题的便捷组件。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `light` | `MiuixColors?` | `null`（= [lightColorScheme]） | 自定义浅色配色 |
| `dark` | `MiuixColors?` | `null`（= [darkColorScheme]） | 自定义深色配色 |
| `textStyles` | `MiuixTextStyles?` | `null`（= [defaultTextStyles]） | 自定义文本样式 |
| `child` | `Widget` | 必填 | 子树 |

**示例：**
```dart
MiuixSystemTheme(
  child: Builder(builder: (context) {
    final theme = MiuixTheme.of(context);
    return MaterialApp(
      theme: ThemeData(brightness: theme.brightness),
      home: const HomePage(),
    );
  }),
)
```

### MiuixColorSchemeMode

配色模式枚举。

| 值 | 说明 |
|---|---|
| `system` | 跟随系统亮度，使用静态 light/dark 配色 |
| `light` | 强制浅色 |
| `dark` | 强制深色 |
| `monetSystem` | 跟随系统亮度 + Monet 动态取色 |
| `monetLight` | 浅色 + Monet 动态取色 |
| `monetDark` | 深色 + Monet 动态取色 |

> `monet*` 模式：`keyColor` 非空时按种子同步生成（纯 HCT 计算）；`keyColor` 为空时读平台壁纸（Android），其他平台回退固定种子 `0xFF6750A4`。

### MiuixThemeController

完整的主题控制器，按 [MiuixColorSchemeMode] 解析配色并向子树提供 [MiuixTheme]。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `colorSchemeMode` | `MiuixColorSchemeMode` | `system` | 配色模式 |
| `lightColors` | `MiuixColors?` | `null`（= [lightColorScheme]） | 浅色静态配色 |
| `darkColors` | `MiuixColors?` | `null`（= [darkColorScheme]） | 深色静态配色 |
| `textStyles` | `MiuixTextStyles?` | `null`（= [defaultTextStyles]） | 文本样式 |
| `keyColor` | `Color?` | `null` | Monet 种子色；为 null 时走平台壁纸取色 |
| `colorSpec` | `MiuixThemeColorSpec` | `spec2021` | 配色规范版本 |
| `paletteStyle` | `MiuixThemePaletteStyle` | `tonalSpot` | Monet palette 风格 |
| `isDark` | `bool?` | `null` | 是否深色；null 时跟随系统 |
| `child` | `Widget` | 必填 | 子树 |

**Monet 取色流程**：
1. `keyColor` 非空 → 同步调用 [miuixColorsFromSeed]（纯 HCT 计算，无平台通道）。
2. `keyColor` 为空 → 异步调用 [miuixPlatformDynamicColors]（Android 壁纸；其他平台回退固定种子）。结果就绪前用 [miuixMonetSystemColors] 占位以避免闪烁。

**示例：**
```dart
MiuixThemeController(
  colorSchemeMode: MiuixColorSchemeMode.monetSystem,
  keyColor: const Color(0xFF6750A4),
  child: MyApp(),
)
```

### MiuixColors

Miuix 颜色方案。所有字段均不可空，可通过 [copy] 覆盖部分颜色；浅色/深色默认值由 [lightColorScheme] / [darkColorScheme] 提供，与 HyperOS 规范一致。

#### 主要语义角色

| 字段 | 说明 |
|---|---|
| `primary` / `onPrimary` | 主色 / 主色上文字（Switch、Button、Slider） |
| `primaryVariant` / `onPrimaryVariant` | 主色变体（Card 用） |
| `primaryContainer` / `onPrimaryContainer` | 主色容器 |
| `secondary` / `onSecondary` | 次级色 / 上文字 |
| `secondaryVariant` / `onSecondaryVariant` | 次级变体 |
| `secondaryContainer` / `onSecondaryContainer` | 次级容器 |
| `secondaryContainerVariant` / `onSecondaryContainerVariant` | 次级容器变体 |
| `tertiaryContainer` / `onTertiaryContainer` / `tertiaryContainerVariant` | 三级容器 |
| `error` / `onError` | 错误色 / 上文字 |
| `errorContainer` / `onErrorContainer` | 错误容器 |
| `background` / `onBackground` / `onBackgroundVariant` | 应用背景 / 上文字 / 变体文字 |
| `surface` / `onSurface` / `surfaceVariant` | Surface 色 / 上文字 / 变体 |
| `onSurfaceSecondary` | Surface 上次级文字（80% alpha） |
| `onSurfaceVariantSummary` / `onSurfaceVariantActions` | Surface 变体上的摘要 / 操作文字 |
| `surfaceContainer` / `onSurfaceContainer` / `onSurfaceContainerVariant` | Surface 容器 / 上文字 / 变体文字 |
| `surfaceContainerHigh` / `onSurfaceContainerHigh` | 高 Surface 容器 |
| `surfaceContainerHighest` / `onSurfaceContainerHighest` | 最高 Surface 容器 |
| `outline` | 描边 / 边框 |
| `dividerLine` | 分隔线 |
| `windowDimming` | 窗口遮罩色（Dialog / Dropdown / Spinner / BottomSheet） |
| `sliderKeyPoint` / `sliderKeyPointForeground` / `sliderBackground` | Slider 关键点 / 前景 / 背景 |

#### 禁用态颜色

| 字段 | 说明 |
|---|---|
| `disabledPrimary` / `disabledOnPrimary` | Switch 禁用主色 / 上文字 |
| `disabledPrimaryButton` / `disabledOnPrimaryButton` | Button 禁用主色 / 上文字 |
| `disabledPrimarySlider` | Slider 禁用主色 |
| `disabledSecondary` / `disabledOnSecondary` | 禁用次级色 / 上文字 |
| `disabledSecondaryVariant` / `disabledOnSecondaryVariant` | 禁用次级变体 / 上文字 |
| `disabledOnSurface` | 禁用 Surface 上文字 |

#### 默认配色工厂

| 函数 | 返回 | 说明 |
|---|---|---|
| `lightColorScheme()` | `MiuixColors` | 默认浅色（primary=`0xFF3482FF`，background=白） |
| `darkColorScheme()` | `MiuixColors` | 默认深色（primary=`0xFF277AF7`，background=`0xFF242424`） |

#### `MiuixColors.copy(...)`

复制并覆盖部分颜色，所有参数均可空，未传则保留原值。返回新的 [MiuixColors] 实例。

**示例：**
```dart
final colors = lightColorScheme().copy(
  primary: const Color(0xFFFF6B35),
  background: const Color(0xFFFFFBF8),
);
```

### MiuixTextStyles

Miuix 文本样式集。所有样式仅保留字号/字重/行高，颜色由 [MiuixTheme] 的 `onBackground` 在运行时提供。

| 字段 | 字号 | 行高/字重 | 用途 |
|---|---|---|---|
| `main` | 17 | — | 主文本 |
| `paragraph` | 17 | 1.2em | 段落 |
| `body1` | 16 | — | 正文 1 |
| `body2` | 14 | — | 正文 2 |
| `button` | 17 | — | 按钮 |
| `footnote1` | 13 | — | 脚注 1 |
| `footnote2` | 11 | — | 脚注 2 |
| `headline1` | 17 | — | 标题行 1 |
| `headline2` | 16 | — | 标题行 2 |
| `subtitle` | 14 | bold | 副标题 |
| `title1` | 32 | — | 标题 1 |
| `title2` | 24 | — | 标题 2 |
| `title3` | 20 | — | 标题 3 |
| `title4` | 18 | — | 标题 4 |

#### `MiuixTextStyles.copy({...})`

按字段复制覆盖，返回新实例。

#### `defaultTextStyles()`

返回与 Miuix 规范一致的默认样式集（即上表所有数值）。可单独传入 [MiuixThemeData] / [MiuixSystemTheme] / [MiuixThemeController] 的 `textStyles` 参数以替换。

### Monet 动态取色

#### MiuixThemeColorSpec

Material 配色规范版本。当前 `material_color_utilities` 0.13.0 仅实现 SPEC_2021，`spec2025` 在受支持的 palette 上语义等价请求 2025，但底层按 2021 生成（与原版"不支持则降级"路径一致）。

| 值 | 说明 |
|---|---|
| `spec2021` | Material You 2021 配色规范 |
| `spec2025` | Material You 2025 规范（当前等价于 spec2021） |

#### MiuixThemePaletteStyle

Monet 动态配色的 palette 风格。

| 值 | 对应 DynamicScheme |
|---|---|
| `tonalSpot` | `SchemeTonalSpot`（默认） |
| `neutral` | `SchemeNeutral` |
| `vibrant` | `SchemeVibrant` |
| `expressive` | `SchemeExpressive` |
| `rainbow` | `SchemeRainbow` |
| `fruitSalad` | `SchemeFruitSalad` |
| `monochrome` | `SchemeMonochrome` |
| `fidelity` | `SchemeFidelity` |
| `content` | `SchemeContent` |

#### `miuixColorsFromSeed({seed, colorSpec, paletteStyle, dark})`

从种子色生成整套 miuix 配色。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `seed` | `Color` | 必填 | 种子色 |
| `colorSpec` | `MiuixThemeColorSpec` | `spec2021` | 配色规范 |
| `paletteStyle` | `MiuixThemePaletteStyle` | `tonalSpot` | palette 风格 |
| `dark` | `bool` | 必填 | 是否深色 |

返回 [MiuixColors]。流程：按 `paletteStyle` 选择对应的 `DynamicScheme` → 用 `MaterialDynamicColors` 提取 27 个 MD3 角色 → 经 [mapMd3RolesToMiuixColors] 映射为 miuix 颜色（带透明度的颜色合成到对应背景上，保证结果全不透明）。

#### `miuixMonetSystemColors({dark})`

默认 Monet 配色：固定种子 `0xFF6750A4` + TonalSpot + Spec2021。也是所有非 Android 平台的 `platformDynamicColors` 回退。

#### `miuixPlatformDynamicColors({dark})` → `Future<MiuixColors>`

平台动态取色。

- Android（及支持的平台）：通过 `DynamicColorPlugin.getAccentColor` 读系统壁纸/主题种子色，非空则用 [miuixColorsFromSeed]（TonalSpot + Spec2021）生成。
- 其他平台或读取失败：回退 [miuixMonetSystemColors]（固定种子）。

> 平台通道是**异步**，故本函数返回 `Future`。UI 层（[MiuixThemeController]）在结果就绪前用 [miuixMonetSystemColors] 占位。

#### MiuixMonetRoles

MD3（Monet）动态配色的角色集合（27 个字段）。由 [miuixColorsFromSeed] 从 `DynamicScheme` 提取后填充，再交给 [mapMd3RolesToMiuixColors] 转换为 [MiuixColors]。

主要角色：`primary`、`onPrimary`、`primaryFixed`、`onPrimaryFixed`、`error`、`onError`、`errorContainer`、`onErrorContainer`、`primaryContainer`、`onPrimaryContainer`、`secondary`、`onSecondary`、`secondaryContainer`、`onSecondaryContainer`、`tertiaryContainer`、`onTertiaryContainer`、`background`、`onBackground`、`surface`、`onSurface`、`surfaceVariant`、`surfaceContainer`、`surfaceContainerHigh`、`surfaceContainerHighest`、`outline`、`outlineVariant`、`onSurfaceVariant`。

#### `mapMd3RolesToMiuixColors(roles, {dark})`

把 MD3（Monet）角色映射为 miuix [MiuixColors]。逐字段照搬原版映射；带透明度的 disabled / slider / onSurfaceSecondary 等通过 `ensureOpaqueOver` 合成到对应背景上，保证结果全不透明。

### MiuixMotion

Miuix 常用动效曲线与弹簧集合，按 HyperOS 交互习惯分类。

| 字段 / 方法 | 类型 | 说明 |
|---|---|---|
| `standardDecelerate` | `Curve` | 标准缓出，用于进场/出现（`DecelerateEasing(1.0)`） |
| `standardAccelerate` | `Curve` | 标准缓入，用于退场/消失（`AccelerateEasing(1.0)`） |
| `sinOut` | `Curve` | 正弦缓出，用于柔和位移/缩放（`SinOutEasing`） |
| `pressSpring` | `SpringDescription` | 通用按压/状态切换（临界阻尼，response=0.35s） |
| `bouncySpring` | `SpringDescription` | 弹性切换（轻微欠阻尼 0.85，response=0.45s，有自然回弹） |

#### `folmeSpring({damping, response})` → `SpringDescription`

由阻尼比 [damping] 与响应时间 [response]（秒）构造一个 [SpringDescription]：`stiffness = (2π/response)²`。

| 参数 | 类型 | 说明 |
|---|---|---|
| `damping` | `double` | 阻尼比；1.0=临界，<1 欠阻尼（有回弹），>1 过阻尼 |
| `response` | `double` | 响应时间（秒）；越小越快 |

#### AccelerateEasing

加速曲线。`factor=1` 时为 `y=x²`；`factor` 越大缓入越夸张。

```dart
const curve = AccelerateEasing(1.0);
```

#### DecelerateEasing

减速曲线。`factor=1` 时为 `1-(1-x)²`；`factor` 越大缓出越夸张。

#### SinOutEasing

正弦缓出曲线：`sin(t·π/2)`。

**完整动效示例：**
```dart
AnimationController(vsync: this)
  ..animateWith(
    SpringSimulation(
      folmeSpring(damping: 0.85, response: 0.45),
      0.0, 1.0, 0.0,
    ),
  );

// 或使用预设
AnimationController(vsync: this)
  ..animateTo(1.0, curve: MiuixMotion.standardDecelerate);
```
