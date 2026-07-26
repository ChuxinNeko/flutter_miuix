#!/usr/bin/env python3
"""Miuix 扩展图标 Kotlin -> Dart 生成器（批次 3）。

解析 demo/miuix-main/miuix-icons/.../icon/extended/*.kt 里的 ImageVector 定义，
把每个图标的 5 个字重（Light/Normal/Regular/Medium/Demibold）压成紧凑的 SVG 路径
字符串，生成一个 Dart 文件，运行时用 miuixParsePath 还原。

关键事实（已核对全库 156 文件 / 780 path）：
- 每个字重恰好 1 个 addPath，fill=Black / fillAlpha=1 / pathFillType=NonZero。
- 视口正方形，group 恒为 scaleY=-1, translationY=viewportHeight（绕中心翻转 Y），
  个别文件（如 Home）无 group。
- PathNode 仅 7 种绝对指令：MoveTo/LineTo/HorizontalTo/VerticalTo/QuadTo/CurveTo/Close。
  HorizontalTo/VerticalTo 在此展开为完整 L（跟踪当前点）。
"""
import os
import re
import sys

SRC = os.path.join(
    "demo", "miuix-main", "miuix-icons", "src", "commonMain",
    "kotlin", "top", "yukonga", "miuix", "kmp", "icon", "extended",
)
OUT = os.path.join(
    "lib", "theme", "miuix", "icon", "miuix_extended_icons.dart",
)

WEIGHTS = ["Light", "Normal", "Regular", "Medium", "Demibold"]

# 抓一段 ImageVector.Builder(...).apply { ... }.build() 内的关键信息
NODE_RE = re.compile(r"PathNode\.(\w+)\(([^)]*)\)")


def fmt(n: float) -> str:
    """紧凑数字：去掉多余的 .0，避免字符串膨胀。"""
    if n == int(n):
        return str(int(n))
    return repr(round(n, 4)).rstrip("0").rstrip(".")


def parse_nodes(block: str):
    """把一个 addPath 的 PathNode 列表转成 SVG 命令串（仅 M/L/Q/C/Z 绝对指令）。

    跟踪当前点 (cx, cy) 以便把 HorizontalTo/VerticalTo 展开为 L。
    """
    out = []
    cx = cy = 0.0
    sx = sy = 0.0  # subpath 起点，用于 Close 后恢复当前点
    for m in NODE_RE.finditer(block):
        kind = m.group(1)
        args = [float(a) for a in re.findall(r"-?[0-9.]+", m.group(2).replace("f", ""))]
        if kind == "MoveTo":
            cx, cy = args[0], args[1]
            sx, sy = cx, cy
            out.append(f"M {fmt(cx)} {fmt(cy)}")
        elif kind == "LineTo":
            cx, cy = args[0], args[1]
            out.append(f"L {fmt(cx)} {fmt(cy)}")
        elif kind == "HorizontalTo":
            cx = args[0]
            out.append(f"L {fmt(cx)} {fmt(cy)}")
        elif kind == "VerticalTo":
            cy = args[0]
            out.append(f"L {fmt(cx)} {fmt(cy)}")
        elif kind == "QuadTo":
            cx, cy = args[2], args[3]
            out.append(f"Q {fmt(args[0])} {fmt(args[1])} {fmt(cx)} {fmt(cy)}")
        elif kind == "CurveTo":
            cx, cy = args[4], args[5]
            out.append(
                f"C {fmt(args[0])} {fmt(args[1])} {fmt(args[2])} {fmt(args[3])} "
                f"{fmt(cx)} {fmt(cy)}"
            )
        elif kind == "Close":
            out.append("Z")
            cx, cy = sx, sy
        else:
            raise SystemExit(f"未知 PathNode: {kind}")
    return " ".join(out)


def lower_first(s: str) -> str:
    return s[0].lower() + s[1:] if s else s


def parse_file(path):
    """返回 (iconName, viewport(float), {weight: svgPathData})。"""
    text = open(path, encoding="utf-8").read()
    icon_name = None
    # 顶部：val MiuixIcons.<Name>: ImageVector（默认别名，取 <Name>）
    m = re.search(r"val MiuixIcons\.(\w+): ImageVector", text)
    if m:
        icon_name = m.group(1)

    # weight -> dict(vp=float, flip=bool, data=str)
    weights = {}
    # 每个字重的 getter：val MiuixIcons.<Weight>.<Name> ... ImageVector.Builder(...).apply { ... }.build()
    for wm in re.finditer(
        r"val MiuixIcons\.(\w+)\.(\w+): ImageVector\s*\n\s*get\(\) \{(.*?)\n    \}",
        text, re.DOTALL,
    ):
        weight, name, body = wm.group(1), wm.group(2), wm.group(3)
        if weight not in WEIGHTS:
            continue
        if icon_name is None:
            icon_name = name
        vw = re.search(r"viewportWidth = ([0-9.]+)f", body)
        vp = float(vw.group(1)) if vw else None
        # 是否有 group(scaleY = -1, translationY = ...) 翻转
        gm = re.search(r"group\(scaleY = -1\.0f, translationY = ([0-9.]+)f\)", body)
        flip = gm is not None
        # 取 addPath 里的 pathData listOf(...) 段
        pd = re.search(r"pathData = listOf\((.*?)\),\s*\n\s*fill = ", body, re.DOTALL)
        block = pd.group(1) if pd else ""
        weights[weight] = {"vp": vp, "flip": flip, "data": parse_nodes(block)}
    return icon_name, weights


def dart_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")


def main():
    files = sorted(
        f for f in os.listdir(SRC) if f.endswith(".kt")
    )
    icons = []  # (name, {weight: {vp, flip, data}})
    for f in files:
        name, weights = parse_file(os.path.join(SRC, f))
        if not name or len(weights) != 5 or any(
            weights[wt]["vp"] is None for wt in WEIGHTS
        ):
            print(f"跳过（结构异常）: {f} name={name} w={list(weights)}",
                  file=sys.stderr)
            continue
        icons.append((name, weights))

    print(f"解析到 {len(icons)} 个图标", file=sys.stderr)

    with open(OUT, "w", encoding="utf-8", newline="\n") as out:
        w = out.write
        w(HEADER)
        # 数据表：name -> 5 个 _W(viewport, flip, pathData)。运行时懒构建 MiuixVectorIcon。
        for name, weights in icons:
            key = lower_first(name)
            w(f"  '{key}': [\n")
            for wt in WEIGHTS:
                d = weights[wt]
                flip = "true" if d["flip"] else "false"
                w(f"    _W({fmt(d['vp'])}, {flip}, '{dart_escape(d['data'])}'),\n")
            w("  ],\n")
        w(FOOTER)
    print(f"已写出 {OUT}", file=sys.stderr)


HEADER = r'''// Miuix Flutter 移植版 - Extended Icons（自动生成，请勿手改）
// 源自 compose-miuix-ui/miuix 的 miuix-icons/.../icon/extended/*.kt。
// 由 tool/gen_extended_icons.py 生成：把每个图标 5 个字重的 PathNode 列表压成
// SVG 路径串，运行时经 miuixParsePath 还原为 MiuixVectorIcon。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_vector_icon.dart';

/// 扩展图标的字重。对应 Kotlin `MiuixIcons.{Light,Normal,Regular,Medium,Demibold}`。
enum MiuixIconWeight { light, normal, regular, medium, demibold }

/// 单个字重的原始数据：视口尺寸、是否需要绕中心翻转 Y、SVG 路径串。
class _W {
  const _W(this.viewport, this.flip, this.data);
  final double viewport;
  final bool flip;
  final String data;
}

/// 扩展图标集合。对应 Kotlin `MiuixIcons.Extended`（通过 `MiuixIcons.<Name>` 访问）。
///
/// 用法：`MiuixIcons.extended.byName('add')`（默认 Regular 字重）或
/// `MiuixIcons.extended.byName('add', MiuixIconWeight.light)` 取指定字重。
class MiuixExtendedIcons {
  /// 内部构造。请通过 `MiuixIcons.extended` 使用单例，勿直接实例化。
  const MiuixExtendedIcons.internal();

  /// 按名字取图标（默认 Regular）。名字为小驼峰（如 `addCircle`）。找不到返回 null。
  MiuixVectorIcon? byName(String name,
      [MiuixIconWeight weight = MiuixIconWeight.regular]) {
    final variants = _data[name];
    if (variants == null) return null;
    return _build(name, variants[weight.index], weight);
  }

  /// 所有图标名（小驼峰），按字母序。用于图标浏览页。
  List<String> get names => _data.keys.toList();
}

// 懒构建缓存：key = "name#weightIndex"。
final Map<String, MiuixVectorIcon> _cache = {};

MiuixVectorIcon _build(String name, _W v, MiuixIconWeight weight) {
  final cacheKey = '$name#${weight.index}';
  final cached = _cache[cacheKey];
  if (cached != null) return cached;
  final built = MiuixVectorIcon(
    name: name,
    viewport: Size(v.viewport, v.viewport),
    intrinsicSize: const Size(24, 24),
    paths: [
      MiuixVectorPath(
        // 部分图标（如 Home）无 group，则不翻转。
        groupTransform: v.flip ? _flipY(v.viewport) : null,
        build: () => miuixParsePath(v.data),
      ),
    ],
  );
  _cache[cacheKey] = built;
  return built;
}

// scaleY=-1 + translationY=vp，绕视口中心翻转 Y。
Matrix4 _flipY(double vp) => Matrix4.identity()
  ..translateByDouble(0.0, vp, 0.0, 1.0)
  ..scaleByDouble(1.0, -1.0, 1.0, 1.0);

/// 扩展图标原始数据表：小驼峰名 -> 5 个字重（顺序同 [MiuixIconWeight]）。
const Map<String, List<_W>> _data = {
'''

FOOTER = r'''};
'''

if __name__ == "__main__":
    main()

