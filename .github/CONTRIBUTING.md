# 贡献指南 · flybear-skills

感谢你为 `flybear-skills` 贡献技能！本指南说明如何新增 / 改进一个 skill。

---

## 📁 单个 skill 的结构

每个 skill 是仓库根目录下的一个文件夹，必须包含两个文件：

```
<skill-name>/
├── SKILL.md        # 主体：触发场景 + 执行 SOP（必需）
└── _meta.json      # 元数据：ownerId/slug/version/...（必需）
```

可选：脚本、模板、示例文件等。

---

## 1️⃣ `SKILL.md` 规范

### Frontmatter（必需）

```yaml
---
name: <skill-name>            # kebab-case，与文件夹名一致
description: "<触发场景 + 用途>"   # 一句话，含「用户说 X 时做 Y」
version: 1.0.0
author: <你的名字>
license: MIT
metadata:
  hermes:
    tags: [tag1, tag2]              # 便于检索
    related_skills: [skill-a, skill-b]   # 关联的其他 skill
---
```

> **description 是关键**：要写清楚「用户说什么话时触发」+ 「这个 skill 干什么」。
> 例：`触发场景：用户说「修个 issue」「fix issues」。覆盖…① 拉 issue ② 修复 …`

### 主体结构（建议章节）

参考现有 skill（如 `fix-issues/`、`builder/`）的写法：

1. **标题 + 一句话定位** — `> blockquote` 说明这个 skill 一句话能干什么
2. **Overview** — 做什么 / 不做什么（明确边界）
3. **When to Use / 触发场景** — 用户说什么话触发
4. **30 秒启动** — 最快入口
5. **SOP 步骤** — 每步写清楚命令、坑点、验证
6. **决策树** — `用户说 X → 走哪步` 的表格
7. **安全护栏 / 硬规则** — 不能违反的约束
8. **故障排查** — 常见错误 + 修复
9. **元信息** — 创建日期 / 版本 / 配套

### 写作原则

- **场景驱动**：不是「我能做什么」，而是「用户说什么话时我做这个」
- **SOP 化**：每步命令可直接复制执行，坑点 / 验证写清楚
- **可独立运行**：不强依赖其他 skill
- **最小改动**：修 issue 时只改相关代码，不顺手重构

---

## 2️⃣ `_meta.json` 规范

```json
{
  "ownerId": "flybear16",
  "version": "1.0.0",
  "slug": "<skill-name>",
  "publishedAt": 1780000000000
}
```

| 字段 | 说明 |
|------|------|
| `ownerId` | GitHub 用户名 |
| `version` | 语义化版本 |
| `slug` | 与文件夹名 / frontmatter `name` 一致 |
| `publishedAt` | Unix 毫秒时间戳，用 `date +%s%3N` 生成 |

---

## 🚀 新 skill 贡献流程（5 步）

1. **Fork** 本仓库
2. **建目录**：根目录下新建 `<skill-name>/`（kebab-case）
3. **写文件**：`SKILL.md`（含 frontmatter）+ `_meta.json`
4. **自检**：
   - [ ] 文件夹名 = frontmatter `name` = `_meta.json` `slug`/`name` 三处一致
   - [ ] `_meta.json` 是合法 JSON（`python3 -c "import json; json.load(open('<skill>/_meta.json'))"`）
   - [ ] frontmatter YAML 合法
   - [ ] README.md 技能列表表格已加行 + badge 数字已更新
5. **提 PR**：commit 用 conventional commits（`feat: add xxx skill`），CI 会跑格式检查

---

## 🔍 复用 / 移植现有 skill

标 `public`（MIT）的 skill 可直接 fork / port。保留版权声明即可。

---

## 🧪 验证门禁（提交前必过）

| 检查项 | 命令 |
|--------|------|
| JSON 合法 | `python3 -c "import json; json.load(open('<skill>/_meta.json'))"` |
| 三处命名一致 | 文件夹名 / frontmatter name / _meta slug |
| README 已同步 | badge 数字 + 表格行 |
| 无硬编码密钥 | `git diff` 过目 |

> 纯文档 / skill 类改动没有单元测试；功能性改动（脚本等）需自带测试并本地跑通。

---

## 📜 许可证

贡献内容遵循仓库的 **MIT** 协议。提交即表示同意以 MIT 发布。

---

## ❓ 有问题？

- 开 [GitHub Issue](https://github.com/flybear16/flybear-skills/issues) 讨论
- 或直接提 Draft PR 草案讨论方向
