---
name: changelog
description: |
  当 agent 完成代码编写和 git commit 后，自动生成符合 Keep-a-Changelog 规范的 CHANGELOG.md。
  触发条件：
  - agent 说"代码写完了"、"commit 了"、"发布了"
  - agent 在做 code review / release 前的收尾工作
  - 用户提到"生成 changelog"、"更新日志"、"release notes"、"变更记录"
  - agent 需要为刚完成的改动写更新说明
  - 任何涉及 git commit 历史需要整理成文档的场景
  注意：需要传入 repo 路径（绝对路径）或在有 git 仓库的目录下运行。
---

# Changelog Skill

> `git log` → Keep-a-Changelog 格式的 CHANGELOG.md

## 功能

当 agent 完成代码编写后，自动扫描 git 提交历史，生成结构化的更新日志。

## 使用方式

```
git log → changelog-gen → CHANGELOG.md
```

## 输入参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `repo` | 仓库路径（绝对路径） | `/home/user/my-project` |
| `since` | 最近 N 条 commit | `HEAD~10` |
| `from` | 起始 tag | `v1.0.0` |
| `to` | 结束 tag | `v1.2.0` |
| `use_ai` | 是否用 LLM 润色（可选） | `true`/`false` |

## 典型调用场景

**场景 1：agent 刚写完功能代码**
```
用户：功能写完了，帮我生成 changelog
→ agent 调用 skill，传入 repo 路径
→ 输出 CHANGELOG.md 内容
```

**场景 2：agent 准备发 release**
```
agent 判断：代码已经完成，需要生成 release notes
→ agent 自主调用 skill
→ 输出符合 Keep-a-Changelog 规范的 changelog
```

**场景 3：agent 写完代码后的收尾**
```
agent 在代码任务收尾阶段
→ 自动扫描最近 commit
→ 生成结构化 changelog
→ agent 将 changelog 写入文件
```

## 依赖

纯 Python，无外部依赖。运行前确认目标目录是 git 仓库。

## 输出

生成符合 [Keep a Changelog](https://keepachangelog.com/zh-CN/) 规范的 Markdown 文件，内容包含：
- 新增功能（✨）
- 修复问题（🐛）
- 性能优化（⚡）
- 文档更新（📝）
- 重构（♻️）
- 变更记录（其他）

## 示例输出

```markdown
## [未发布] · 2026-06-24

### ✨ 新增
- feat: changelog 生成 skill 完成
- feat: 支持按 tag 范围生成

### 🐛 修复
- fix: 分类逻辑对 refactor 的误判

### 📝 文档
- docs: 更新 README
```
