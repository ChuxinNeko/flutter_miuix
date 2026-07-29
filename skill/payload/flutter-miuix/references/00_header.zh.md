# flutter_miuix API 文档

> 本文档为 **flutter_miuix** 组件库的完整 API 参考（中文版）。英文版见 [`API.en.md`](API.en.md)。

flutter_miuix 是移植自 [miuix](https://github.com/compose-miuix-ui/miuix) 的 Flutter 组件库，提供小米 HyperOS / MIUI 风格的完整组件集：Squircle 圆角、动态取色（Monet）、液态玻璃模糊等。

- 所有组件的**尺寸、圆角、内边距等均可通过构造参数自定义**，且都带有与原版一致的默认值。
- 颜色走 `MiuixColors` 语义角色，文本走 `MiuixTextStyles` 预设，随主题自动明暗切换。

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_miuix: ^1.0.0
```

然后：

```dart
import 'package:flutter_miuix/miuix.dart';
```

> 一个 import 即可使用全部公开 API。

## 主题接入

在应用根部包一层 `MiuixSystemTheme`（自动跟随系统明暗），组件即可通过 `MiuixTheme.of(context)` 取用配色与文本样式：

```dart
void main() => runApp(
  MiuixSystemTheme(
    child: Builder(
      builder: (context) {
        final theme = MiuixTheme.of(context);
        return MaterialApp(
          theme: ThemeData(brightness: theme.brightness),
          home: const HomePage(),
        );
      },
    ),
  ),
);
```

如需自定义配色或动态取色（Monet），见文末「主题、基础与图标」章节的 `MiuixSystemTheme` / `MiuixThemeController` / `miuixColorsFromSeed`。

## 快速上手

```dart
MiuixScaffold(
  topBar: const MiuixTopAppBar(title: 'flutter_miuix'),
  content: (padding) => ListView(
    padding: padding,
    children: [
      MiuixButton(
        onPressed: () {},
        child: const MiuixText('主色按钮'),
      ),
    ],
  ),
)
```

## 约定

- 表格中默认值列写「必填」表示该参数为 `required`（无默认值，必须传入）。
- 默认值形如 `MiuixXxxDefaults.yyy` 表示取自该组件的 `Defaults` 常量，可查源码得到具体数值。
- 所有示例均可直接编译运行，仅展示最常用参数；完整参数见各组件表格。

---
