---
name: evening-journal
description: "SOP-3 晚间复盘 — 每天 5 分钟结构化反思。触发场景：用户说「今天结束了」「晚上好」「今天做了啥」「复盘」「journal」「evening」「sop-3」「收工」「晚安」「明天计划」「今天学到了」「今天卡在哪里」。按 STAR-T 框架 (Summary/Today/Action/Roadblock/Tomorrow) 5 段记录，存入 gbrain journal/YYYY-MM-DD 页面，可选写入飞书当晚报告。配套 long-term-ai-productivity-system 计划中 SOP-3 设计，与 sop-2-deep-work-protection 配合形成完整日闭环。"
version: 1.0.0
author: 飞熊 (flybear)
license: MIT
metadata:
  hermes:
    tags: [sop, productivity, reflection, journal, daily, p3-system]
    related_skills: [sop-2-deep-work-protection, gtd-active, builder]
---

# SOP-3 · Evening Journal · 晚间复盘

> **每天 5 分钟，把隐性知识外化为显性知识。**
> SOP-2 保护你的 builder 时间，SOP-3 把这段时间的成果转化为可复用的资产。

## Overview

5 段式结构化复盘（STAR-T 框架）：

1. **S**ummary — 一句话总结今天
2. **T**oday — 今天具体做了什么（3-5 件）
3. **A**ction — 学到了什么（可迁移的洞察）
4. **R**oadblock — 卡在哪里（具体的 bug/困惑/决策）
5. **T**omorrow — 明天第一件事是什么

**核心价值**：
- 🧠 把"我今天学到了 X"从短期记忆搬到长期记忆（gbrain）
- 🔍 形成可检索的"个人决策日志"（3 个月后能查"我那天为什么选 Vue 3"）
- 📊 度量 SOP-2 深度工作的实际效果（focus90 跑了几次？被打断了几次？）
- 🔁 复利效应 — 第 30 天你会看到清晰的模式

**不做什么**（明确边界）：
- ❌ 不是 GTD 任务管理（用 `gtd-active`）
- ❌ 不是项目监控（用 `ws-monitor`）
- ❌ 不是日记本/心情记录（这个是工作复盘）
- ❌ 不强制每天（每 3 天至少 1 次即可）

---

## 🚀 30 秒启动

### 手动模式

```bash
# 触发 SOP-3（直接对话说"晚间复盘"或"今天做了啥"）
journal
```

### AI 辅助模式（推荐）

对话中直接说：
- 「今天结束了，帮我 journal」
- 「复盘一下今天」
- 「sop-3」

agent 会按 STAR-T 5 段引导你回答，然后把结果存入 gbrain。

### 自动模式（可选）

```bash
# 每天 22:00 提醒（建议加上）
hermes cron create \
  --name "SOP-3 晚间复盘提醒" \
  --schedule "0 22 * * *" \
  --prompt "提醒用户执行 evening-journal，3 行内结束" \
  --deliver feishu
```

---

## 📦 STAR-T 5 段框架

### 1️⃣ Summary（一句话总结）

> "今天的主题是 ___"

- 3-5 个词
- 不需要完整句子
- 例：「sbti-tools 主页 MVP 上线」

### 2️⃣ Today（具体做了什么）

3-5 件事实，不是任务清单：
- ✅ "sbti-tools 主页接了 mock 数据，跑了 dev server 验证"
- ❌ "完成 sbti-tools 任务"（太粗）

格式建议：
```
- [主线项目] 完成了什么
- [维护项目] 推进了什么
- [个人] 学到了什么工具/方法
- [其他] 杂事
```

### 3️⃣ Action（学到了什么）

**关键问题**：这个洞察能**迁移到其他项目**吗？

- ✅ "builder skill 改用 `gbrain import --no-embed` 批量喂入，比 put 60s/次快 300 倍"
- ❌ "今天很累"（不是洞察）
- ❌ "sbti 难做"（没具体内容）

**好的 Action 模板**：
- "[具体方法/工具] 解决 [什么问题]，下次 [场景] 可以直接用"
- "[错误] 原来 [原因]，修正为 [正确做法]"

### 4️⃣ Roadblock（卡在哪里）

明确具体的卡点，方便下次 journal 跟进：
- ✅ "Next.js 16 cookies() API 在 Server Component 异步化，文档没写"
- ❌ "今天没什么卡住"（不允许逃避）

**好的 Roadblock 模板**：
- "[项目/任务] 卡的点是 [具体技术/决策]，需要 [什么帮助/资源]"
- "卡了 [时长]，原因可能是 [假设]，下次 [验证方法]"

### 5️⃣ Tomorrow（明天第一件事）

最重要的 1 件 — **不是清单，是单一行动**：
- ✅ "完成 sbti-tools 主页 SEO meta + sitemap.xml"
- ❌ "继续 sbti-tools"（模糊）

---

## 🔁 与 SOP-1 / SOP-2 的闭环

```
SOP-1 standup (5min)   ──→  SOP-2 deep (4h+)   ──→  SOP-3 journal (5min)
  今天最重要 1 件              深度执行                实际做了什么
  优先级排序                  番茄钟守护              学到什么/卡住
  ─────────────                                              │
       ↑                                                       │
       └───────────── 明天最重要 1 件 ←───────────────────────┘
```

| 时间 | SOP | 入口 | 状态 |
|------|-----|------|------|
| 09:00 | SOP-1 standup | `standup` 别名 | ✅ |
| 09-02 | SOP-2 deep | `deep` / `focus 90` | ✅ |
| 22:00 | **SOP-3 journal** | **`journal` 别名 / 对话触发** | ✅ **本 skill** |

---

## 🧠 决策树：什么时候用 evening-journal？

```
用户说...                              → 动作
─────────────────────────────────────────────────────────
"今天结束了"                           → 启动 SOP-3
"晚上好" / "收工" / "晚安"             → 启动 SOP-3
"今天做了啥" / "复盘一下"              → 启动 SOP-3
"journal" / "sop-3"                   → 启动 SOP-3
"今天学到了什么"                       → 跳到 Action 段
"我卡在哪里"                          → 跳到 Roadblock 段
"明天第一件事"                        → 跳到 Tomorrow 段
"打开 gbrain journal 列表"            → gbrain search "journal/"
```

---

## 📁 数据存储格式

### gbrain slug 规范

```
journal/2026-06-01
journal/2026-06-02
...
```

### frontmatter 标准

```yaml
---
title: 2026-06-01 journal
type: journal
date: 2026-06-01
mood: 😴 focused  # 😫 😐 🙂 😊 🤩 😴
focus_score: 7    # 1-10，SOP-2 实际效果
projects: [sbti-tools, flybear-skills]  # 当天涉及的主项目
tags: [mvp, gbrain, sop-2]
---
```

### Markdown 模板

```markdown
# 2026-06-01 · Journal

**Summary**: 1 句话总结
**Mood**: 😴 **Focus**: 7/10

## 🌅 Today
- 主线: sbti-tools 主页接 mock 数据
- 维护: 修了 ws-monitor 的端口冲突
- 工具: 发现 gbrain import --no-embed 批量喂入快 300 倍

## 💡 Action
- gbrain 批量喂入改用 import --no-embed，避免单次 put 60s 等待
- builder skill 栈选择加 "嵌入式" 维度（esp-ai 项目没用上）

## 🚧 Roadblock
- Next.js 16 cookies() 异步化没找到文档，dev server 报错先 mock 了
- 下次: 查 Next.js 16 release notes 找 breaking change

## 🎯 Tomorrow
- sbti-tools 主页 SEO meta + sitemap.xml
```

---

## 📊 度量 / 迭代

### 每周日 21:00（journal 时）做周复盘

| 维度 | 问自己 |
|------|--------|
| **连续性** | 这周 journal 了几次？(目标 ≥ 5) |
| **质量** | Action 段是否 ≥ 2 条可迁移洞察？ |
| **跟进** | 上周 Roadblock 这周解决了吗？ |
| **Focus** | 平均 focus_score？(目标 ≥ 6) |
| **Tomorrow** | 昨天说的"明天第一件"今天真做了吗？ |

### 月度反思（每月 1 号）

```bash
# 用 gbrain 查这个月所有 journal
gbrain search "journal/2026-06"
```

- 找到 **3 个最高频的 Roadblock** — 写 SOP 或工具
- 找到 **最有效的 Action** — 标准化到 builder skill
- 找到 **拖延的 Tomorrow** — 看为什么没做

---

## 🔧 集成与扩展

### 飞书日报（可选）

每天 22:00 journal 后，agent 可选把 Summary + Tomorrow 段推送到飞书：

```bash
hermes cron create \
  --name "SOP-3 飞书日报" \
  --schedule "5 22 * * *" \
  --prompt "读 gbrain journal/$(date +%Y-%m-%d) 的 Summary 和 Tomorrow 段，推送飞书，5 行内" \
  --deliver feishu
```

### weekly report（高级）

每周日 21:00，自动汇总本周所有 journal：

```bash
# 伪代码
for slug in journal/2026-06-{01..07}; do
  gbrain get $slug
done | summarize
```

### 与 builder skill 联动

`builder` 席位的"5 步流程"（PRD→设计→实现→自测→部署）每完成一步，agent 可**主动 prompt**：
> 「这个 builder 任务完成，要不要在 journal 里加一条 Action？」

---

## 🔧 故障排查

### `journal` 函数没有？
- 检查 `source ~/.bashrc.sop2`
- 见 `sop-2-deep-work-protection` skill

### gbrain 写入失败？
- `gbrain doctor` 看健康
- `gbrain put "journal/$(date +%Y-%m-%d)" --content "..."` 手动

### 每天 22:00 提醒没收到？
- `hermes cron list` 看 job 状态
- 检查飞书 gateway 连接

### 不想每天都做？
- 最低频率：每 3 天 1 次
- 关键 trigger：完成 builder 重活之后**必须** journal 1 次

---

## 📚 配套文件

| 文件 | 作用 |
|------|------|
| `~/.bashrc.sop2` | 包含 `journal` 别名（SOP-2 一部分） |
| `~/.hermes/sop-2-feishu-dnd-guide.md` | DND 22:00 后的飞书策略 |
| `~/ws2026/PROJECTS.md` | Today 段要选主线优先 |
| `~/ws2026/.hermes/plans/2026-06-01_220000-long-term-ai-productivity-system.md` | 总设计文档 |

---

## 📝 元信息

- **创建**: 2026-06-01
- **版本**: 1.0.0
- **配套**: sop-2-deep-work-protection (SOP-2)
- **核心观点**: "复利效应" — 第 30 天的你会感谢第 1 天的你
- **灵感**: David Allen GTD 周回顾 + 工程师的 "decision log"
