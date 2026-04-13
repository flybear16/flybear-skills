---
name: ai-news-collector
description: AI 新闻聚合与热度排序工具。当用户询问 AI 领域最新动态时触发，如："今天有什么 AI 新闻？""总结一下这周的 AI 动态""最近有什么火的 AI 产品？""AI 圈最近在讨论什么？"。覆盖：新产品发布、研究论文、行业动态、融资新闻、开源项目更新、社区病毒传播现象、AI 工具/Agent 热门项目。输出中文摘要列表，按热度排序，附带原文链接。
---

# AI News Collector

收集、聚合并按热度排序 AI 领域新闻。

## 核心原则

**不要只搜"AI news today"。** 泛搜索返回的是 SEO 聚合页和趋势预测文章，会系统性遗漏社区级病毒传播现象。必须用多维度、分层搜索策略。

---

## Step 0：意图检测与路径选择

在开始搜索前，先判断查询类型，选择对应路径：

| 查询类型 | 触发关键词 | 路径 | 预计耗时 |
|----------|------------|------|----------|
| 今日突发 / 热点 | "今天有什么"、"现在有什么"、"刚刚" | 🔥 快速路径 | < 1 分钟 |
| 周汇总 | "这周"、"本周"、"上周" | 📅 标准路径 | 5-8 分钟 |
| 月度 / 趋势 | "这个月"、"最近趋势"、"月度" | 📊 深度路径 | 10-15 分钟 |

**语言检测**：用户用中文提问 → **必须搜中文源**（机器之心、量子位、36氪）+ 英文源互补；英文提问 → 以英文源为主。

**搜索被封时的备用策略**（优先级顺序）：
1. 直接访问官方博客（Anthropic News、Google AI Blog 等）
2. 访问中文源（机器之心、量子位）
3. 尝试 DDG（DuckDuckGo）或 Bing（注意 Bing 可能劫持搜索结果）
4. 放弃该维度，用其他维度补上

---

## 🔥 快速路径（今日突发）

适用于"今天有什么 AI 新闻"类查询。直接抓取核心实时源，不走完整搜索流程。

### 执行步骤

1. **并发抓取**（web_fetch 或 curl）：
   - Hacker News Top 10：`https://news.ycombinator.com/`
   - GitHub Trending：`https://github.com/trending?since=daily`（过滤 AI 相关项目）
   - Ben's Bites：`https://bensbites.com/`（或对应 Newsletter）
   - 产品发布官方博客：OpenAI Blog、Anthropic News、Google AI Blog（当天内容）

2. **提取当天新闻**（只看最近 24 小时内容）

3. **热度排序**：HN 排名 × 2 + GitHub stars 增量（如果有）

4. **输出 5-10 条**，直接进入输出格式

> 如果某个源无法访问（403/超时），立即切换备用源，不要卡住。

---

## 📅 标准路径（周汇总）

适用于"这周 AI 动态"类查询。

### Step 1：并发多维度搜索（6-8 次）

**优先策略**：当搜索被封（Google 被拦截、Bing 劫持）时，**直接访问官方博客页面**比换搜索词更高效。

按以下维度**并发**执行搜索，每个维度 1 次：

#### 维度 A：周报/Newsletter 聚合（最优先 🔑）

```
搜索词：
- "last week in AI" [当前月份年份]
- "AI weekly roundup" [当前月份年份]
```

发现周报后，用 web_fetch 或浏览器获取全文。如果 Substack 需要登录，尝试从 archive 或 RSS 获取。

#### 维度 B：社区热度/病毒传播（关键 🔑）

**GitHub Trending** 直接访问 `https://github.com/trending`，过滤含以下关键词的项目：
- AI、ML、LLM、Agent、Claude、GPT、OpenAI、HuggingFace、Stable Diffusion

**Hacker News** 直接访问 `https://news.ycombinator.com/`，优先提取含 AI/ML/Agent/LLM 的条目。

```
搜索词（备用）：
- "viral AI tool" OR "viral AI agent"
- site:reddit.com AI trending
```

#### 维度 C：产品发布与模型更新

**直接访问官方博客**（最可靠，不受搜索干扰）：
- Anthropic News：`https://www.anthropic.com/news`
- OpenAI Blog：`https://openai.com/blog`（可能需要备用源）
- Google AI Blog：`https://ai.googleblog.com/`
- DeepMind Blog：`https://deepmind.com/blog/`
- Hugging Face Blog：`https://huggingface.co/blog`

```
搜索词（备用）：
- site:anthropic.com OR site:openai.com OR site:deepmind.com [月份]
- "大模型 发布" OR "AI 新产品"
```

#### 维度 D：融资与商业

```
搜索词：
- "AI startup funding" [当前月份年份]
- "AI 融资" OR "人工智能 投资"
```

中文源：36氪 AI (`https://36kr.com/information/AI`)、量子位 (`https://qbitai.com/`)

#### 维度 E：研究突破

**直接访问 arXiv**：
- cs.AI：`https://arxiv.org/list/cs.AI/recent`
- cs.LG：`https://arxiv.org/list/cs.LG/recent`

```
搜索词（备用）：
- "AI breakthrough" [当前月份]
- "state of the art" machine learning
```

#### 维度 F：监管与政策（如有提及）

```
搜索词：
- "AI regulation" OR "AI policy" [当前月份年份]
- "AI 监管" OR "人工智能 法案"
```

### Step 2：搜索饱和度检测

每次搜索后检查：
- **是否有新信息**：新结果与已有结果重复 > 70%？
- **是否已覆盖主要维度**：至少 4 个维度有内容？

如果连续 2 次搜索重复率 > 70%，**提前结束搜索**，不要为了凑数继续搜。

### Step 3：热度评分（客观信号组合）

对每条新闻打分（1-10 分），分数越高越热：

| 信号 | 评分规则 |
|------|----------|
| **HN 排名** | 前 3 名 = +3，前 10 名 = +2，前 30 名 = +1 |
| **GitHub stars 增量** | 24h 内 +1000 = +3，+500 = +2，+100 = +1 |
| **媒体覆盖数量** | 3+ 不同来源 = +3，2 个来源 = +2，1 个来源 = +1 |
| **来源权威性** | 官方博客/顶会 = +2，知名媒体 = +1 |
| **时效性** | 24 小时内 = +2，48 小时 = +1 |
| **社区讨论量** | Reddit 100+ 评论 = +2，HN 50+ 评论 = +1 |

**最终热度 = 各项得分之和**

### Step 4：输出

按热度降序排列，输出 **15-20 条**新闻。

---

## 📊 深度路径（月度/趋势）

适用于"这月 AI 趋势"或"总结 AI 发展"类查询。

在标准路径基础上增加：

1. **arXiv 论文扫描**：抓取最近 2 周 cs.AI / cs.LG 新论文，按引用数排序，取前 5
2. **融资数据统计**：搜索整月所有 AI 融资事件，列出金额最大的 5 笔
3. **GitHub 月度趋势**：查看 GitHub Trending 整个月的 AI 项目演变
4. **输出扩展**：在标准格式基础上，增加"本月趋势总结"段落

---

## 搜索关键词设计原则（反模式清单）

| ❌ 不要这样搜 | ✅ 应该这样搜 | 原因 |
|---|---|---|
| "AI news today February 2026" | "AI weekly roundup February 2026" | 前者返回聚合页，后者返回策划内容 |
| "AI news today" | "viral AI tool" + "AI model release" 分开搜 | 泛搜无法覆盖社区现象 |
| "artificial intelligence breaking news" | 按维度分类搜索 | 过于宽泛，返回噪音 |
| 搜索词中加具体年月日 | 用 "this week" "today" "latest" | 日期反而会偏向预测/展望文章 |
| 搜够 8 次才开始输出 | 搜索饱和就提前结束 | 重复内容搜再多也没用 |

---

## 输出格式

```
## 🔥 AI 新闻速递（YYYY-MM-DD）| [查询类型]

<!-- 按热度降序排列 -->

### 热度最高（8-10 分）

1. **[新闻标题]**
   > 一句话摘要（不超过 50 字）
   > 🔗 [来源名称](URL)
   > 热度信号：HN Top3 | GitHub +2000 stars | 5 家媒体报道

### 高热度（5-7 分）

2. ...

<!-- 中等热度分段展示 -->

---

📊 共收集 **XX** 条新闻 | 搜索 **X** 次 | 覆盖维度：A/B/C/D/E/F | 更新时间：HH:MM
```

---

## 精选核心新闻源（内嵌使用，非外链）

这些是执行效率最高的源，直接使用：

**Newsletter / 周报**：
- Last Week in AI：`https://lastweekin.ai/`
- Ben's Bites：`https://bensbites.com/`
- The Batch：`https://deeplearning.ai/the-batch/`

**实时热点**：
- Hacker News：`https://news.ycombinator.com/`（AI 相关）
- GitHub Trending：`https://github.com/trending`（过滤含 AI/ML/LLM/Agent/Claude/GPT/HuggingFace 关键词的项目）

**官方博客**：
- OpenAI Blog、Anthropic News、Google AI Blog、DeepMind Blog、Hugging Face Blog

**国内源**（中文提问时优先使用）：
- 机器之心：`https://jiqizhixin.com/`
- 量子位：`https://qbitai.com/`
- 36氪 AI：`https://36kr.com/information/AI`
- 即刻 App AI 圈子

---

## 注意事项

- 优先使用 HTTPS 链接
- 遇到付费墙/无法访问的内容，标注"需订阅"，不要卡住
- 保持客观，不对新闻内容做主观评价
- **快速路径不要走标准路径的搜索流程**
- 如果某个维度搜索结果为空，用其他维度补上，不要硬凑
- **搜索被封时**：不要反复重试搜索，立即切换到"直接访问官方博客"策略
