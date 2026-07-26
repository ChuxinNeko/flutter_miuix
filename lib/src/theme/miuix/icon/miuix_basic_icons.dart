// Miuix Flutter 移植版 - Basic Icons
// 源自 compose-miuix-ui/miuix 的 miuix-ui/.../icon/basic/*.kt。
// 逐路径 1:1 复刻 7 个内置矢量图标（ArrowRight/ArrowUpDown/Check/Close/Search/
// SearchCleanup/Sidebar），通过 MiuixIcons.basic 访问，配合 MiuixIcon 渲染上色。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_vector_icon.dart';
import 'miuix_extended_icons.dart';

/// Miuix 内置图标集合入口。对应 Kotlin `object MiuixIcons`。
///
/// 公开 [basic]（对应 `MiuixIcons.Basic`）与 [extended]（对应 `MiuixIcons.Extended`，
/// 156 个图标 × 5 种字重）。
class MiuixIcons {
  const MiuixIcons._();

  /// 组件内部使用的基础矢量图标。对应 Kotlin `MiuixIcons.Basic`。
  static const MiuixBasicIcons basic = MiuixBasicIcons._();

  /// 扩展图标（156 个 × 5 字重）。对应 Kotlin `MiuixIcons.Extended`。
  static const MiuixExtendedIcons extended = MiuixExtendedIcons.internal();
}

/// 基础图标命名空间。对应 Kotlin `MiuixIcons.Basic` 上的一组扩展属性。
///
/// 每个 getter 返回一个 [MiuixVectorIcon]，与 Kotlin 端相同：懒加载缓存单例，
/// 保证同一图标只构建一次。
class MiuixBasicIcons {
  const MiuixBasicIcons._();

  /// 右向箭头（`>`）。源自 `icon/basic/ArrowRight.kt`，视口 10x16。
  MiuixVectorIcon get arrowRight => _arrowRight ??= _buildArrowRight();

  /// 上下双箭头。源自 `icon/basic/ArrowUpDown.kt`，视口 10x16。
  MiuixVectorIcon get arrowUpDown => _arrowUpDown ??= _buildArrowUpDown();

  /// 勾选。源自 `icon/basic/Check.kt`，视口 56x56。
  MiuixVectorIcon get check => _check ??= _buildCheck();

  /// 关闭（`x`，描边）。源自 `icon/basic/Close.kt`，视口 24x24。
  MiuixVectorIcon get close => _close ??= _buildClose();

  /// 搜索（放大镜）。源自 `icon/basic/Search.kt`，视口 20x20。
  MiuixVectorIcon get search => _search ??= _buildSearch();

  /// 搜索清除（圆底 x）。源自 `icon/basic/SearchCleanup.kt`，视口 68x68。
  MiuixVectorIcon get searchCleanup => _searchCleanup ??= _buildSearchCleanup();

  /// 侧边栏。源自 `icon/basic/Sidebar.kt`，视口 1224x1224（含纵向翻转）。
  MiuixVectorIcon get sidebar => _sidebar ??= _buildSidebar();
}

// ==== 懒加载缓存（对应 Kotlin 各文件的 private var _xxx）====
MiuixVectorIcon? _arrowRight;
MiuixVectorIcon? _arrowUpDown;
MiuixVectorIcon? _check;
MiuixVectorIcon? _close;
MiuixVectorIcon? _search;
MiuixVectorIcon? _searchCleanup;
MiuixVectorIcon? _sidebar;

const Size _size24 = Size(24, 24);

// ============================ 图标构建 ============================

MiuixVectorIcon _buildArrowRight() => MiuixVectorIcon(
      name: 'ArrowRight',
      viewport: const Size(10, 16),
      intrinsicSize: const Size(10, 16),
      paths: [
        MiuixVectorPath(
          build: () => miuixEvenOddPath()
            ..moveTo(1.65, 1.469)
            ..cubicTo(1.929, 1.19, 2.381, 1.19, 2.66, 1.469)
            ..lineTo(8.721, 7.53)
            ..cubicTo(9.0, 7.809, 9.0, 8.261, 8.721, 8.54)
            ..lineTo(2.66, 14.601)
            ..cubicTo(2.381, 14.88, 1.929, 14.88, 1.65, 14.601)
            ..cubicTo(1.371, 14.322, 1.371, 13.87, 1.65, 13.591)
            ..lineTo(7.205, 8.035)
            ..lineTo(1.65, 2.479)
            ..cubicTo(1.371, 2.2, 1.371, 1.748, 1.65, 1.469)
            ..close(),
        ),
      ],
    );

MiuixVectorIcon _buildArrowUpDown() => MiuixVectorIcon(
      name: 'ArrowUpDown',
      viewport: const Size(10, 16),
      intrinsicSize: const Size(10, 16),
      paths: [
        MiuixVectorPath(
          build: () => miuixEvenOddPath()
            ..moveTo(2.397, 4.7384)
            ..lineTo(4.5688, 2.5665)
            ..lineTo(5.0075, 2.1278)
            ..lineTo(5.4266, 2.5469)
            ..lineTo(7.5985, 4.7187)
            ..lineTo(8.531, 5.6512)
            ..cubicTo(8.8282, 5.9485, 9.3102, 5.9485, 9.6075, 5.6512)
            ..cubicTo(9.9047, 5.354, 9.9047, 4.872, 9.6075, 4.5747)
            ..lineTo(8.675, 3.6423)
            ..lineTo(6.5031, 1.4704)
            ..lineTo(5.5706, 0.5379)
            ..cubicTo(5.3595, 0.3267, 5.0551, 0.2656, 4.7899, 0.3544)
            ..cubicTo(4.6561, 0.3855, 4.5291, 0.4532, 4.4248, 0.5575)
            ..lineTo(3.4924, 1.49)
            ..lineTo(1.3205, 3.6619)
            ..lineTo(0.388, 4.5943)
            ..cubicTo(0.0907, 4.8916, 0.0907, 5.3736, 0.388, 5.6708)
            ..cubicTo(0.6853, 5.9681, 1.1672, 5.9681, 1.4645, 5.6708)
            ..lineTo(2.397, 4.7384)
            ..close()
            ..moveTo(2.397, 11.257)
            ..lineTo(4.5688, 13.4289)
            ..lineTo(5.0075, 13.8675)
            ..lineTo(5.4266, 13.4485)
            ..lineTo(7.5985, 11.2766)
            ..lineTo(8.531, 10.3441)
            ..cubicTo(8.8282, 10.0468, 9.3102, 10.0468, 9.6075, 10.3441)
            ..cubicTo(9.9047, 10.6414, 9.9047, 11.1233, 9.6075, 11.4206)
            ..lineTo(8.675, 12.3531)
            ..lineTo(6.5031, 14.525)
            ..lineTo(5.5706, 15.4574)
            ..cubicTo(5.3594, 15.6686, 5.0551, 15.7298, 4.7899, 15.6409)
            ..cubicTo(4.6561, 15.6098, 4.5291, 15.5421, 4.4248, 15.4378)
            ..lineTo(3.4924, 14.5053)
            ..lineTo(1.3205, 12.3335)
            ..lineTo(0.388, 11.401)
            ..cubicTo(0.0907, 11.1037, 0.0907, 10.6217, 0.388, 10.3245)
            ..cubicTo(0.6853, 10.0272, 1.1672, 10.0272, 1.4645, 10.3245)
            ..lineTo(2.397, 11.257)
            ..close(),
        ),
      ],
    );
MiuixVectorIcon _buildCheck() => MiuixVectorIcon(
      name: 'Check',
      viewport: const Size(56, 56),
      intrinsicSize: _size24,
      paths: [
        MiuixVectorPath(
          build: () => miuixEvenOddPath()
            ..moveTo(46.8171, 18.1514)
            ..cubicTo(48.0496, 16.6624, 47.8417, 14.4561, 46.3527, 13.2235)
            ..cubicTo(44.8636, 11.991, 42.6573, 12.1989, 41.4247, 13.6879)
            ..lineTo(22.9535, 36.0031)
            ..lineTo(13.4007, 26.4502)
            ..cubicTo(12.0338, 25.0833, 9.8177, 25.0833, 8.4509, 26.4502)
            ..cubicTo(7.0841, 27.817, 7.0841, 30.0331, 8.4509, 31.3999)
            ..lineTo(20.7077, 43.6567)
            ..cubicTo(21.7243, 44.6733, 23.2108, 44.9338, 24.4682, 44.4381)
            ..cubicTo(25.0159, 44.2302, 25.5189, 43.8818, 25.9192, 43.3982)
            ..lineTo(46.8171, 18.1514)
            ..close(),
        ),
      ],
    );

MiuixVectorIcon _buildClose() => MiuixVectorIcon(
      name: 'Close',
      viewport: _size24,
      intrinsicSize: _size24,
      paths: [
        // 描边路径：两条对角线组成 'x'，宽 2.2，圆帽。对应 Kotlin path(stroke=...).
        MiuixVectorPath(
          style: PaintingStyle.stroke,
          strokeWidth: 2.2,
          strokeCap: StrokeCap.round,
          build: () => Path()
            ..moveTo(6, 6)
            ..lineTo(18, 18)
            ..moveTo(18, 6)
            ..lineTo(6, 18),
        ),
      ],
    );

MiuixVectorIcon _buildSearch() => MiuixVectorIcon(
      name: 'Search',
      viewport: const Size(20, 20),
      intrinsicSize: const Size(20, 20),
      paths: [
        MiuixVectorPath(
          build: () => miuixEvenOddPath()
            ..moveTo(12.572, 13.379)
            ..cubicTo(11.541, 14.183, 10.244, 14.662, 8.835, 14.662)
            ..cubicTo(5.477, 14.662, 2.754, 11.94, 2.754, 8.581)
            ..cubicTo(2.754, 5.223, 5.477, 2.5, 8.835, 2.5)
            ..cubicTo(12.194, 2.5, 14.916, 5.223, 14.916, 8.581)
            ..cubicTo(14.916, 9.99, 14.437, 11.287, 13.633, 12.318)
            ..lineTo(17.464, 16.149)
            ..cubicTo(17.563, 16.248, 17.612, 16.297, 17.645, 16.346)
            ..cubicTo(17.78, 16.548, 17.78, 16.811, 17.645, 17.013)
            ..cubicTo(17.612, 17.062, 17.563, 17.111, 17.464, 17.21)
            ..cubicTo(17.366, 17.308, 17.316, 17.358, 17.267, 17.39)
            ..cubicTo(17.065, 17.525, 16.802, 17.525, 16.601, 17.39)
            ..cubicTo(16.551, 17.358, 16.502, 17.308, 16.403, 17.21)
            ..lineTo(12.572, 13.379)
            ..close()
            ..moveTo(13.416, 8.581)
            ..cubicTo(13.416, 11.111, 11.365, 13.162, 8.835, 13.162)
            ..cubicTo(6.305, 13.162, 4.254, 11.111, 4.254, 8.581)
            ..cubicTo(4.254, 6.051, 6.305, 4.0, 8.835, 4.0)
            ..cubicTo(11.365, 4.0, 13.416, 6.051, 13.416, 8.581)
            ..close(),
        ),
      ],
    );

MiuixVectorIcon _buildSearchCleanup() => MiuixVectorIcon(
      name: 'SearchCleanup',
      viewport: const Size(68, 68),
      intrinsicSize: const Size(18.199984, 18.199984),
      paths: [
        // 底盘圆（白 6%）。
        MiuixVectorPath(
          color: const Color(0xFFFFFFFF),
          alpha: 0.06,
          build: () => Path()
            ..moveTo(34, 66)
            ..cubicTo(51.6731, 66, 66, 51.6731, 66, 34)
            ..cubicTo(66, 16.3269, 51.6731, 2, 34, 2)
            ..cubicTo(16.3269, 2, 2, 16.3269, 2, 34)
            ..cubicTo(2, 51.6731, 16.3269, 66, 34, 66)
            ..close(),
        ),
        // 外描边圈（黑 10%，发丝线）。
        MiuixVectorPath(
          style: PaintingStyle.stroke,
          strokeWidth: 0.0,
          color: const Color(0xFF000000),
          alpha: 0.1,
          build: () => Path()
            ..moveTo(34, 67)
            ..cubicTo(52.2254, 67, 67, 52.2254, 67, 34)
            ..cubicTo(67, 15.7746, 52.2254, 1, 34, 1)
            ..cubicTo(15.7746, 1, 1, 15.7746, 1, 34)
            ..cubicTo(1, 52.2254, 15.7746, 67, 34, 67)
            ..close(),
        ),
        // 中心 'x'（白 30%）。
        MiuixVectorPath(
          color: const Color(0xFFFFFFFF),
          alpha: 0.3,
          build: () => miuixEvenOddPath()
            ..moveTo(44.6066, 27.8492)
            ..cubicTo(45.7782, 26.6777, 45.7782, 24.7782, 44.6066, 23.6066)
            ..cubicTo(43.435, 22.435, 41.5355, 22.435, 40.364, 23.6066)
            ..lineTo(34, 29.9706)
            ..lineTo(27.636, 23.6066)
            ..cubicTo(26.4645, 22.435, 24.565, 22.435, 23.3934, 23.6066)
            ..cubicTo(22.2218, 24.7782, 22.2218, 26.6777, 23.3934, 27.8492)
            ..lineTo(29.7574, 34.2132)
            ..lineTo(23.3934, 40.5772)
            ..cubicTo(22.2218, 41.7487, 22.2218, 43.6482, 23.3934, 44.8198)
            ..cubicTo(24.565, 45.9914, 26.4645, 45.9914, 27.636, 44.8198)
            ..lineTo(34, 38.4558)
            ..lineTo(40.364, 44.8198)
            ..cubicTo(41.5355, 45.9914, 43.435, 45.9914, 44.6066, 44.8198)
            ..cubicTo(45.7782, 43.6482, 45.7782, 41.7487, 44.6066, 40.5772)
            ..lineTo(38.2426, 34.2132)
            ..lineTo(44.6066, 27.8492)
            ..close(),
        ),
      ],
    );
MiuixVectorIcon _buildSidebar() {
  // group(scaleY = -1, translationY = 1224)：先平移再翻转 Y（Compose 变换顺序）。
  final transform = Matrix4.identity()
    ..translateByDouble(0.0, 1224.0, 0.0, 1.0)
    ..scaleByDouble(1.0, -1.0, 1.0, 1.0);
  return MiuixVectorIcon(
    name: 'Sidebar',
    viewport: const Size(1224, 1224),
    intrinsicSize: _size24,
    paths: [
      MiuixVectorPath(
        groupTransform: transform,
        build: () => Path()
          ..moveTo(1001.2, 199.5)
          ..quadraticBezierTo(1054.5, 226.4, 1081.4, 279.7)
          ..quadraticBezierTo(1095.1, 306.8, 1098.5, 344.8)
          ..quadraticBezierTo(1101.8, 382.8, 1101.8, 471.9)
          ..lineTo(1101.8, 752.1)
          ..quadraticBezierTo(1101.8, 841.2, 1098.5, 879.2)
          ..quadraticBezierTo(1095.1, 917.2, 1081.4, 944.3)
          ..quadraticBezierTo(1054.5, 997.6, 1001.2, 1024.5)
          ..quadraticBezierTo(974.1, 1038.2, 936.1, 1041.6)
          ..quadraticBezierTo(898.1, 1044.9, 809.0, 1044.9)
          ..lineTo(415.0, 1044.9)
          ..quadraticBezierTo(325.9, 1044.9, 287.4, 1041.6)
          ..quadraticBezierTo(248.9, 1038.2, 221.9, 1024.5)
          ..quadraticBezierTo(169.6, 997.6, 141.6, 944.3)
          ..quadraticBezierTo(128.1, 917.2, 125.1, 879.2)
          ..quadraticBezierTo(122.2, 841.2, 122.2, 752.1)
          ..lineTo(122.2, 471.9)
          ..quadraticBezierTo(122.2, 382.8, 125.1, 344.8)
          ..quadraticBezierTo(128.1, 306.8, 141.6, 279.7)
          ..quadraticBezierTo(169.6, 226.4, 221.9, 199.5)
          ..quadraticBezierTo(248.9, 185.8, 287.4, 182.4)
          ..quadraticBezierTo(325.9, 179.1, 415.0, 179.1)
          ..lineTo(809.0, 179.1)
          ..quadraticBezierTo(898.1, 179.1, 936.1, 182.4)
          ..quadraticBezierTo(974.1, 185.8, 1001.2, 199.5)
          ..close()
          ..moveTo(263.7, 275.6)
          ..quadraticBezierTo(234.7, 291.6, 218.7, 320.7)
          ..quadraticBezierTo(211.2, 335.7, 209.3, 357.4)
          ..quadraticBezierTo(207.5, 379.1, 207.5, 429.8)
          ..lineTo(207.5, 793.3)
          ..quadraticBezierTo(207.5, 844.8, 209.3, 866.1)
          ..quadraticBezierTo(211.2, 887.4, 218.7, 902.4)
          ..quadraticBezierTo(235.5, 933.4, 263.7, 947.4)
          ..quadraticBezierTo(278.8, 955.0, 300.5, 956.8)
          ..quadraticBezierTo(322.2, 958.6, 372.9, 958.6)
          ..lineTo(521.0, 958.6)
          ..lineTo(521.0, 264.4)
          ..lineTo(372.9, 264.4)
          ..quadraticBezierTo(322.2, 264.4, 300.5, 266.3)
          ..quadraticBezierTo(278.8, 268.1, 263.7, 275.6)
          ..close()
          ..moveTo(445.6, 830.9)
          ..lineTo(445.6, 857.3)
          ..quadraticBezierTo(445.6, 871.1, 438.1, 878.6)
          ..quadraticBezierTo(430.7, 886.0, 416.8, 886.0)
          ..lineTo(316.5, 886.0)
          ..quadraticBezierTo(304.3, 886.0, 295.6, 879.5)
          ..quadraticBezierTo(286.8, 872.9, 286.8, 859.1)
          ..lineTo(286.8, 829.1)
          ..quadraticBezierTo(286.8, 815.2, 295.6, 808.7)
          ..quadraticBezierTo(304.3, 802.2, 316.5, 802.2)
          ..lineTo(416.8, 802.2)
          ..quadraticBezierTo(430.7, 802.2, 438.1, 810.0)
          ..quadraticBezierTo(445.6, 817.9, 445.6, 830.9)
          ..close()
          ..moveTo(606.4, 958.6)
          ..lineTo(850.2, 958.6)
          ..quadraticBezierTo(901.7, 958.6, 923.0, 956.8)
          ..quadraticBezierTo(944.3, 955.0, 960.3, 947.4)
          ..quadraticBezierTo(974.3, 939.9, 986.0, 928.6)
          ..quadraticBezierTo(997.7, 917.3, 1004.4, 902.4)
          ..quadraticBezierTo(1011.9, 887.4, 1013.7, 866.1)
          ..quadraticBezierTo(1015.5, 844.8, 1015.5, 793.3)
          ..lineTo(1015.5, 429.8)
          ..quadraticBezierTo(1015.5, 379.1, 1013.7, 357.4)
          ..quadraticBezierTo(1011.9, 335.7, 1004.4, 320.7)
          ..quadraticBezierTo(991.1, 292.4, 960.3, 275.6)
          ..quadraticBezierTo(944.3, 268.1, 923.0, 266.3)
          ..quadraticBezierTo(901.7, 264.4, 850.2, 264.4)
          ..lineTo(606.4, 264.4)
          ..close()
          ..moveTo(445.6, 685.8)
          ..lineTo(445.6, 712.2)
          ..quadraticBezierTo(445.6, 726.0, 438.1, 733.4)
          ..quadraticBezierTo(430.7, 740.9, 416.8, 740.9)
          ..lineTo(316.5, 740.9)
          ..quadraticBezierTo(304.3, 740.9, 295.6, 734.4)
          ..quadraticBezierTo(286.8, 727.9, 286.8, 713.9)
          ..lineTo(286.8, 684.0)
          ..quadraticBezierTo(286.8, 670.2, 295.6, 663.6)
          ..quadraticBezierTo(304.3, 657.0, 316.5, 657.0)
          ..lineTo(416.8, 657.0)
          ..quadraticBezierTo(430.7, 657.0, 438.1, 664.9)
          ..quadraticBezierTo(445.6, 672.7, 445.6, 685.8)
          ..close()
          ..moveTo(445.6, 541.7)
          ..lineTo(445.6, 568.0)
          ..quadraticBezierTo(445.6, 581.9, 438.1, 589.4)
          ..quadraticBezierTo(430.7, 596.9, 416.8, 596.9)
          ..lineTo(316.5, 596.9)
          ..quadraticBezierTo(304.3, 596.9, 295.6, 590.3)
          ..quadraticBezierTo(286.8, 583.7, 286.8, 569.9)
          ..lineTo(286.8, 539.9)
          ..quadraticBezierTo(286.8, 526.0, 295.6, 519.4)
          ..quadraticBezierTo(304.3, 512.8, 316.5, 512.8)
          ..lineTo(416.8, 512.8)
          ..quadraticBezierTo(430.7, 512.8, 438.1, 520.8)
          ..quadraticBezierTo(445.6, 528.7, 445.6, 541.7)
          ..close(),
      ),
    ],
  );
}


