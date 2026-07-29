#!/usr/bin/env node
// 从组件库的单一真源 doc/.api_frag/ 重新生成 skill 自带的 API 参考副本。
//
// 为什么需要这一步：下游用户通过 npx 安装 skill 时拿不到本仓库，SKILL.md
// 引用的参考文档必须打进包里（自包含）。但 doc/.api_frag/ 才是唯一真源，
// 手动复制迟早漂移——所以改完 API 文档后跑一次本脚本，把片段拷进
// payload/flutter-miuix/references/，保证副本与真源逐字节一致。
//
// 用法（在 skill/ 目录或仓库根目录均可）：
//   node skill/scripts/sync-references.mjs
//   node skill/scripts/sync-references.mjs --check   # 只校验是否同步，不写入（CI 用）

import { readdirSync, readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
// skill/scripts → 仓库根 → doc/.api_frag
const repoRoot = resolve(__dirname, '..', '..');
const srcDir = join(repoRoot, 'doc', '.api_frag');
const destDir = resolve(__dirname, '..', 'payload', 'flutter-miuix', 'references');

const checkOnly = process.argv.includes('--check');

if (!existsSync(srcDir)) {
  console.error(`[sync-references] 找不到真源目录：${srcDir}`);
  console.error('本脚本必须在 flutter_miuix 仓库内运行（doc/.api_frag 是唯一真源）。');
  process.exit(1);
}

mkdirSync(destDir, { recursive: true });

// 只同步 .en.md / .zh.md 片段（跳过任何临时文件）。
const fragments = readdirSync(srcDir).filter((f) => /\.(en|zh)\.md$/.test(f)).sort();

if (fragments.length === 0) {
  console.error(`[sync-references] 真源目录里没有 *.{en,zh}.md 片段：${srcDir}`);
  process.exit(1);
}

let drifted = 0;
let copied = 0;

for (const name of fragments) {
  const srcContent = readFileSync(join(srcDir, name), 'utf8');
  const destPath = join(destDir, name);
  const existing = existsSync(destPath) ? readFileSync(destPath, 'utf8') : null;

  if (existing === srcContent) continue;

  if (checkOnly) {
    console.error(`[sync-references] 漂移：${name} 与真源不一致`);
    drifted++;
    continue;
  }

  writeFileSync(destPath, srcContent);
  copied++;
}

if (checkOnly) {
  if (drifted > 0) {
    console.error(`\n[sync-references] ${drifted} 个副本已漂移，请运行 node skill/scripts/sync-references.mjs`);
    process.exit(1);
  }
  console.log(`[sync-references] 全部 ${fragments.length} 个参考副本与真源一致 ✔`);
  process.exit(0);
}

console.log(
  `[sync-references] 已同步 ${fragments.length} 个片段（更新 ${copied}，未变 ${fragments.length - copied}）→ payload/flutter-miuix/references/`,
);
