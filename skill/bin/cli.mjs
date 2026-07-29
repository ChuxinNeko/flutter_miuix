#!/usr/bin/env node
// flutter-miuix-skill 安装器。
//
// 把 flutter_miuix 的 AI 使用指南（Claude Code / Agent skill）复制进当前项目的
// .claude/skills/flutter-miuix/，让 AI 直接获得组件库的正确用法、组合范式与避坑要点。
//
// 用法：
//   npx flutter-miuix-skill                 装到 ./.claude/skills/flutter-miuix/
//   npx flutter-miuix-skill --path <dir>    装到 <dir>/.claude/skills/flutter-miuix/
//   npx flutter-miuix-skill --force         覆盖已存在的安装
//   npx flutter-miuix-skill --help          显示帮助
//
// 零依赖：只用 Node 内置模块，兼容 Node >= 16。

import {
  cpSync,
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
} from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const SKILL_NAME = 'flutter-miuix';
// bin/ 的同级是 payload/flutter-miuix/
const payloadDir = resolve(__dirname, '..', 'payload', SKILL_NAME);

function parseArgs(argv) {
  const opts = { path: process.cwd(), force: false, help: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--help' || a === '-h') opts.help = true;
    else if (a === '--force' || a === '-f') opts.force = true;
    else if (a === '--path' || a === '-p') {
      const next = argv[++i];
      if (!next) fail('--path 需要一个目录参数');
      opts.path = resolve(next);
    } else {
      fail(`未知参数：${a}（用 --help 查看用法）`);
    }
  }
  return opts;
}

function fail(msg) {
  console.error(`\x1b[31m✗\x1b[0m ${msg}`);
  process.exit(1);
}

function printHelp() {
  console.log(`
flutter-miuix-skill —— 把 flutter_miuix 的 AI 使用指南装进你的项目

用法：
  npx flutter-miuix-skill [选项]

选项：
  -p, --path <dir>   目标项目根目录（默认：当前目录）
  -f, --force        覆盖已存在的 skill
  -h, --help         显示本帮助

安装位置：
  <项目>/.claude/skills/${SKILL_NAME}/

安装后，Claude Code 等支持 Agent Skills 的 AI 会在你用到 flutter_miuix
组件时自动加载该指南（含 45+ 组件的中英双语 API 参考）。
`);
}

function readPkgVersion() {
  try {
    const pkg = JSON.parse(readFileSync(resolve(__dirname, '..', 'package.json'), 'utf8'));
    return pkg.version || '';
  } catch {
    return '';
  }
}

function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.help) {
    printHelp();
    return;
  }

  if (!existsSync(payloadDir) || !existsSync(join(payloadDir, 'SKILL.md'))) {
    fail(`找不到 skill 载荷：${payloadDir}\n包可能安装不完整，请重新安装 flutter-miuix-skill。`);
  }

  const projectRoot = opts.path;
  if (!existsSync(projectRoot)) {
    fail(`目标目录不存在：${projectRoot}`);
  }

  const destDir = join(projectRoot, '.claude', 'skills', SKILL_NAME);

  if (existsSync(destDir)) {
    if (!opts.force) {
      fail(
        `目标已存在：${destDir}\n` +
          `如需覆盖，加 --force：npx flutter-miuix-skill --force`,
      );
    }
    rmSync(destDir, { recursive: true, force: true });
  }

  mkdirSync(dirname(destDir), { recursive: true });
  cpSync(payloadDir, destDir, { recursive: true });

  const version = readPkgVersion();
  console.log(`\x1b[32m✓\x1b[0m flutter_miuix skill${version ? ` v${version}` : ''} 已安装`);
  console.log(`  → ${destDir}`);
  console.log('');
  console.log('接下来：');
  console.log('  1. 重启 / 重新打开你的 AI 编码工具，使其加载新 skill。');
  console.log("  2. 让 AI 用 flutter_miuix 搭界面即可（如“用 Miuix 风格做个设置页”）。");
  console.log('  3. 把 .claude/skills/ 提交进仓库可让团队共享该指南。');
}

main();
