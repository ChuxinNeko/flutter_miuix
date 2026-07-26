import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 反馈类组件演示：Snackbar / Tooltip / ProgressIndicator / Dialog / Badge。
class FeedbackShowcase extends StatefulWidget {
  const FeedbackShowcase({super.key});

  @override
  State<FeedbackShowcase> createState() => _FeedbackShowcaseState();
}

class _FeedbackShowcaseState extends State<FeedbackShowcase> {
  final _snackbarHost = MiuixSnackbarHostState();
  // Rich Tooltip 使用持久状态，点击按钮时手动弹出。
  final _richTooltipState = MiuixTooltipState(isPersistent: true);
  // 线性进度：自动播放模拟下载，比手动 +20% 更直观。
  double _linearProgress = 0.0;
  bool _autoPlaying = false;
  Timer? _progressTimer;
  bool _showBasicDialog = false;
  bool _showConfirmDialog = false;

  /// 分组卡片内 demo 项的统一内边距。
  static const _cardPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  void dispose() {
    _progressTimer?.cancel();
    _snackbarHost.dispose();
    _richTooltipState.dispose();
    super.dispose();
  }

  void _startAutoProgress() {
    if (_autoPlaying) return;
    if (_linearProgress >= 1.0) _linearProgress = 0.0;
    setState(() => _autoPlaying = true);
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _linearProgress += 0.012;
        if (_linearProgress >= 1.0) {
          _linearProgress = 1.0;
          _autoPlaying = false;
          t.cancel();
        }
      });
    });
  }

  void _pauseAutoProgress() {
    _progressTimer?.cancel();
    _progressTimer = null;
    if (mounted) setState(() => _autoPlaying = false);
  }

  void _resetAutoProgress() {
    _progressTimer?.cancel();
    _progressTimer = null;
    if (mounted) {
      setState(() {
        _linearProgress = 0.0;
        _autoPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    return ShowcasePage(
      title: '反馈 Feedback',
      subtitle: 'Snackbar / Tooltip / Progress / Dialog / Badge',
      // 组件库内置毛玻璃能力：blurSigma=30 + 半透明背景
      snackbarHost: MiuixSnackbarHost(
        state: _snackbarHost,
        blurSigma: 30,
        blurBackgroundAlpha: 0.55,
      ),
      overlay: Stack(
        children: [
          MiuixOverlayDialog(
            show: _showBasicDialog,
            title: '提示',
            summary: '这是一个基础对话框，展示简单的信息内容。',
            onDismissRequest: () => setState(() => _showBasicDialog = false),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                MiuixText(
                  '对话框内容区域可以放置任意 Flutter 组件。Miuix 对话框在大屏幕居中显示，小屏幕从底部弹出。',
                  style: ts.body2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MiuixTextButton(
                      '知道了',
                      onPressed: () =>
                          setState(() => _showBasicDialog = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MiuixOverlayDialog(
            show: _showConfirmDialog,
            title: '确认删除',
            summary: '此操作不可撤销',
            onDismissRequest: () => setState(() => _showConfirmDialog = false),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                MiuixText(
                  '你确定要删除这个项目吗？删除后将无法恢复。',
                  style: ts.body1,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MiuixTextButton(
                      '取消',
                      onPressed: () =>
                          setState(() => _showConfirmDialog = false),
                    ),
                    const SizedBox(width: 12),
                    MiuixButton(
                      onPressed: () {
                        setState(() => _showConfirmDialog = false);
                        _snackbarHost.showSnackbar('已删除');
                      },
                      child: MiuixText('删除', style: ts.button),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      sections: [
        ShowcaseSection('MiuixSnackbar', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MiuixButton(
                    onPressed: () => _snackbarHost.showSnackbar('这是一条消息'),
                    child: MiuixText('短消息 4s', style: ts.button),
                  ),
                  MiuixButton(
                    onPressed: () => _snackbarHost.showSnackbar(
                      '文件已保存到本地目录，可随时查看历史记录',
                      duration: MiuixSnackbarDuration.long,
                    ),
                    child: MiuixText('长消息 10s', style: ts.button),
                  ),
                  MiuixButton(
                    onPressed: () => _snackbarHost.showSnackbar(
                      '操作已完成',
                      actionLabel: '查看',
                    ),
                    child: MiuixText('带操作', style: ts.button),
                  ),
                  MiuixButton(
                    onPressed: () => _snackbarHost.showSnackbar(
                      '可滑动关闭',
                      withDismissAction: true,
                      duration: MiuixSnackbarDuration.indefinite,
                    ),
                    child: MiuixText('可关闭', style: ts.button),
                  ),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixBadge', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiuixText(
                    '圆点徽标、数字徽标与自定义色徽标，常用于图标右上角的状态提示。',
                    style: ts.body2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _badgedIcon(
                        Icons.notifications_none,
                        const MiuixBadge(),
                        '圆点',
                      ),
                      const SizedBox(width: 32),
                      _badgedIcon(
                        Icons.email_outlined,
                        const MiuixBadge(child: MiuixText('8')),
                        '数字',
                      ),
                      const SizedBox(width: 32),
                      _badgedIcon(
                        Icons.favorite_border,
                        MiuixBadge(
                          containerColor: MiuixTheme.of(context).colors.primary,
                          contentColor: MiuixTheme.of(context).colors.onPrimary,
                          child: const MiuixText('NEW'),
                        ),
                        '自定义',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixTooltip', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: MiuixTooltipBox(
                tooltip: (context, scope) => MiuixPlainTooltip(
                  scope: scope,
                  child: MiuixText('这是一个 Tooltip 提示', style: ts.body2),
                ),
                child: MiuixIconButton(
                  onPressed: () {},
                  child: const Icon(Icons.info),
                ),
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixRichTooltip', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiuixText('点击按钮弹出带标题、正文和操作的富提示。', style: ts.body2),
                  const SizedBox(height: 12),
                  MiuixRichTooltipBox(
                    state: _richTooltipState,
                    title: '新功能',
                    text: '富提示可以承载更长的说明文字、标题以及一个操作按钮，'
                        '适合用于引导或展示较复杂的信息。',
                    actionText: '知道了',
                    onActionPressed: () => _snackbarHost.showSnackbar('已确认'),
                    positioning: MiuixTooltipAnchorPosition.below,
                    showCaret: true,
                    child: MiuixButton(
                      onPressed: _richTooltipState.show,
                      child: MiuixText('查看富提示', style: ts.button),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixOverlayDialog', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MiuixButton(
                    onPressed: () => setState(() => _showBasicDialog = true),
                    child: MiuixText('基础对话框', style: ts.button),
                  ),
                  MiuixButton(
                    onPressed: () => setState(() => _showConfirmDialog = true),
                    child: MiuixText('确认对话框', style: ts.button),
                  ),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixLinearProgressIndicator', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiuixText(
                    '模拟下载',
                    style: ts.body2,
                    color: MiuixTheme.of(context).colors.onSurfaceVariantSummary,
                  ),
                  const SizedBox(height: 10),
                  MiuixLinearProgressIndicator(progress: _linearProgress),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      MiuixButton(
                        onPressed: _autoPlaying ? null : _startAutoProgress,
                        child: MiuixText(
                          _linearProgress >= 1.0 ? '重新开始' : '开始',
                          style: ts.button,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MiuixTextButton(
                        _autoPlaying ? '暂停' : '重置',
                        onPressed: _autoPlaying
                            ? _pauseAutoProgress
                            : _resetAutoProgress,
                      ),
                      const Spacer(),
                      MiuixText(
                        '${(_linearProgress * 100).round()}%',
                        style: ts.body2,
                        color: MiuixTheme.of(context).colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const IndentDivider(),
            Padding(
              padding: _cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiuixText(
                    '不确定',
                    style: ts.body2,
                    color: MiuixTheme.of(context).colors.onSurfaceVariantSummary,
                  ),
                  const SizedBox(height: 10),
                  const MiuixLinearProgressIndicator(),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixCircularProgressIndicator', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Row(
                children: [
                  _circularDemo(
                    const MiuixCircularProgressIndicator(progress: 0.7),
                    '确定进度 70%',
                  ),
                  const SizedBox(width: 32),
                  _circularDemo(
                    const MiuixCircularProgressIndicator(),
                    '不确定',
                  ),
                  const SizedBox(width: 32),
                  _circularDemo(
                    const MiuixInfiniteProgressIndicator(),
                    '无限循环',
                  ),
                ],
              ),
            ),
          ]),
        ]),
      ],
    );
  }

  /// 徽标演示：图标 + 徽标 + 下方标签。
  Widget _badgedIcon(IconData icon, Widget badge, String label) {
    final ts = MiuixTheme.of(context).textStyles;
    final colors = MiuixTheme.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiuixBadgedBox(
          badge: badge,
          child: MiuixIconButton(
            onPressed: () {},
            child: Icon(icon),
          ),
        ),
        const SizedBox(height: 8),
        MiuixText(
          label,
          style: ts.footnote1,
          color: colors.onSurfaceVariantSummary,
        ),
      ],
    );
  }

  /// 圆形进度演示：组件 + 下方标签。
  Widget _circularDemo(Widget indicator, String label) {
    final ts = MiuixTheme.of(context).textStyles;
    final colors = MiuixTheme.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 30, height: 30, child: Center(child: indicator)),
        const SizedBox(height: 8),
        MiuixText(
          label,
          style: ts.footnote1,
          color: colors.onSurfaceVariantSummary,
        ),
      ],
    );
  }
}
