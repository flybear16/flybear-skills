# 🛠️ flybear-skills — 阿拉蕾的公有技能库

> **开源共享的 AI 助手技能集合**（Hermes / OpenClaw 兼容），欢迎使用、Star、Fork！

[![Skills: 7](https://img.shields.io/badge/skills-7-blue)]()
[![License: MIT](https://img.shields.io/badge/license-MIT-green)]()
[![Open Source](https://img.shields.io/badge/open_source-%E2%9D%A4-red)]()

仓库地址：[github.com/flybear16/flybear-skills](https://github.com/flybear16/flybear-skills)

---

## ✨ 这是什么？

**flybear-skills** 是 `flybear16`（阿拉蕾）公开发布的 **AI Agent Skills 仓库**。
每个 skill 是一个独立的 SKILL.md 文件，定义了一组**触发场景 + 执行 SOP**，可被 Hermes Agent / OpenClaw / Claude Code 等多 agent 平台直接加载。

设计原则：
- **场景驱动**：不是「我能做什么」，而是「**用户说什么话时我做这个**」
- **SOP 化**：每步命令、坑点、验证都写清楚
- **可独立运行**：每个 skill 自包含，不强依赖其他 skill
- **可商用**：MIT 协议，标 `public` 的都能拿去用

> 私有 / 实验中 skills 放在姊妹仓库 [`myskills`](https://github.com/flybear16/myskills)（私有）。

---

## 📦 技能列表（7 个）

| Skill | 触发场景 | 用途 |
|-------|---------|------|
| [**gtd-active**](./gtd-active/) | 用户说「记一下」「加个 todo」「GTD」 | GTD 任务管理 —— 输入自动归类到收件箱/项目/下一步/等待/将来/参考 |
| [**ws-monitor**](./ws-monitor/) | 用户说 `/ws` 「看下项目状态」 | 监控 `~/ws2026` 所有项目的运行状态（端口/进程/Git/数据库）|
| [**mvp-bootstrap**](./mvp-bootstrap/) | 用户说「做个 X」「新建项目」「快速上线」 | MVP 快速启动模板 —— Next.js + Tailwind + Supabase 一键脚手架 |
| [**builder**](./builder/) | 用户说「从一句话需求到 MVP 上线」 | AI Builder 席位 —— 端到端把想法变成可发布产品 |
| [**evening-journal**](./evening-journal/) | 用户说「今天结束了」「晚上好」 | SOP-3 晚间复盘 —— 每天 5 分钟结构化反思 |
| [**sop-2-deep-work-protection**](./sop-2-deep-work-protection/) | — | 深度工作保护机制 (SOP-2) —— 守护 3-5-2 矩阵中 80% builder 时间 |
| [**ai-news-collectors**](./ai-news-collectors/) | 用户问「今天有什么 AI 新闻？」 | AI 新闻聚合 + 热度排序 |

> 标 `public` 的可直接复用，标 `private` 的请先联系作者。

---

## 🚀 使用方式

### 在 Hermes Agent / OpenClaw 中加载

将本仓库克隆到本地 skills 目录：

```bash
# 默认 skills 目录
git clone https://github.com/flybear16/flybear-skills.git \
  ~/.hermes/skills/flybear-skills
```

或在 `config.yaml` 中添加 skills 来源：

```yaml
skills:
  sources:
    - github:flybear16/flybear-skills
```

### 在 Claude Code / OpenCode 中使用

```bash
# 通过 openskills CLI 加载单个 skill
npx openskills read flybear-skills/gtd-active

# 或一次性加载多个
npx openskills read flybear-skills/gtd-active,flybear-skills/ws-monitor
```

### 单个 skill 内

每个 skill 目录下都有 `SKILL.md`，按其中的步骤说明直接调用即可。多数 skill **无外部依赖**（只调用本机命令），少数会需要 `gh` / `vercel` CLI。

---

## 🤝 贡献指南

欢迎 PR 新 skill 或改进现有 skill。

**新 skill 流程**：
1. Fork 本仓库
2. 在根目录新建 `<skill-name>/` 文件夹
3. 写 `SKILL.md`，包含 frontmatter：
   ```yaml
   ---
   name: <skill-name>
   description: <触发场景 + 用途>
   ---
   ```
4. 写主体内容：触发条件、步骤、命令、坑点、验证
5. 提交 PR，CI 会跑格式检查

详细规范见 [`.github/CONTRIBUTING.md`](./.github/CONTRIBUTING.md)。

---

## 📜 许可证

**MIT** —— 标 `public` 的 skill 可自由使用、修改、商用，**保留版权声明即可**。

私有 skill（[myskills](https://github.com/flybear16/myskills) 仓库内）不在本仓库公开。

---

## ⭐ Star History

如果这些 skills 对你有帮助，欢迎点 ⭐ 鼓励作者持续更新！

---

## 📮 联系

- GitHub Issues：报告 bug / 提需求
- 飞书 / 微信：见作者主页
- 邮件：见 GitHub Profile
