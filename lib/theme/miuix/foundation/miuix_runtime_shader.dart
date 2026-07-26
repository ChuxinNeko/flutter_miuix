// Miuix Flutter 移植版 - RuntimeShader / RenderEffect 能力封装
// 源自 compose-miuix-ui/miuix 的 miuix-shader 模块
// （shader/RuntimeShader.kt + RenderEffect.kt 及各平台 actual）。
// Compose 侧是对 AGSL(Android)/SkSL(Skia) 运行时着色器的跨平台封装；
// Flutter 侧对应 dart:ui 的 FragmentProgram/FragmentShader（预编译 .frag GLSL）。
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui' as ui;

/// 是否支持基于 `RenderEffect` 的效果（模糊等）。对应 Kotlin `isRenderEffectSupported()`。
///
/// Flutter 的 `ImageFilter`/`BackdropFilter` 在所有目标平台都可用，故恒为 true
/// （对应原版 skiko `= true`；Android 原版是 SDK≥S，Flutter 无此限制）。
bool isRenderEffectSupported() => true;

/// 是否支持运行时着色器。对应 Kotlin `isRuntimeShaderSupported()`。
///
/// Flutter 的 `FragmentProgram` 在 Impeller/Skia 上均可用，恒为 true
/// （对应原版 skiko `= true`）。
bool isRuntimeShaderSupported() => true;

/// 运行时着色器的跨平台封装。对应 Kotlin `interface RuntimeShader`。
///
/// **与原版的关键差异（务必了解）**：
/// - Kotlin 侧从**运行时字符串**编译 AGSL/SkSL，uniform 按**名字**设置
///   （`setFloatUniform("name", ...)`）。
/// - Flutter 的 `FragmentShader` 只能由**预编译的 `.frag` 资源**（经 impellerc）产生，
///   uniform 按**下标**设置（`setFloat(index, value)`）。因此本封装：
///   1. 由 [MiuixRuntimeShader.fromProgram] 用已加载的 [ui.FragmentProgram] 构造；
///   2. 通过 [uniformLayout]（uniform 名 → 起始 float 下标）把名字翻译成下标，
///      从而保留 Kotlin 端「按名设 uniform」的调用风格；
///   3. sampler（子着色器）通过 [samplerLayout]（名 → sampler 下标）设置。
///
/// 着色器源码不再内联于 Dart，而是作为 `.frag` 资源随包分发（批次 5 液态玻璃/模糊
/// 会提供具体 `.frag` 与对应 layout）。
class MiuixRuntimeShader {
  MiuixRuntimeShader.fromProgram(
    ui.FragmentProgram program, {
    this.uniformLayout = const {},
    this.samplerLayout = const {},
  }) : shader = program.fragmentShader();

  /// 底层 Flutter 着色器。可直接作为 [ui.Shader] 用于 `Paint..shader`。
  final ui.FragmentShader shader;

  /// uniform 名 → 起始 float 下标。用于把按名设值翻译为 [ui.FragmentShader.setFloat]。
  final Map<String, int> uniformLayout;

  /// sampler 名 → sampler 下标。用于 [ui.FragmentShader.setImageSampler]。
  final Map<String, int> samplerLayout;

  int _indexOf(String name) {
    final i = uniformLayout[name];
    if (i == null) {
      throw ArgumentError('未知 uniform "$name"，请在 uniformLayout 中登记其起始下标');
    }
    return i;
  }

  /// 设置单分量 `float`。对应 `setFloatUniform(name, value)`。
  void setFloatUniform(String name, double value) {
    shader.setFloat(_indexOf(name), value);
  }

  /// 设置 `vec2`。对应 `setFloatUniform(name, v1, v2)`。
  void setFloat2Uniform(String name, double v1, double v2) {
    final i = _indexOf(name);
    shader
      ..setFloat(i, v1)
      ..setFloat(i + 1, v2);
  }

  /// 设置 `vec3`。对应 `setFloatUniform(name, v1, v2, v3)`。
  void setFloat3Uniform(String name, double v1, double v2, double v3) {
    final i = _indexOf(name);
    shader
      ..setFloat(i, v1)
      ..setFloat(i + 1, v2)
      ..setFloat(i + 2, v3);
  }

  /// 设置 `vec4`。对应 `setFloatUniform(name, v1, v2, v3, v4)`。
  void setFloat4Uniform(
      String name, double v1, double v2, double v3, double v4) {
    final i = _indexOf(name);
    shader
      ..setFloat(i, v1)
      ..setFloat(i + 1, v2)
      ..setFloat(i + 2, v3)
      ..setFloat(i + 3, v4);
  }

  /// 从数组设置 `float` uniform。对应 `setFloatUniform(name, FloatArray)`。
  void setFloatArrayUniform(String name, List<double> values) {
    final i = _indexOf(name);
    for (var k = 0; k < values.length; k++) {
      shader.setFloat(i + k, values[k]);
    }
  }

  /// 以 `vec4` 设置颜色（RGBA，分量 0..1）。对应 `setColorUniform(name, Color)`。
  void setColorUniform(String name, ui.Color color) {
    setFloat4Uniform(name, color.r, color.g, color.b, color.a);
  }

  /// 绑定子输入着色器（如被模糊的图层快照）。对应 `setInputShader(name, shader)`。
  void setInputShader(String name, ui.Image image) {
    final i = samplerLayout[name];
    if (i == null) {
      throw ArgumentError('未知 sampler "$name"，请在 samplerLayout 中登记其下标');
    }
    shader.setImageSampler(i, image);
  }

  /// 释放底层资源。Flutter 的 [ui.FragmentShader] 需显式 dispose。
  void dispose() => shader.dispose();
}
