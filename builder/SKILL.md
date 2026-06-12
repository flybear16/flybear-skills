---
name: builder
description: "AI Builder 席位 — 从一句话需求到 MVP 上线。触发场景：用户说「做一个 X」「新建项目」「开发 Y 功能」「修这个 bug」「给项目加 Z」。在 Next.js/Vue 3/FastAPI/Spring Boot 四个栈中自动选型，按 5 步流程（PRD→设计→实现→自测→部署）执行，输出可运行代码 + 部署链接。"
version: 1.0.0
author: 飞熊 (flybear)
license: MIT
metadata:
  hermes:
    tags: [builder, mvp, fullstack, nextjs, vue, fastapi, spring-boot, deployment]
    related_skills: [mvp-bootstrap, ws-monitor, gtd-active]
---

# Builder · AI 编码席位

> 这是你每天 80% 编码工作的入口。**输入一句话需求，输出可运行代码 + 部署链接。**

## Overview

把 `mvp-bootstrap` 的 Next.js 5 步流程，扩展为**多栈版本**（Next.js / Vue 3 / FastAPI / Spring Boot），并加上：
- **栈自动选择**（根据需求关键词判断）
- **gbrain 优先查找**（避免重复造轮子）
- **builder agent prompt 模板**（直接喂给 Claude Code/Codex/Hermes）
- **失败重试 SOP**（5 类常见错误的快速修复）

**不做什么**（明确边界）：
- ❌ 不写完整 PRD（→ `prd-writer` skill）
- ❌ 不做架构设计（→ 用 DESGIN.md skill）
- ❌ 不做 SEO/营销内容（→ `writer` skill）
- ❌ 不做长期规划（→ `gtd-active` skill）

---

## When to Use

**触发**：
- 「帮我做一个 X 工具 / 落地页 / SaaS / 插件」
- 「新建项目 / 启动 MVP」
- 「实现 Y 功能」+ 具体需求
- 「修这个 bug / 改 Z 行为」
- 「给项目加 W 集成」

**不触发**（用其他 skill）：
- 调研类问题（→ 用 `researcher` 席位 / web search）
- 写作类任务（→ `writer` 席位）
- 长期规划（→ `gtd-active`）
- 纯运维监控（→ `ws-monitor`）

---

## 0. 启动前 30 秒：3 件事

```bash
# 1. gbrain 查一下（避免重复造轮子）
gbrain query "$需求关键词"

# 2. 选栈（看下方"栈选择决策树"）

# 3. 检查 workspace
ls ~/ws2026/ | grep "$领域关键词"  # 避免重复
```

> **为什么**：你 30+ 项目已经有大量现成模板。30 秒省 30 分钟。

---

## 1. 栈选择决策树

```
用户说                          → 栈
─────────────────────────────────────────────────
"做一个 AI 工具"               → Next.js 15 + shadcn + Vercel
"做一个静态网站 / landing page" → Next.js 15 + Tailwind + Vercel
"做一个 Vue 项目"               → Vue 3 + Vite + pnpm monorepo
"做一个 Python 后端 / API"     → FastAPI + SqlModel
"做一个 Java 后端 / 企业应用"  → Spring Boot 3.2 + JPA
"做一个全栈应用"               → Next.js 15 (前后端同构) ⭐推荐
"做一个小脚本 / CLI"           → Python + click
"做一个 Chrome 插件"           → Plasmo + React
"做一个小游戏"                 → Phaser / P5.js
"做硬件 / IoT"                → ESP32 + MicroPython
"不确定"                      → 直接问用户
```

**经验法则**：
- 90% 情况用 **Next.js 15**（闭环最快）
- 需要复杂前端交互用 **Vue 3**（你 wechat-formatter 用的）
- 纯 API / 异步任务用 **FastAPI**（你 copywriter 用的）
- 已有 Java 团队用 **Spring Boot**（你 skillhub 用的）

---

## 2. Builder Agent Prompt 模板

直接复制使用，根据栈替换 `<STACK>`：

```markdown
# Role
你是 Builder，一个全栈 AI 工程师，遵循 5 步流程：PRD → 设计 → 实现 → 自测 → 部署。

# Context
- 用户需求：<USER_REQUEST>
- 工作目录：<PROJECT_DIR>
- 技术栈：<STACK>
- 类似项目参考：<SIMILAR_PROJECTS>

# Process（严格执行，不要跳步）

## Step 1: PRD（如果不存在）
写 `docs/PRD.md`：
- 用户画像（一句话）
- 场景故事
- MVP 功能清单（做什么 / 不做什么）
- 交互流程（5 步内）
- 成功标准

## Step 2: 设计（DESIGN.md）
写 `docs/DESIGN.md`：
- 技术选型理由
- 架构图（mermaid）
- 数据模型（ER 图）
- API 设计表
- 环境变量清单

## Step 3: 实现
按顺序：
1. 项目脚手架（`npx create-...`）
2. 数据模型 + 迁移
3. API 路由（先 mock，后实现）
4. 前端组件（按路由拆）
5. 集成 + 自测

每完成一步立即跑 `npm run dev` / `uvicorn` 验证。

## Step 4: 自测清单
- [ ] 主流程跑通（端到端）
- [ ] 控制台无报错
- [ ] Network 请求都 2xx
- [ ] 移动端基本可用
- [ ] 环境变量 `.env.example` 完整

## Step 5: 部署
- Next.js → Vercel（推 GitHub 即部署）
- Vue → Vercel / Netlify
- FastAPI → Railway / Fly.io
- Spring Boot → Docker + 云服务器

# Constraints（硬规则）
- TypeScript strict mode（TS 项目）
- 不用 `any` `@ts-ignore` 抑制错误
- 不用空 catch
- 不删失败的测试
- Conventional Commits
- 完成后立即喂入 gbrain：`gbrain import <project>/README.md`

# Output
返回：
1. 完成的功能清单
2. 关键文件路径
3. 部署 URL
4. 下一步建议
```

---

## 3. 四栈快速参考

### 3.1 Next.js 15（默认首选）

```bash
# 创建
npx create-next-app@latest my-project \
  --typescript --tailwind --eslint --app --src-dir \
  --import-alias "@/*"

cd my-project
npx shadcn@latest init  # Default / Slate / Yes
npx shadcn@latest add button card input textarea form dialog sheet toast

# 数据库（可选）
npm install prisma @prisma/client
npx prisma init
```

**关键约定**（来自 ws2026/AGENTS.md）：
- 路径别名 `@/*`
- 状态用 Zustand，不引入 Redux
- 组件 PascalCase，工具 camelCase
- Tailwind 工具类，不用 inline style

**完整模板**：见 `mvp-bootstrap` skill（本 skill 的前身）

### 3.2 Vue 3 + Vite（pnpm monorepo）

```bash
pnpm create vue@latest my-project
# 勾选：TypeScript, Router, Pinia, Vitest, ESLint, Prettier
cd my-project && pnpm install
```

**关键约定**（来自 wechat-formatter-md）：
- `<script setup>` 组合式 API
- 状态用 Pinia
- pnpm workspace 管理 monorepo
- 路径别名 `@/`

**常用命令**（来自 ws2026/AGENTS.md）：
```bash
pnpm web dev      # 启动 web
pnpm web build    # 构建
pnpm run lint     # lint 整个 monorepo
pnpm run type-check
```

### 3.3 FastAPI + SqlModel（Python）

```bash
mkdir my-project && cd my-project
python -m venv .venv && source .venv/bin/activate
pip install fastapi uvicorn[standard] sqlmodel pydantic python-dotenv

# 启动
uvicorn main:app --reload
```

**关键约定**（来自 ws2026/AGENTS.md）：
- Python 3.10+，所有函数加 type hints
- 异步默认（`async def`）
- Pydantic 模型做 schema
- SqlModel 做 ORM
- 不留空 except

**最小骨架**：
```python
# main.py
from fastapi import FastAPI
from sqlmodel import SQLModel, Field, Session, create_engine
app = FastAPI()
# ... 见 mvp-bootstrap 风格的扩展
```

### 3.4 Spring Boot 3.2（Java 21）

```bash
# 用 Spring Initializr
curl https://start.spring.io/starter.zip \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.2.0 \
  -d javaVersion=21 \
  -d dependencies=web,data-jpa,postgresql \
  -d name=my-project \
  -d packageName=com.flybear \
  -o starter.zip && unzip starter.zip
```

**关键约定**（来自 ws2026/AGENTS.md）：
- Controller → Service → Repository 分层
- 构造器注入，不用 `@Autowired`
- JPA entity 用 `Long id @GeneratedValue`
- 可用 records、sealed classes、text blocks

**常用命令**：
```bash
./mvnw spring-boot:run
./mvnw test
./mvnw test -Dtest=ClassName#methodName
./mvnw verify
```

---

## 4. 5 步执行流（统一）

无论选哪个栈，都按这 5 步走：

### Step 1: PRD（5 分钟）
写 `docs/PRD.md`（参考 mvp-bootstrap 模板），明确：
- 用户画像
- 做什么 / 不做什么
- 成功标准

**判断**：需求 < 3 行 → 跳过 PRD，直接做

### Step 2: DESIGN.md（10 分钟）
写 `docs/DESIGN.md`：
- 架构图
- 数据模型
- API 设计
- 环境变量

**判断**：纯前端 / 纯脚本 → 跳过

### Step 3: 实现（30-120 分钟）
顺序：
1. 脚手架（5min）
2. 数据模型（10min）
3. API 路由（20min）
4. 前端组件（30min）
5. 集成（10min）

**每完成一个模块立即自测**。

### Step 4: 自测（10 分钟）
- [ ] 主流程跑通
- [ ] F12 无报错
- [ ] 移动端基本可用
- [ ] 关键数据持久化

### Step 5: 部署（10 分钟）
- 推 GitHub
- 配 Vercel / Railway / Docker
- 验证线上可访问
- 喂入 gbrain

---

## 5. 失败快速修复（5 类常见错误）

| 错误 | 症状 | 快速修复 |
|------|------|---------|
| **TypeScript 类型报错** | `as any` 诱因 | 加 type narrowing，**不**用 `as any` |
| **Prisma 连接耗尽** | 热更新后报错 | 用 `globalForPrisma` 单例模式 |
| **Vercel 部署 500** | 本地正常 | 检查 `directUrl`（Postgres） + 环境变量 |
| **Next.js 路由问题** | 404 / 500 | App Router 路径用 `(group)` 不用嵌套 |
| **FastAPI CORS** | 前端调不通 | 加 `CORSMiddleware`，允许 origin |

完整诊断清单见 `mvp-bootstrap` 第 9 节。

---

## 6. 输出规范（Builder 必须给）

完成一个任务后，**必须**输出这 4 项：

```markdown
## ✅ 完成

### 功能清单
- ✅ 功能 A（路径：`src/...`）
- ✅ 功能 B（路径：`src/...`）

### 关键文件
- PRD: `docs/PRD.md`
- 设计: `docs/DESIGN.md`
- 主入口: `src/app/page.tsx` / `main.py` / `Application.java`

### 部署
- 预览 URL: <url>
- GitHub: <repo>

### 下一步
- [ ] 建议 1
- [ ] 建议 2
```

---

## 7. 与其他 skill 的协同

| 场景 | 配合 skill |
|------|-----------|
| 写完功能要提 PR | → `code-review` / `requesting-code-review` |
| 写完代码要写文档 | → `writer` 席位 |
| 完成后要纳入 gtd | → `gtd-active` 写入"今日完成" |
| 部署到 Vercel 出错 | → `vercel-deploy`（如存在） |
| 整个项目进度跟踪 | → `ws-monitor` |

---

## 8. 自检清单（开始任何任务前）

- [ ] 已读 gbrain 相关历史（避免重复造轮子）
- [ ] 已确认栈选型（用决策树）
- [ ] 已检查 workspace 没有重复项目
- [ ] 已规划 5 步流程（不跳步）
- [ ] 已设自测 checklist

> **反模式**：
> - ❌ "用户说做 X，我直接 clone 模板开干" — 先看 gbrain
> - ❌ "Stack 选 Vue" 但需求是 SaaS — 用决策树，不是凭感觉
> - ❌ "完成后不写 gbrain" — 12 个月后你忘了为什么做这个
> - ❌ "跳过 Step 4 自测" — 90% 错误在这里被埋下

---

## 9. 完整示例：30 分钟做一个落地页

```bash
# 1. gbrain 查（30s）
gbrain query "landing page 模板"

# 2. 选栈：Next.js 15（默认）

# 3. 启动 builder agent
# 把以下 prompt 喂给 Claude Code：

"""
你是 Builder，用户需求：「做一个 996 工具箱的落地页，3 个产品卡片，邮件订阅」。

工作目录：~/ws2026/996-toolkit
技术栈：Next.js 15 + Tailwind + shadcn/ui
部署：Vercel

按 5 步流程执行：
1. 写 docs/PRD.md（一句话用户画像 + 3 个功能）
2. 写 docs/DESIGN.md（架构图 + 单页设计）
3. 用 create-next-app 创建项目
4. 实现：3 个 ProductCard + 1 个 EmailForm + 落地页布局
5. 推 GitHub + Vercel 部署

完成后输出：完成清单 + 文件路径 + 部署 URL + 下一步。
"""

# 4. builder agent 跑完后，喂入 gbrain
gbrain import ~/ws2026/996-toolkit/README.md
```

**预计时间**：30 分钟（vs 不使用 builder 的 2-3 小时）

---

## 哲学

> Builder 不是一个 AI 工具，**它是你的"日工作流的中枢"**。
>
> 12 个月后，你的每日编码流程从「打开 IDE → 回忆上次干了啥 → 重新搭脚手架」变成「一句话需求 → 30 分钟可运行代码 → gbrain 自动归档」。这就是 L1 资产层的力量。

**铁律**：
- 每天 Builder 任务不超过 3 个（深度工作 vs 多任务）
- 每个 Builder 任务完成后必须喂入 gbrain
- Builder 不替你做决策，只帮你执行（决策由 gtd-active + 你做）
