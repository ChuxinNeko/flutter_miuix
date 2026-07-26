import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 按钮类组件演示：MiuixButton / MiuixTextButton / MiuixIconButton /
/// MiuixFloatingActionButton。
///
/// [MiuixButton] 内部已用 `DefaultTextStyle.merge(theme.textStyles.button)`
/// 注入 17sp button 样式，所以 child 直接用 [Text] 即可，颜色由
/// [MiuixContentColor] 控制；所有图标统一使用 [MiuixIcon] +
/// [MiuixIcons.extended] 矢量图标；同组演示均用 [GroupCard] 收拢为圆角卡片。
class ButtonsShowcase extends StatelessWidget {
  const ButtonsShowcase({super.key});

  /// 分组卡片内列表项的统一内边距。
  static const _itemMargin =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return ShowcasePage(
      title: '按钮 Button',
      subtitle: 'MiuixButton / TextButton / IconButton / FAB',
      sections: [
        ShowcaseSection('MiuixButton', [_buttonCard(context, colors)]),
        ShowcaseSection('MiuixTextButton', [
          _textButtonCard(context, colors),
        ]),
        ShowcaseSection('MiuixIconButton', [_iconButtonCard(context, colors)]),
        ShowcaseSection('MiuixFloatingActionButton', [
          _fabBlock(context, colors),
        ]),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixButton：Primary / Secondary / Error / Disabled
  // ─────────────────────────────────────────────
  Widget _buttonCard(BuildContext context, MiuixColors colors) {
    return GroupCard(
      children: [
        Padding(
          padding: _itemMargin,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // 主色按钮：使用 buttonColorsPrimary 预设
              MiuixButton(
                onPressed: () {},
                colors: MiuixButtonDefaults.buttonColorsPrimary(context),
                child: const Text('Primary'),
              ),
              // 次级按钮：默认 colors = buttonColors（secondaryVariant）
              MiuixButton(
                onPressed: () {},
                child: const Text('Secondary'),
              ),
              // 自定义 Error 按钮
              MiuixButton(
                onPressed: () {},
                colors: MiuixButtonColors(
                  color: colors.error,
                  disabledColor: colors.error.withValues(alpha: 0.5),
                  contentColor: colors.onError,
                  disabledContentColor: colors.onError.withValues(alpha: 0.5),
                ),
                child: const Text('Error'),
              ),
              // 禁用态：onPressed 为 null
              MiuixButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixTextButton：默认 / Primary / Disabled
  // ─────────────────────────────────────────────
  Widget _textButtonCard(BuildContext context, MiuixColors colors) {
    return GroupCard(
      children: [
        Padding(
          padding: _itemMargin,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MiuixTextButton('确定', onPressed: () {}),
              MiuixTextButton('取消', onPressed: () {}),
              MiuixTextButton(
                'Primary',
                onPressed: () {},
                colors: MiuixButtonDefaults.buttonColorsPrimary(context),
              ),
              MiuixTextButton('禁用', onPressed: null, enabled: false),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixIconButton：透明 / 主色背景 / holdDownState / Disabled
  // ─────────────────────────────────────────────
  Widget _iconButtonCard(BuildContext context, MiuixColors colors) {
    return GroupCard(
      children: [
        Padding(
          padding: _itemMargin,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // 透明背景：默认 IconButton
              MiuixIconButton(
                onPressed: () {},
                child: MiuixIcon(
                  vector: MiuixIcons.extended.byName('favoritesFill')!,
                ),
              ),
              MiuixIconButton(
                onPressed: () {},
                child: MiuixIcon(vector: MiuixIcons.extended.byName('share')!),
              ),
              MiuixIconButton(
                onPressed: () {},
                child: MiuixIcon(
                  vector: MiuixIcons.extended.byName('settings')!,
                ),
              ),
              // 主色背景：custom backgroundColor + onPrimary tint
              MiuixIconButton(
                onPressed: () {},
                backgroundColor: colors.primary,
                child: MiuixIcon(
                  vector: MiuixIcons.extended.byName('add')!,
                  tint: colors.onPrimary,
                ),
              ),
              // holdDownState：强制按住态（如下拉菜单展开期间）
              MiuixIconButton(
                onPressed: () {},
                holdDownState: true,
                child: MiuixIcon(vector: MiuixIcons.extended.byName('more')!),
              ),
              // Disabled
              MiuixIconButton(
                onPressed: null,
                child: MiuixIcon(
                  vector: MiuixIcons.extended.byName('delete')!,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixFloatingActionButton：Primary / Secondary / Error
  // ─────────────────────────────────────────────
  // 注意：FAB 内容色默认继承 onSurface（而非 onPrimary），故需显式 tint
  // 才能在彩色背景上正常显示。
  Widget _fabBlock(BuildContext context, MiuixColors colors) {
    return ShowcaseBlock(
      children: [
        Row(
          children: [
            MiuixFloatingActionButton(
              onPressed: () {},
              child: MiuixIcon(
                vector: MiuixIcons.extended.byName('add')!,
                tint: colors.onPrimary,
              ),
            ),
            const SizedBox(width: 24),
            MiuixFloatingActionButton(
              onPressed: () {},
              containerColor: colors.secondary,
              child: MiuixIcon(
                vector: MiuixIcons.extended.byName('edit')!,
                tint: colors.onSecondary,
              ),
            ),
            const SizedBox(width: 24),
            MiuixFloatingActionButton(
              onPressed: () {},
              containerColor: colors.error,
              child: MiuixIcon(
                vector: MiuixIcons.extended.byName('delete')!,
                tint: colors.onError,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
