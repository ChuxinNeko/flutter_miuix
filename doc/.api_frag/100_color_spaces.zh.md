## 颜色空间 Color Spaces

本章涵盖 flutter_miuix 的颜色空间抽象：[Hsv]（传统 HSV）、[OkLab]（感知均匀 Lab）、[OkLch]（感知均匀 LCH）、[OkHsv]（基于 OkLab 的 HSV）以及 [Color] 上的转换扩展 [MiuixColorSpaceExtensions]。

所有颜色空间类均为 `@immutable`，并实现 `==` / `hashCode`，可直接用于 `ValueListenable`、`AnimatedBuilder` 等需要值相等的场景。

### 设计概览

| 类 | 维度 | 取值范围 | 适用场景 |
|---|---|---|---|
| [Hsv] | h/s/v | h: `[0, 360]` 度；s/v: `[0, 100]` 百分比 | 传统 HSV，色相环均匀（程序员直观） |
| [OkLab] | l/a/b | l: `[0, 100]`；a/b: `[-100, 100]` | 感知均匀明度与色轴，色差计算 |
| [OkLch] | l/c/h | l/c: `[0, 100]`；h: `[0, 360]` 度 | 感知均匀色度色相，调色板生成 |
| [OkHsv] | h/s/v | h: `[0, 360]` 度；s/v: `[0, 100]` 百分比 | 感知均匀 HSV，取色器首选 |

> **归一化区间**：所有类对外暴露的是"便于用户理解的归一化区间"（明度/饱和度/色度用 0..100，色相用 0..360 度）；内部再按各空间的要求缩放到算法区间（如 OkLab 的 a/b 内部为 `[-0.4, 0.4]`、OkLch 的 c 内部为 `[0, 0.4]`）。

> **色域裁剪**：所有 `toColor` 在映射回 sRGB 时都做色域裁剪，确保输出颜色各通道在 `[0, 1]` 内。OkLab/OkLch 的 a/b/c 还会先裁剪到安全范围，避免色域外的不可预测颜色。

### Hsv

传统 HSV 颜色空间。**保留完整浮点精度**而非 8 位取整。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `h` | `double` | 必填（位置参数） | 色相，单位度，取值 `[0, 360]` |
| `s` | `double` | 必填（位置参数） | 饱和度，百分比，取值 `[0, 100]` |
| `v` | `double` | 必填（位置参数） | 明度/亮度，百分比，取值 `[0, 100]` |

| 方法 / 字段 | 返回 | 说明 |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | 转 sRGB；色相规范化到 `[0, 360)`，s/v 裁剪到 `[0, 1]`，逐分量求值 |
| `copyWith({h, s, v})` | `Hsv` | 替换指定分量后的副本 |
| `h` / `s` / `v` | `double` | 各分量 |

**示例：**
```dart
const Hsv(120, 80, 90).toColor();           // 绿色系
Hsv(0, 100, 100).copyWith(h: 240).toColor(); // 红→蓝
```

### OkLab

感知均匀 Lab 颜色空间。明度 l 与 a（绿-红轴）、b（蓝-黄轴）解耦，相邻数值差对应近似相等的感知色差。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `l` | `double` | 必填（位置参数） | 明度百分比，取值 `0..100` |
| `a` | `double` | 必填（位置参数） | 绿-红轴，取值 `-100..100`（负=绿，正=红） |
| `b` | `double` | 必填（位置参数） | 蓝-黄轴，取值 `-100..100`（负=蓝，正=黄） |

| 方法 / 字段 | 返回 | 说明 |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | 转 sRGB；l 按 `l/100` 裁剪到 `[0, 1]`；a、b 先按 `x/100*0.4` 缩放再裁剪到 `[-0.4, 0.4]` |
| `copyWith({l, a, b})` | `OkLab` | 替换指定分量后的副本 |
| `l` / `a` / `b` | `double` | 各分量 |

**示例：**
```dart
// 中灰（l=50, 无色轴）
const OkLab(50, 0, 0).toColor();

// 偏红
const OkLab(60, 30, 10).toColor();
```

### OkLch

感知均匀 LCH 颜色空间（OkLab 的极坐标形式）。色度 c 与色相 h 解耦，调色板生成时按固定 l、c 扫描 h 可得感知均匀的色相环。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `l` | `double` | 必填（位置参数） | 明度百分比，取值 `0..100` |
| `c` | `double` | 必填（位置参数） | 色度百分比，取值 `0..100`（0=灰，越大越饱和） |
| `h` | `double` | 必填（位置参数） | 色相，单位度，取值 `[0, 360]` |

| 方法 / 字段 | 返回 | 说明 |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | 转 sRGB；l 按 `l/100` 裁剪到 `[0, 1]`；c 先按 `c/100*0.4` 缩放再裁剪到 `[0, 0.4]`；h 规范化到 `[0, 360)` |
| `copyWith({l, c, h})` | `OkLch` | 替换指定分量后的副本 |
| `l` / `c` / `h` | `double` | 各分量 |

**示例：**
```dart
// 感知均匀的 36 色色相环（同 l、c，扫描 h）
final palette = List.generate(36, (i) => OkLch(70, 50, i / 36 * 360).toColor());

// 与 MiuixColorPicker 协同：当前色转 OkLch 后只调明度
final lab = current.toOkLch();
final dimmer = lab.copyWith(l: (lab.l - 10).clamp(0, 100)).toColor();
```

### OkHsv

基于 OkLab 的 HSV 颜色空间。与 [Hsv] 的 API 形状一致，但色相、饱和度、明度均在感知均匀空间下定义，调色时各方向色差更均衡。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `h` | `double` | 必填（位置参数） | 色相，单位度，取值 `[0, 360]` |
| `s` | `double` | 必填（位置参数） | 饱和度，百分比，取值 `[0, 100]` |
| `v` | `double` | 必填（位置参数） | 明度/亮度，百分比，取值 `[0, 100]` |

| 方法 / 字段 | 返回 | 说明 |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | 转 sRGB；**不对 h/s/v 或 alpha 做额外裁剪**，原样传入底层算法 |
| `copyWith({h, s, v})` | `OkHsv` | 替换指定分量后的副本 |
| `h` / `s` / `v` | `double` | 各分量 |

> 与 [Hsv] 的 `toColor` 不同，[OkHsv] 的 `toColor` 不主动把 s/v 裁剪到 `[0, 1]`，调用方需自行保证输入合法。

**示例：**
```dart
const OkHsv(210, 70, 90).toColor();  // 感知均匀的蓝色
OkHsv(0, 0, 100).copyWith(h: 180).toColor();
```

### MiuixColorSpaceExtensions

`Color` 上的颜色空间转换扩展。把当前 sRGB [Color] 转换为归一化区间的 [OkLab] / [Hsv] / [OkLch]。

```dart
extension MiuixColorSpaceExtensions on Color {
  OkLab toOkLab();
  Hsv toHsv();
  OkLch toOkLch();
}
```

| 方法 | 返回 | 区间映射 |
|---|---|---|
| `toOkLab()` | `OkLab` | 明度按 `l*100` 裁剪到 `[0, 100]`；a、b 按 `x/0.4*100` 还原后裁剪到 `[-100, 100]` |
| `toHsv()` | `Hsv` | 色相保留度数；s、v 按 `x*100` 裁剪到 `[0, 100]` |
| `toOkLch()` | `OkLch` | 明度按 `l*100` 裁剪到 `[0, 100]`；色度按 `c/0.4*100` 还原后裁剪到 `[0, 100]`；色相已归一化 |

> 所有转换**忽略输入颜色的 alpha**，输出颜色空间类不带 alpha 字段；如需保留 alpha，请用 `toColor(current.alpha)` 显式回传。

**示例：**
```dart
final c = const Color(0xFF3482FF);

// 转 OkLch 后只调整明度（适合做"调暗 10%"这类感知均匀操作）
final lch = c.toOkLch();
final dimmer = lch.copyWith(l: (lch.l - 10).clamp(0, 100)).toColor(c.alpha);

// 转 HSV 后只替换色相（保持原饱和度/明度，做"换色"）
final hsv = c.toHsv();
final recolored = hsv.copyWith(h: 0).toColor(c.alpha); // 改为红色系
```

### 完整示例：基于 OkLch 的感知均匀色板生成

```dart
/// 生成围绕 [seed] 的感知均匀 5 色配色（用于图表 / 标签）。
List<Color> analogousPalette(Color seed, {int count = 5, double span = 60}) {
  final lch = seed.toOkLch();
  return List.generate(count, (i) {
    final t = (i - (count - 1) / 2) / (count - 1) * 2; // -1..1
    final h = (lch.h + t * span / 2) % 360;
    return lch.copyWith(h: h < 0 ? h + 360 : h).toColor();
  });
}

// 使用
final colors = analogousPalette(const Color(0xFF3482FF));
```

### 内部实现说明

- 所有 `toColor` 的底层算法由内部的 `Transforms` 类提供（RGB ↔ OkLab、OkLCH、HSV、OkHSV，含色域裁剪与缓存）。该类**未在 `package:flutter_miuix/miuix.dart` 中导出**，属于内部实现，调用方应通过本节的 4 个颜色空间类与 [MiuixColorSpaceExtensions] 使用。
- OkLab/OkLCH 的数学源自 Björn Ottosson 的原始论文；OkHSV 的色域裁剪采用 Brent Burmeister 的 cusp 算法。
- `generateOkLchHueColors` 等批量生成函数未公开导出；如需色相环，请按上例用 `List.generate` + `OkLch.copyWith` 自行生成。
