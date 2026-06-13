---
name: find-issues
description: "代码体检 → 提 GitHub issue。触发场景：用户说「扫一下代码」「找找隐藏问题」「体检」「audit」「挖 bug」「给代码挑刺」「找死链/不一致/坏味道」「提 issue 到 github」。多 agent 编排：① N 个 finder 按维度并行扫(bug/安全/死链/不一致/性能/可维护性) ② 每个发现对抗式验证(杀假阳性) ③ 去重 + 查重已有 issue ④ 写成规范 issue 草稿(带 file:line 证据 + 复现) ⑤ 人工勾选 → gh issue create。证据驱动,空泛发现一律丢弃。与 fix-issues 互补形成 find→fix 闭环。"
version: 1.0.0
author: 飞熊 (flybear)
license: MIT
metadata:
  hermes:
    tags: [audit, code-review, bug-hunt, issues, multi-agent, adversarial-verify, dead-link]
    related_skills: [fix-issues, builder, ws-monitor]
---

# find-issues · 代码体检 → 提 GitHub Issue

> **主动扫代码找隐藏问题,验证为真后提成 GitHub issue。**
> 与 `fix-issues` 配对:`find-issues` 造 issue,`fix-issues` 修 issue。

## Overview

不是被动等用户报 issue,而是**主动挖**。多 agent 编排,核心杀招是**对抗验证**:

```
① 找(多维度并行) → ② 对抗验证(杀假阳性) → ③ 去重+查重 → ④ 写 issue 草稿 → ⑤ [人工选] 提交
```

**做什么**:
- 跨维度并行扫代码(bug/安全/死链/不一致/性能/可维护性)
- 每个发现派 skeptic **对抗式反驳**,只有扛住的才保留
- 查重已有 issue(不重复提)
- 写成带 `file:line` 证据 + 复现路径的规范 issue
- 你勾选后逐个 `gh issue create`

**不做什么**(明确边界):
- ❌ 不提**未经对抗验证**的发现(假阳性是最大风险)
- ❌ 不提**空泛**发现(「这里可以优化」一律丢)
- ❌ 不重复提已有 issue(先 `gh issue list --state all`)
- ❌ 不把安全漏洞细节写进公开 issue(脱敏或走私有流程)
- ❌ 不自动提交(提 issue 前必须人工勾选)

---

## 🚀 30 秒启动

```bash
# 触发方式(任一)
#   对话说「扫一下代码」/「体检」「audit」「挖 bug」
#   /find-issues                    # 扫当前 repo
#   /find-issues ~/ws2026/xxx       # 扫指定目录
#   /find-issues --dim bug,security # 只扫指定维度

# agent 会自动:
#   1. 多维度并行扫  2. 对抗验证  3. 去重查重  4. 给清单让你选  5. 提你选的
```

---

## 📦 5 阶段 SOP(严格按序)

### Stage 1: 找(Fan-out 多维度并行)

启动 **N 个 finder**,每个只看一个维度(避免单一视角盲区)。默认 6 维:

| 维度 | finder 找什么 |
|------|--------------|
| **bug** | 逻辑错误、边界条件、空指针、off-by-one、错误传播缺失、状态管理 bug |
| **security** | 硬编码密钥、注入、未校验输入、auth/authz 缺失、SSRF、不安全 crypto |
| **dead-link** | README/文档里的死链、引用不存在的文件、import 不存在的模块 |
| **inconsistency** | 命名漂移、配置前后矛盾、接口与实现不符、文档与代码不符 |
| **performance** | N+1 查询、循环内 IO、重复计算、无界增长、缺索引 |
| **maintainability** | 死代码、重复代码、深嵌套、巨型函数、缺失错误处理 |

**执行方式**(三选一,按场景):
- **Claude Code Workflow 工具** → `parallel()` fan-out(推荐,确定性)
- **并行 Agent 调用** → 单条消息里多个 `Agent` tool call
- **单 agent 串行** → 小 repo 降级用,逐维度扫

每个 finder 返回**结构化发现**:
```json
{
  "dimension": "bug",
  "title": "ws-monitor 未处理端口占用导致误报",
  "file": "ws-monitor/SKILL.md",
  "line": 42,
  "severity": "medium",          // critical/high/medium/low
  "evidence": "<实际代码片段>",
  "why": "<为什么是问题>",
  "repro": "<怎么触发/复现>",
  "suggested_fix": "<建议修法>"
}
```

### Stage 2: 对抗验证(杀假阳性)—— 🔑 核心

**找隐藏问题最大的风险是假阳性**:AI 特别爱编造「看起来像问题但实际不是」的发现。每个 finding **必须**派 1 个 skeptic agent **试图反驳**:

```
Finder 说: 「这里有空 catch,会吞错误」
   ↓
Skeptic 审判:
  - 看上下文:这个 catch 后面有没有 log / 重新抛出?
  - 看 git blame:是不是有意为之?
  - 看调用方:这个错误真的需要处理吗?
   ↓
扛住反驳 → 保留(isReal: true)
扛不住 → 丢弃(isReal: false)
```

**skeptic 默认怀疑**:不确定就标 `isReal: false`(宁缺毋滥)。
**高危发现**(critical/security):派 **2 个** skeptic,多数通过才保留。

### Stage 3: 去重 + 查重

1. **跨维度去重** — 多个 finder 发现同一问题(如 dead-link 和 inconsistency 都报同一个文件)→ 合并成一条
2. **查重已有 issue** — 提交前查:
   ```bash
   gh issue list -R <owner>/<repo> --state all --search "<关键词>" --limit 10
   ```
   已有 open/closed issue 覆盖同一问题 → 跳过(或建议 reopen)

### Stage 4: 写 issue 草稿

每个确认的 finding 写成规范 issue body:

```markdown
## 问题
<一句话>

## 位置
`<file>:<line>`
\`\`\`
<实际代码片段>
\`\`\`

## 为什么是问题
<why + 严重度依据>

## 复现
<步骤 / 触发条件>

## 建议修法
<suggested_fix>

## 来源
代码体检(find-issues skill,<维度>维度)
```

### Stage 5: 提交(人工卡点)

**不自动提**。先把确认的 issue 排成清单给你:

```
[#] sev   维度        title                                        位置
──────────────────────────────────────────────────────────────────────
 1  high  bug         ws-monitor 端口占用误报                      ws-monitor/SKILL.md:42
 2  med   dead-link   README 引用不存在的 CONTRIBUTING.md           README.md:98
 3  low   maintain    builder skill 有死代码段                     builder/SKILL.md:200
```

→ 你勾选(如 `1,2`)→ 逐个 `gh issue create`:

```bash
gh issue create -R <owner>/<repo> \
  --title "<title>" \
  --body "<issue body>" \
  --label "<bug/doc/...>"   # 按维度自动打 label
```

→ 提完回报每个 issue 的 URL。

---

## 🧠 决策树:用户说… → 扫哪个维度

```
用户说...                        → 维度 / 动作
───────────────────────────────────────────────────────────────
"扫一下代码" / "体检"             → 全部 6 维
"找 bug"                         → bug
"查安全问题" / "audit security"  → security(脱敏)
"找死链"                         → dead-link
"代码质量" / "可维护性"          → maintainability + inconsistency
"性能问题"                       → performance
"只扫 X 目录"                    → --path 限定
"扫完直接提"                     → ⚠️ 仍需 Stage 5 人工勾选(可降级为"自动提 low sev")
```

---

## 🛡️ 安全护栏(硬规则,不可违反)

| 规则 | 原因 |
|------|------|
| ❌ 不提未经对抗验证的发现 | 假阳性污染 issue 列表 |
| ❌ 不提空泛发现(无 file:line / 无证据) | 不可复现 = 没价值 |
| ❌ 不重复提已有 issue | 先查重 |
| ❌ 安全漏洞细节不进公开 issue | 走私有 / 脱敏 |
| ❌ 不自动提(critical/high 必须人工勾选) | outward-facing 不可逆 |
| ✅ 每个 finding 必带 file:line + 证据 + 复现 | 可验证 |
| ✅ skeptic 默认怀疑,不确定即丢 | 宁缺毋滥 |

---

## 🔁 与 fix-issues 的闭环

```
find-issues(本 skill)              fix-issues
   扫代码 → 对抗验证 → 提 issue  ──→  拉 issue → 修 → 验证 → 推
        ↑________________________反馈_______________________|
   (fix 完可在 evening-journal 记录这次找+修的模式)
```

| 场景 | 配合 skill |
|------|-----------|
| 找到 issue 后想修 | → `fix-issues` |
| 扫的是大型新功能代码 | → 先 `builder` 建好再扫 |
| 扫完想确认线上状态 | → `ws-monitor` |

---

## ⚙️ 多 agent 编排参考(Workflow 脚本骨架)

供 Claude Code 用 Workflow 工具执行时参考:

```js
export const meta = {
  name: 'find-issues',
  description: 'Scan codebase for hidden problems, adversarially verify, file GitHub issues',
  phases: [
    { title: 'Scan',   detail: 'fan out finders by dimension' },
    { title: 'Verify', detail: 'adversarially refute each finding' },
    { title: 'Dedup',  detail: 'merge overlaps + check existing issues' },
  ],
}

const DIMENSIONS = [
  { key: 'bug',            prompt: '/* 找逻辑错误/边界/错误传播 bug */' },
  { key: 'security',       prompt: '/* 找密钥/注入/未校验输入 */' },
  { key: 'dead-link',      prompt: '/* 找死链/引用不存在的文件 */' },
  { key: 'inconsistency',  prompt: '/* 找命名漂移/配置矛盾 */' },
  { key: 'performance',    prompt: '/* 找 N+1/循环 IO/无界增长 */' },
  { key: 'maintainability',prompt: '/* 找死代码/重复/巨型函数 */' },
]

const FINDINGS = {
  type: 'object',
  properties: { findings: { type: 'array', items: {
    type: 'object',
    properties: {
      dimension: { type: 'string' },
      title: { type: 'string' },
      file: { type: 'string' }, line: { type: 'number' },
      severity: { type: 'string' },
      evidence: { type: 'string' },
      why: { type: 'string' },
      repro: { type: 'string' },
      suggested_fix: { type: 'string' },
    }, required: ['title','file','line','severity','why'],
  }}},
}

const VERDICT = {
  type: 'object',
  properties: {
    isReal: { type: 'boolean' },
    reasoning: { type: 'string' },
    confidence: { type: 'string' },  // high/medium/low
  }, required: ['isReal','reasoning'],
}

// Stage 1: fan out finders
phase('Scan')
const scans = await parallel(DIMENSIONS.map(d => () =>
  agent(d.prompt, { label: `find:${d.key}`, phase: 'Scan', schema: FINDINGS })))
const findings = scans.filter(Boolean).flatMap(r => r.findings)

// Stage 2: adversarial verify each (high sev → 2 skeptics)
phase('Verify')
const judged = await parallel(findings.map(f => () => {
  const skeptics = f.severity === 'critical' || f.severity === 'high' ? 2 : 1
  return parallel(Array.from({length: skeptics}, () => () =>
    agent(`Adversarially REFUTE this finding. Default to isReal=false if uncertain. Finding: ${JSON.stringify(f)}`,
      { phase: 'Verify', schema: VERDICT })))
    .then(vs => ({ f, real: vs.filter(Boolean).filter(v => v.isReal).length >= Math.ceil(skeptics/2) }))
}))
const confirmed = judged.filter(Boolean).filter(j => j.real).map(j => j.f)

// Stage 3 + 4 + 5 由主循环处理:去重 → 查重 gh issue list → 写草稿 → 人工勾选 → gh issue create
return { confirmed, totalFound: findings.length, dropped: findings.length - confirmed.length }
```

---

## 🔧 故障排查

### 假阳性太多?
- skeptic prompt 加严:「默认 isReal=false,只有铁证才 true」
- high sev 用 2 个 skeptic
- 降低 finder 的「想象力」,要求每个发现必须带 file:line + 复现

### 漏报严重?
- 增加维度(如加 `accessibility` / `i18n` / `error-message`)
- 每个 dimension 拆成更细的子 finder
- repo 大时按目录分片扫

### `gh issue create` 报权限错?
- `gh auth status` 确认登录 flybear16 + 有 `repo` scope
- 跨 repo 时用 `-R <owner>/<repo>` 指定

### 重复提了已有 issue?
- Stage 3 查重要用 `--state all`(含 closed),关键词用 finding 的核心名词
- 命中已 closed 的 → 可选 reopen 而非新建

### repo 太大扫不动?
- `--path` 限定子目录
- 先跳过 `node_modules/`、`.git/`、`dist/`、`vendor/`
- 分批扫

---

## 📝 元信息

- **创建**: 2026-06-14
- **版本**: 1.0.0
- **配套**: `fix-issues`(修 issue),形成 find→fix 闭环
- **核心观点**: "对抗验证前置" — 假阳性在提 issue 前被杀掉,不是提了再删
- **灵感**: 静态分析(linter)的多规则思想 + AI 的对抗式自检
