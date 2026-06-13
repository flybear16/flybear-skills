---
name: fix-issues
description: "GitHub Issue 修复闭环 — 从拉取 issue 到验证推送一条龙。触发场景：用户说「修个 issue」「处理一下 GitHub issues」「fix issues」「看看有没有 bug 要修」「拉 issues 来修」「issue #23 修一下」。覆盖 flybear16 名下所有 repo：① 拉取 open issues ② 人选一个 ③ 理解/复现 ④ TDD 修复 ⑤ 测试门禁 ⑥ commit(Fixes #N) ⑦ 推送(分支→ff 合并 master→推送，不开 PR)。人机协同：推送前必看 diff。"
version: 1.0.0
author: 飞熊 (flybear)
license: MIT
metadata:
  hermes:
    tags: [github, issues, fix, bug, tdd, ci-gate, push, flybear16]
    related_skills: [builder, ws-monitor, gtd-active]
---

# fix-issues · GitHub Issue 修复闭环

> **一句话需求 → issue 修好并推到 master,issue 自动关闭。**
> 范围:flybear16 名下所有 repo。推送:直接推(分支 → ff 合并 master),不开 PR。

## Overview

把「拉 GitHub issue → 修复 → 验证 → 推送」串成一条 SOP,**每步有硬门禁**:

```
① 拉取    ② 选择     ③ 理解      ④ 修复      ⑤ 验证       ⑥ 提交        ⑦ 推送
gh search → 人选编号 → view+复现 → TDD 改 → test/lint 全绿 → Fixes #N → ff merge master
```

**做什么**:
- 跨所有 repo 拉 open issue(可按 label 筛 `bug`/`good-first-issue`)
- 在本地 clone 里 TDD 修复
- 提交前**强制**过测试门禁
- 推送前**强制**人工过目 diff
- commit 带 `Fixes #N`,合并到 master 后 GitHub **自动关闭 issue**

**不做什么**(明确边界):
- ❌ 不直推 master 跳过验证(测试没过不提交)
- ❌ 不开 PR(个人项目,ff 合并到 master 即可)
- ❌ 不处理标了 `security` 的 issue(→ 走专门安全流程)
- ❌ 不 force push、不碰 `wontfix`/`discussion`/`duplicate` 标签的 issue

---

## 🚀 30 秒启动

```bash
# 触发方式(任一)
#   对话说「修个 issue」/「fix issues」
#   /fix-issues              # 列出所有 repo 的 open issue 让你选
#   /fix-issue 23            # 直接处理某个 repo 的 #23
#   /fix-issue 23 -R owner/repo

# agent 会自动:
#   1. 拉取 → 2. 让你选 → 3. 理解 → 4. 修 → 5. 验证 → 6. 提交 → 7. 推送
```

---

## 📦 7 步 SOP(严格按序,不跳步)

### Step 1: 拉取 issues

跨所有 repo 拉取(默认 scope = 全部 flybear16):

```bash
# 所有 repo 的 open issue(排除 PR)
gh search issues \
  --owner flybear16 \
  --state open \
  --include-prs=false \
  --limit 30 \
  --json repository,number,title,labels,createdAt \
  --jq '.[] | "\(.repository)\t#\(.number)\t\([.labels[].name]|join(","))\t\(.title)"'
```

**筛选优先级**(展示时排序):
1. 标了 `bug` 的优先
2. 标了 `good-first-issue` 的次之
3. 跳过:`wontfix` / `discussion` / `duplicate` / `security`

**只想看当前 repo**:
```bash
gh issue list --state open --limit 20
```

### Step 2: 选择(人工卡点 ①)

把上一步结果排成表格给用户:

```
repo                          #    labels         title
─────────────────────────────────────────────────────────
flybear-skills                #12  bug            ws-monitor 端口冲突未处理
flybear16/some-tool           #3   good-first...  README 拼写错误
...
```

→ 等用户输入编号(如 `12` 或 `some-tool 3`)。**不要自动选**。

### Step 3: 理解 + 复现

```bash
# 读 issue 正文 + 评论
gh issue view <N> -R <owner>/<repo> --comments
```

agent 读完后**用 3 行总结给用户确认**:
- **问题**:发生了什么
- **复现**:怎么触发(是 bug 的话)
- **预期**:正确行为应该是什么

→ 是 bug → Step 4 先写**失败测试**(RED)
→ 是功能/文档 → Step 4 写**验收标准**

### Step 4: 修复(TDD)

#### 4.1 定位/准备本地工作区

```bash
# repo 已在 ~/ws2026 下 → 直接进
cd ~/ws2026/<repo-dir> 2>/dev/null || {
  # 不在 → clone 到 ~/ws2026
  git clone git@github.com:<owner>/<repo>.git ~/ws2026/<repo>
  cd ~/ws2026/<repo>
}
git checkout master && git pull --ff-only
git checkout -b fix/issue-<N>-<slug>   # 分支名:fix/issue-12-port-conflict
```

#### 4.2 实现

- **bug**:先写复现该 bug 的测试 → 跑(RED 失败)→ 改代码 → 跑(GREEN 通过)
- **最小改动**:只改与该 issue 相关的代码,**不顺手重构无关部分**
- 遵循该 repo 自身的 `AGENTS.md` / `CLAUDE.md` 约定(如有)

### Step 5: 验证门禁(人工卡点 ② 之前,硬规则)

提交前**必须全绿**,缺一不可。先按 repo 文件探测技术栈:

| 探测文件 | 技术栈 | 验证命令 |
|---------|--------|---------|
| `pnpm-lock.yaml` | pnpm | `pnpm test && pnpm lint && pnpm type-check` |
| `package.json` | npm | `npm test && npm run lint && npm run type-check` |
| `pom.xml` | Maven | `./mvnw test` |
| `build.gradle*` | Gradle | `./gradlew test` |
| `pyproject.toml`/`requirements.txt` | Python | `pytest` |
| `go.mod` | Go | `go test ./... && go vet ./...` |
| 无测试框架 | 纯文档/配置 | 跳过测试,但必须说明 |

> **铁律**:任一门禁失败 → **回到 Step 4 修**,绝不跳过提交。
> 没有 test 脚本的 repo → 至少手动验证主流程跑通,并在 commit 里说明。

### Step 6: 提交

```bash
git add -A

# conventional commit + Fixes #N(合并到 master 时自动关 issue)
git commit -m "fix: <一句话描述> (fixes #<N>)"

# 例:
# git commit -m "fix: ws-monitor 处理端口占用冲突 (fixes #12)"
```

多行 commit(需要写背景时):
```bash
git commit -m "fix: <一句话描述> (fixes #<N>)" -m "<背景/原因/验证方式>"
```

### Step 7: 推送(人工卡点 ②,最关键)

**推送前必须给用户看完整 diff**:

```bash
git diff master --stat          # 改了哪些文件
git diff master                 # 完整 diff(给用户过目)
```

→ 用户确认「推」才继续:

```bash
# ff 合并到 master(保持线性历史)
git checkout master
git merge --ff-only fix/issue-<N>-<slug>

# 推送 master → Fixes #N 触发,GitHub 自动关闭 issue
git push origin master

# 清理本地分支(可选)
git branch -d fix/issue-<N>-<slug>
```

**如果 `--ff-only` 失败**(master 期间被别人推过):
```bash
git checkout fix/issue-<N>-<slug>
git rebase master               # 变基到最新
# 回 Step 5 重新跑验证门禁!
git checkout master && git merge --ff-only fix/issue-<N>-<slug>
git push origin master
```

---

## 🧠 决策树:用户说… → 走哪步

```
用户说...                         → 动作
─────────────────────────────────────────────────────────────
"修个 issue" / "fix issues"       → Step 1(全部 repo)
"看看有没有 bug 要修"             → Step 1(只看 bug label)
"issue #23 修一下"                → Step 3(view #23)
"#23 在 some-repo"                → Step 3(-R 指定 repo)
"只看当前 repo 的 issue"          → Step 1 用 gh issue list
"这个 issue 标了 security"        → 停,提示走安全流程
"测试没过但先推吧"                → 拒绝,回 Step 4
```

---

## 🛡️ 安全护栏(硬规则,不可违反)

| 规则 | 原因 |
|------|------|
| ❌ 不跳过验证门禁提交 | 测试没过的代码上 master 是灾难 |
| ❌ 推送前不看 diff | 防 AI 跑偏乱改、误删 |
| ❌ 不处理 `security` 标签 issue | 走专门安全流程(对应 security 规则) |
| ❌ 不 force push | 覆盖历史,不可恢复 |
| ❌ 不碰 `wontfix`/`duplicate` | 这些不该被"修" |
| ✅ `Fixes #N` 必须在 commit 里 | 推 master 自动关 issue,闭环 |
| ✅ 只改相关代码 | 最小 diff,易 review 易回退 |

---

## 🔁 与其他 skill 的协同

| 场景 | 配合 skill |
|------|-----------|
| 修完要复盘这次 issue | → `evening-journal` 的 Action 段 |
| 修复涉及大重构/新功能 | → `builder` 席位的 5 步流程 |
| 推完想确认线上状态 | → `ws-monitor` |
| issue 太多记不过来 | → `gtd-active` 排优先级 |

---

## 🔧 故障排查

### `gh search issues` 没结果?
- `gh auth status` 确认登录的是 `flybear16`(token 需 `repo` scope)
- 多账号:可能登了别的号 → `gh auth switch`

### repo 本地没有?
```bash
# 找一下
ls ~/ws2026/ | grep <repo>
# 没有 → clone(Step 4.1 已处理)
```

### `--ff-only` 合并失败?
- master 被推过新提交 → rebase 后**重跑验证门禁**(Step 5),不要直接强合

### issue 没自动关闭?
- 检查 commit 里 `Fixes #N` 的 `N` 是否正确、`#` 是否漏了
- `Fixes` 必须在**默认分支**(master)上才触发关 issue,推 feature 分支不会关
- 手动补:`gh issue close <N> -R <owner>/<repo>`

### 不确定改动是否安全?
- **停下来问用户**,不要赌
- 涉及数据库迁移/auth/支付 → 必须人工确认,不能自动推

---

## 📝 元信息

- **创建**: 2026-06-13
- **版本**: 1.0.0
- **范围**: flybear16 名下所有 repo(不限白名单)
- **推送策略**: 分支 → ff 合并 master → 推送(不开 PR)
- **核心观点**: "门禁前置 + diff 过目" — 验证和审查发生在 push 之前,不是之后
