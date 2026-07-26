// Miuix Flutter 移植版 - Bloom 高光边框着色器（阶段 5C，single-peak 变体）
// 源自 compose-miuix-ui/miuix 的 Shaders.kt buildBloomStrokeShader(dualPeak=false)。
// 圆角矩形 SDF + 3D 半球 rim 法线 + 两个方向光，画出被照亮的玻璃边缘。
// SkSL→GLSL：half→float，float2/3/4→vec2/3/4，layout(color) half4→普通 vec4。
// SPDX-License-Identifier: Apache-2.0
#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

// uniform 顺序即 setFloat 下标（见 miuix_highlight.dart）。
uniform vec2 halfView;          // 区域半尺寸（像素）
uniform vec2 halfViewFloor;     // floor(halfView)
uniform vec4 cornerRadii;       // [TL, TR, BL, BR] 像素圆角
uniform float strokeWidth;      // 描边带宽（像素）
uniform float innerBlurRadius;  // 内发光halo深度（像素）
uniform float innerBlurRadiusSq;// innerBlurRadius^2
uniform float highlightAlpha;   // 整体不透明度
uniform vec4 strokeColor;       // 描边色（rgb，a=1）
uniform float strokeAlphaMul;   // 描边色原始 alpha 乘子
uniform vec3 lightDir1;
uniform vec3 lightColor1;
uniform float lightIntensity1;
uniform vec3 lightDir2;
uniform vec3 lightColor2;
uniform float lightIntensity2;
uniform vec2 axis1;             // single-peak 的方向轴
uniform vec2 axis2;

out vec4 fragColor;

// 按象限选圆角半径（对应 pickRadius）。
float pickRadius(vec2 fragCoord, vec4 radii) {
    vec2 up = fragCoord.y < halfView.y ? radii.xy : radii.zw;
    return fragCoord.x < halfView.x ? up.x : up.y;
}

// 圆角矩形 SDF（pos 已 abs 折叠）。
float roundedBoxSDF(vec2 pos, vec2 halfSize, float radius) {
    radius = min(radius, min(halfSize.x, halfSize.y));
    vec2 d = pos - halfSize + radius;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

// 3D 半球 rim 法线。
vec3 getNormal(vec2 fragCoord, float sdf, float R) {
    vec2 xy = fragCoord - halfViewFloor;
    vec2 xy_a = abs(xy);
    float t = smoothstep(-innerBlurRadius, 0.0, sdf);
    float z = sqrt(max(innerBlurRadiusSq - t * t, 0.0));
    vec3 coord = vec3(xy_a, -z);

    vec2 corner = halfView - R;
    corner.x = min(corner.x, xy_a.x);
    corner.y = min(corner.y, xy_a.y);

    vec2 dir = normalize(coord.xy - corner.xy);
    corner += dir * (R - innerBlurRadius);

    if (xy_a.x < corner.x || xy_a.y < corner.y) {
        return vec3(0.0, 0.0, -1.0);
    }

    vec2 signal = sign(xy);
    vec3 n = normalize(coord - vec3(corner, 0.0));
    n.xy *= signal;
    return n;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 xy = abs(fragCoord - halfView);

    float originRadius = pickRadius(fragCoord, cornerRadii);
    float R = max(originRadius, innerBlurRadius);

    if (xy.x < halfView.x - R && xy.y < halfView.y - R) {
        fragColor = vec4(0.0);
        return;
    }

    float sdf = roundedBoxSDF(xy, halfView, originRadius);
    float outMask = smoothstep(0.0, -1.0, sdf);
    float strokeAlpha = smoothstep(-strokeWidth, -strokeWidth + 1.0, sdf);

    // stroke = strokeColor.rgb * strokeAlphaMul * strokeAlpha^2
    vec3 rgb = strokeColor.rgb * (strokeAlphaMul * strokeAlpha * strokeAlpha);

    vec3 n = getNormal(fragCoord, sdf, R);

    // single-peak：轴向 falloff × 方向光点积，平方增强。
    float falloff1 = max(dot(vec3(axis1, 0.0), n), 0.0);
    float light1 = clamp(dot(n, lightDir1) * falloff1, 0.0, 1.0);
    rgb += (light1 * light1 * lightIntensity1) * lightColor1;

    float falloff2 = max(dot(vec3(axis2, 0.0), n), 0.0);
    float light2 = clamp(dot(n, lightDir2) * falloff2, 0.0, 1.0);
    rgb += (light2 * light2 * lightIntensity2) * lightColor2;

    fragColor = vec4(rgb * highlightAlpha, 1.0) * outMask;
}
