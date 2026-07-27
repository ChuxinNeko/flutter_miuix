## 图标 Icons

本章涵盖 flutter_miuix 的图标系统：[MiuixIcon]（统一渲染入口）、[MiuixIcons]（图标集合入口）、[MiuixBasicIcons]（7 个基础矢量图标）、[MiuixExtendedIcons]（120+ 扩展图标 × 5 种字重）。

底层矢量数据模型（[MiuixVectorIcon] / [MiuixVectorPath] / `miuixParsePath`）见「基础设施」章节。

### MiuixIcon

Miuix 风格的图标。单色图标通过 `tint` 上色（默认取自 `MiuixContentColor`），多色图标传 [kMiuixTintUnspecified] 禁用上色，或通过 `child` 传入自定义 Widget。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `icon` | `IconData?` | `null` | Material 图标数据 |
| `vector` | `MiuixVectorIcon?` | `null` | Miuix 矢量图标（内置 basic / 扩展图标） |
| `child` | `Widget?` | `null` | 自定义图标 Widget（多色图标等） |
| `tint` | `Color?` | `null` | 上色颜色；`null` 时取 `MiuixContentColor.of(context)`；传 [kMiuixTintUnspecified] 时不应用任何 tint |
| `contentDescription` | `String?` | `null` | 无障碍描述；`null` 时不包裹 `Semantics`（装饰性图标） |
| `size` | `double?` | `null` | 图标尺寸；`null` 时 `icon` 路径回退到 `MiuixIconDefaults.defaultSize`（24），`child` 路径保留自身尺寸 |

> `icon` / `vector` / `child` **三选一**（构造时断言三者中有且仅有一个非 null）。

#### `kMiuixTintUnspecified`

哨兵色值 `Color(0x00000001)`，表示"不上色"（用于多色图标）。通过 `identical` 判等：只有传入此常量本身才被视为"无 tint"。

#### MiuixIconDefaults

| 常量 | 值 | 说明 |
|---|---|---|
| `defaultSize` | `24` | 默认图标尺寸（逻辑像素） |

**渲染路径**：

| 输入 | 行为 |
|---|---|
| `icon` | 调用 Flutter `Icon`，传 `color`/`size`/`semanticLabel`；默认 24，SrcIn 上色 |
| `vector` | 目标框为显式 `size`（正方形）或 `vector.intrinsicSize`；`FittedBox(BoxFit.contain)` 把视口坐标系绘制等比缩放进目标框；tint 通过 `MiuixVectorIconPainter` 的 `ColorFilter.mode(tint, BlendMode.srcIn)` 应用 |
| `child` | 任意 Widget；`size` 非空时用 `SizedBox+FittedBox(BoxFit.contain)` 约束；非"无 tint"时套 `ColorFiltered(BlendMode.srcIn)`；最后按需包 `Semantics` |

**示例：**
```dart
// 1. 单色矢量图标（默认从 MiuixContentColor 取色）
MiuixIcon(vector: MiuixIcons.basic.search);

// 2. 自定义 tint 与尺寸
MiuixIcon(
  vector: MiuixIcons.extended.byName('home')!,
  tint: theme.colors.primary,
  size: 28,
);

// 3. Material 图标
MiuixIcon(icon: Icons.favorite, tint: Colors.red);

// 4. 多色自定义图标（不上色）
MiuixIcon(
  child: Image.asset('assets/multicolor_logo.png'),
  tint: kMiuixTintUnspecified,
  contentDescription: 'Logo',
);
```

### MiuixIcons

Miuix 内置图标集合入口。`MiuixIcons._()` 私有构造，仅暴露 `static` 字段。

| 字段 | 类型 | 说明 |
|---|---|---|
| `basic` | `MiuixBasicIcons` | 组件内部使用的基础矢量图标 |
| `extended` | `MiuixExtendedIcons` | 扩展图标 120+ × 5 字重 |

### MiuixBasicIcons

基础图标命名空间。每个 getter 返回一个 [MiuixVectorIcon]，懒加载缓存单例（保证同一图标只构建一次）。

| getter | 视口 | 说明 |
|---|---|---|
| `arrowRight` | 10×16 | 右向箭头（`>`） |
| `arrowUpDown` | 10×16 | 上下双箭头 |
| `check` | 56×56 | 勾选 |
| `close` | 24×24 | 关闭（`x`，描边） |
| `search` | 20×20 | 搜索（放大镜） |
| `searchCleanup` | 68×68 | 搜索清除（圆底 x） |
| `sidebar` | 1224×1224 | 侧边栏（含纵向翻转） |

**示例：**
```dart
MiuixIcon(vector: MiuixIcons.basic.check, tint: theme.colors.primary);
MiuixIcon(vector: MiuixIcons.basic.arrowRight, size: 12);
```

### MiuixExtendedIcons

扩展图标集合。共 120+ 个图标 × 5 种字重。

| 字段 / 方法 | 类型 | 说明 |
|---|---|---|
| `MiuixExtendedIcons.internal()` | 构造 | 内部构造；请通过 `MiuixIcons.extended` 使用单例，勿直接实例化 |
| `byName(name, [weight = MiuixIconWeight.regular])` | `MiuixVectorIcon?` | 按名字取图标；名字为小驼峰（如 `addCircle`）；找不到返回 null |
| `names` | `List<String>` | 所有图标名（小驼峰），按字母序；用于图标浏览页 |

#### MiuixIconWeight

扩展图标的字重。

| 值 | 说明 |
|---|---|
| `light` | 细体 |
| `normal` | 常规 |
| `regular` | 标准（默认） |
| `medium` | 中等 |
| `demibold` | 半粗 |

**实现要点**：扩展图标的原始数据由 `tool/gen_extended_icons.py` 生成，把每个图标 5 个字重的 `PathNode` 列表压成 SVG 路径串，运行时经 `miuixParsePath` 还原为 [MiuixVectorIcon]。按 `name#weightIndex` 缓存懒构建。

#### 可用图标名（节选）

完整 120+ 个图标可通过 `MiuixIcons.extended.names` 在运行时获取。常见图标：

| 类别 | 图标名（节选） |
|---|---|
| 通用操作 | `add`、`addCircle`、`addFolder`、`close`、`clear`、`remove`、`ok`、`check`（基础） |
| 文件操作 | `copy`、`cut`、`paste`、`delete`、`rename`、`replace`、`merge`、`moveFile`、`convertFile`、`trim` |
| 导航 | `back`、`forward`、`chevronBackward`、`chevronForward`、`reply`、`replyAll`、`send` |
| 编辑 | `edit`、`create`、`undo`、`redo`、`rotateLeft`、`reset`、`update`、`refresh` |
| 视图 | `gridView`、`listView`、`horizontalSplit`、`verticalSplit`、`expandLess`、`expandMore`、`zoomOut`、`sort`、`filter` |
| 媒体 | `play`、`pause`、`music`、`mic`、`micSlash`、`album`、`image`、`photos`、`video`（无）、`screenCapture`、`appRecording`、`recording`、`recordingTape`、`stopwatch`、`timer` |
| 通信 | `phone`、`messages`、`email`、`contacts`、`contactsBook`、`contactsCircle`、`removeContact`、`answer`、`callRecording` |
| 系统 | `home`、`settings`、`theme`、`lock`、`unlock`、`pin`、`unpin`、`hide`、`show`、`blocklist`、`scan`、`screenMirroring`、`searchDevice` |
| 数据 | `backup`、`download`、`fileDownloads`、`topDownloads`、`uploadCloud`、`import`、`cloudFill`、`sync`（无）、`update`、`reset` |
| 文件夹 | `folder`、`folderFill`、`favorites`、`favoritesFill`、`recent`、`years`、`months`、`weeks`、`days`（无）、`all` |
| 信息 | `info`、`help`、`report`、`alarm`、`worldClock`、`tasks`、`notes`、`notesFill`、`mindMap`、`playlist` |
| 人物 | `community`、`contacts`、`carrier`、`promotions`、`store`、`bankCards` |
| 其他 | `link`、`share`、`translate`、`location`、`mapAlbum`、`sidebar`、`tune`、`layers`、`selectAll`、`volumeOff`、`volumeUp` |

**示例：**
```dart
// 默认 Regular 字重
final home = MiuixIcons.extended.byName('home')!;
MiuixIcon(vector: home, tint: theme.colors.primary);

// 指定字重
final homeLight = MiuixIcons.extended.byName('home', MiuixIconWeight.light)!;
MiuixIcon(vector: homeLight, size: 28);

// 列出所有图标名（用于图标浏览页）
final allNames = MiuixIcons.extended.names;
```

### 完整示例：使用内置图标的按钮

```dart
MiuixButton.icon(
  onPressed: () {},
  child: MiuixIcon(
    vector: MiuixIcons.extended.byName('settings')!,
    tint: MiuixTheme.of(context).colors.onSurface,
  ),
)
```
