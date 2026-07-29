# flutter-miuix-skill

**中文 | [English](#english)**

给 AI 编码工具（Claude Code 等支持 [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) 的助手）用的 [flutter_miuix](https://github.com/ChuxinNeko/flutter_miuix) 组件库使用指南。

一条命令即可把指南装进你的 Flutter 项目，之后 AI 用 flutter_miuix 搭界面时会自动获得
正确的组件用法、主题接线、组合范式与避坑要点（含 45+ 组件的中英双语 API 参考）。

## 使用

在你的 Flutter 项目根目录运行：

```bash
npx flutter-miuix-skill
```

装到 `.claude/skills/flutter-miuix/`。然后重启你的 AI 编码工具即可。

### 选项

```bash
npx flutter-miuix-skill --path <dir>   # 指定项目目录（默认当前目录）
npx flutter-miuix-skill --force        # 覆盖已存在的安装
npx flutter-miuix-skill --help         # 帮助
```

## 装了什么

```
.claude/skills/flutter-miuix/
  SKILL.md            # 快速上手 + 组件索引 + 组合范式 + 避坑（中文主）
  references/         # 全部 45+ 组件的 API 参考（中英双语，按分类分文件）
```

- `SKILL.md`：安装、主题接线、`MiuixScaffold` 心智模型、可折叠顶栏 / 底部导航 /
  设置页 / 弹层等可编译范式，以及常见坑。
- `references/NN_分类.{zh,en}.md`：每个组件的完整参数表、默认值、颜色配置。AI 需要精确
  签名时按需读取（渐进式加载，不占初始上下文）。

内容与 flutter_miuix 仓库的 `doc/.api_frag/` 单一真源同步（`npm run sync`），不会漂移。

## 提交进仓库共享

`.claude/skills/` 默认可能被 gitignore 忽略。想让团队共享这份指南，把该目录纳入版本控制即可。

---

## English

An AI coding-assistant skill (Claude Code / [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills))
for the [flutter_miuix](https://github.com/ChuxinNeko/flutter_miuix) component library (HyperOS / MIUI-style
Flutter widgets).

One command installs the guide into your Flutter project, so AI gets correct component usage, theming setup,
composition patterns, and gotchas (with bilingual API reference for 45+ components).

### Usage

Run in your Flutter project root:

```bash
npx flutter-miuix-skill
```

Installs into `.claude/skills/flutter-miuix/`. Restart your AI coding tool afterward.

```bash
npx flutter-miuix-skill --path <dir>   # target project dir (default: cwd)
npx flutter-miuix-skill --force        # overwrite existing install
npx flutter-miuix-skill --help
```

The primary guide (`SKILL.md`) is written in Chinese; the bundled `references/` include both English
(`.en.md`) and Chinese (`.zh.md`) API docs.

## License

Apache-2.0 © ChuxinNeko
