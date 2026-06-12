---
name: sop-2-deep-work-protection
description: "深度工作保护机制 (SOP-2) — 守护 3-5-2 矩阵中 80% builder 时间。触发场景：用户说「我要专注」「准备写代码」「进入深度模式」「今天有重活」「关掉飞书通知」「DND」「番茄钟」「focus」「25min」「90min」「1.5 小时」等。在 bash aliases、飞书 DND、hermes cron 三层建立护栏：① 一键 focus25/45/90 启动番茄钟 ② deep/unlock 切换深度模式 ③ 飞书 3 段 DND 计划 (09-12/14-18/21-02) ④ 工作日 9:00 自动提醒启动深度块。配套 long-term-ai-productivity-system 计划中 SOP-2 设计。"
version: 1.0.0
author: 飞熊 (flybear)
license: MIT
metadata:
  hermes:
    tags: [sop, productivity, focus, deep-work, dnd, pomodoro, p0-protection]
    related_skills: [builder, gtd-active, ws-monitor]
---

# SOP-2 · 深度工作保护

> 你的 3-5-2 矩阵（3 主线 / 5 维护 / 2 实验）要 work，**80% 时间必须是无打断的 builder 时间**。
> SOP-2 是这套护栏的入口。

## Overview

凌晨工作者 + 多项目并行 + 飞书消息打扰 = 严重的上下文切换成本。
SOP-2 在**三个层面**建立保护：

1. **bash aliases**（最快响应）— `focus90` / `deep` / `unlock` / `standup` / `journal`
2. **飞书 DND 计划**（消息源头切断）— 3 段静音 + 紧急白名单
3. **hermes cron**（外部提醒）— 工作日 9:00 启动提醒

**不做什么**（明确边界）：
- ❌ 不强制开/关飞书（DND 由用户手动配）
- ❌ 不替代 SOP-1（晨间计划）和 SOP-3（晚间复盘）
- ❌ 不做项目级保护（项目级用 `builder` 席位）

---

## 🚀 30 秒启动

```bash
# 一次性安装（首次）
echo 'source ~/.bashrc.sop2' >> ~/.bashrc
source ~/.bashrc.sop2

# 配置飞书 DND（手动，5分钟一次永久生效）
# 详见 ~/.hermes/sop-2-feishu-dnd-guide.md
```

---

## 📦 三大组件

### 1️⃣ bash aliases (`~/.bashrc.sop2`)

安装：`source ~/.bashrc.sop2`

| 命令 | 作用 | 触发场景 |
|------|------|----------|
| `focus90` / `focus45` / `focus25` | 启动 N 分钟番茄钟 | 「我准备写 1.5 小时代码」 |
| `deep` | 切到深度模式 + `cd ~/ws2026` | 「开始工作」 |
| `unlock` | 解除深度模式 | 「先到这」 |
| `standup` | SOP-1 晨间计划 | 每天开工前 |
| `journal` | SOP-3 晚间复盘 | 每天收工前 |
| `ws` | 列出活跃项目（3-5-2） | 选项目时 |
| `gbed` / `gq` / `gs` | gbrain embed/query/search 快捷 | 喂入/检索 |
| `focus <min>` | 自定义时长的番茄 | 「专注 50 分钟」 |

**深度模式行为**（执行 `deep` 后）：
- ✅ `cd ~/ws2026`（核心项目目录）
- ✅ 提示飞书 DND 计划已激活
- ✅ 提示 gbrain 待办查询
- ❌ 不自动静音（依赖飞书 DND）

**解除**：`unlock` 提示恢复异步接收 + 建议执行 `journal`。

### 2️⃣ 飞书 DND 计划 (`~/.hermes/sop-2-feishu-dnd-guide.md`)

| 时段 | 名称 | 原因 |
|------|------|------|
| 09:00-12:00 | 上午深度 | 最清醒的 3 小时 |
| 14:00-18:00 | 下午深度 | writer 席位（文档/复盘） |
| 21:00-02:00 | 夜间/凌晨 | **你最关键的时段** |

**白名单**（穿透 DND）：
- 你自己 (east)
- `P0-critical` 群
- Keyword：`紧急` / `救命` / `hotfix` / `卡住`

**预期效果**：每天 9 小时无打扰理论值，扣除会议/休息 ≈ **5h/天 纯 builder 时间**。
**对比**：之前每天 5 个番茄 (25min × 5 = 2h) → 现在 8-10 个 (4h+)。

### 3️⃣ hermes cron

| 任务 ID | 名称 | 频率 | 作用 |
|---------|------|------|------|
| `a3f1a6fb40ac` | SOP-2 晨间深度启动提醒 | 工作日 9:00 | 飞书消息提醒启动深度块 |
| `f8218276200b` | 死链检测 | 周日 2:00 | 维护类（已有） |

**晨间提醒内容**（简短 3 行内）：
1. 今天最重要的 builder 任务（从 `~/ws2026/PROJECTS.md` 选）
2. 提示用 `deep` 别名启动
3. 「接下来 90 分钟不打断」

---

## 🧠 决策树：什么时候用 SOP-2？

```
用户说...                              → 用 SOP-2 的哪部分？
─────────────────────────────────────────────────────────
"我要写 1.5 小时代码"                  → focus90
"开始工作了"                           → deep
"我准备做 builder 任务 X"             → deep + focus90
"今天有重活"                          → deep + focus90
"25 分钟番茄"                         → focus25
"到这吧"                              → unlock + journal
"开早会"                              → standup
"今晚做了啥"                          → journal
"我要专注 1 小时"                      → focus (动态时长)
```

---

## 🔁 与其他 SOP 的关系

```
SOP-1 (standup)  ──→  SOP-2 (deep)  ──→  SOP-3 (journal)
  5min 计划            80% 时间           5min 复盘
  每天开工前           每天中间           每天收工
```

| SOP | 入口 | 状态 |
|-----|------|------|
| SOP-1 standup | `standup` 别名 | ✅ 文档中 |
| **SOP-2 deep** | **`focus90` / `deep`** | ✅ **本 skill** |
| SOP-3 journal | `journal` 别名 | ⏳ 待 `evening-journal` skill |

---

## 📊 度量 / 迭代

每周日 21:00（journal 时）问自己：
- 这周 DND 期间被穿透了几次？
- 哪些穿透是真正紧急？哪些"我以为紧急"？
- focus90 完整跑完了几次？被打断了几次？
- 调整白名单 + 调整时段

**目标 KPI**：
- 每周 focus90 完整跑完 ≥ 8 次
- 每周深度时间 ≥ 30h
- 每周 standup/journal 完成率 ≥ 80%

---

## 🔧 故障排查

### `focus90` 没声音通知？
- 检查 `notify-send` 是否安装：`which notify-send`
- GNOME: `sudo apt install libnotify-bin`
- macOS: `brew install terminal-notifier`

### `deep` 切到 `~/ws2026` 失败？
- 路径不存在：用 `ws` 别名查看实际位置
- 没权限：检查 `~/ws2026` 所有权

### cron 没在 9:00 推送？
- `hermes cron list` 查 job 状态
- `hermes cron pause/resume` 切换
- 检查 `~/.hermes/logs/cron.log`

### gbrain 快捷 (`gq` / `gs`) 报错？
- `which gbrain` 确认安装
- `gbrain doctor` 看健康状态
- 检查 `OPENAI_API_KEY` 和 `OPENAI_BASE_URL`（见 `gbrain` skill）

---

## 📚 配套文件

| 文件 | 作用 |
|------|------|
| `~/.bashrc.sop2` | bash aliases 源文件 |
| `~/.hermes/sop-2-feishu-dnd-guide.md` | 飞书 DND 配置指南 |
| `~/ws2026/PROJECTS.md` | 3-5-2 项目分类（deep 模式优先选主线） |
| `~/ws2026/.hermes/plans/2026-06-01_220000-long-term-ai-productivity-system.md` | 总设计文档 |

---

## 📝 元信息

- **创建**: 2026-06-01
- **版本**: 1.0.0
- **配套计划**: long-term-ai-productivity-system
- **核心观点**: "工具不增项目反哺工具" — SOP-2 就是 3-5-2 矩阵的护栏
