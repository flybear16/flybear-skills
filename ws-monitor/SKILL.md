---
name: ws-monitor
description: "监控目录下所有项目的运行状态，包括端口占用、进程信息、Git 状态、数据库连接等。当用户说 /ws list、ws状态、项目状态、ws2026 时触发。"
metadata:
  {
    "copaw":
      {
        "emoji": "📂",
        "requires": {}
      }
  }
---

# WS Monitor Skill

监控指定目录下所有项目的运行状态。

## 触发条件

当用户说以下内容时触发：
- `/ws list` / `/ws status`
- "ws状态"、"项目状态"、"xxx 状态"
- "哪些项目在跑"、"端口占用"
- 可以指定文件夹，如 `/ws list ~/myprojects`

## 扫描目录优先级

1. **用户指定**：如果用户命令中提供了文件夹路径，扫描该路径
2. **默认目录**：`~/ws2026`

支持的路径格式：
- 绝对路径：`/home/user/projects`
- 相对路径：`./myfolder`（相对于当前工作目录）
- Home 目录：`~/projects`
- Workspace 路径：`~/ws2026`

## 检查流程

按以下顺序对目标目录下每个项目进行检查：

### 1. 项目类型识别

根据项目文件自动识别类型：
- `pom.xml` → Java/Maven
- `package.json` → Node.js
- `requirements.txt` / `setup.py` → Python
- `go.mod` → Go
- `Dockerfile` / `docker-compose.yml` → Docker

### 2. Git 状态

```bash
cd <target_dir>/<project>
git status --short
git remote -v
git log --oneline -1
```

检查内容：
- 是否有未提交的修改
- 最近一次提交信息
- 远程仓库地址

### 3. 端口/进程检查

```bash
# 检查常见端口
lsof -i :<port> -t 2>/dev/null || ss -tlnp | grep <port>

# 检查是否有相关进程在运行
ps aux | grep -E "<project-name>" | grep -v grep
```

常见端口映射：
| 项目 | 默认端口 |
|---|---|
| rocket-api | 3080 |
| moyin-creator | 5173 |
| Step-Realtime-Console | 8080 |
| sql-generator | 3000 |

### 4. 数据库连接检查（仅 Java 项目）

```bash
# 从 application.yml 提取数据库配置
grep -A3 "datasource:" src/main/resources/application.yml
# 尝试 TCP 连接测试
timeout 3 bash -c 'echo > /dev/tcp/<host>/<port>' 2>/dev/null
```

### 5. 磁盘/资源占用

```bash
du -sh <target_dir>/<project>
```

## 输出格式

用表格形式展示，简洁明了：

```
📂 ~/ws2026 项目状态
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 rocket-api          Java/Maven    PID:1825293  :3080  ✓ PostgreSQL
   main: feat: 支持 PostgreSQL + Dubbo 通用服务接口
   remote: git@gitee.com:auto-gc/rocket-api.git
   状态: 运行中 | 磁盘: 85M | 无未提交修改

🔴 moyin-creator        Node.js      --           :5173  ✗ 未运行
   main: initial commit
   remote: https://github.com/MemeCalculate/moyin-creator.git
   状态: 未运行 | 磁盘: 666M | 2 个文件修改

🟢 Step-Realtime-Console  Node.js   PID:1238587  :8080  ✓
   main: latest commit
   状态: 运行中 | 磁盘: 120M

──────────────────────────────────────
汇总: 🟢 运行中 2  🔴 未运行 1  📁 共 22 个项目
```

如果用户指定了其他目录，标题会相应变化，如：
```
📂 /home/user/myprojects 项目状态
```

### 状态图标

- 🟢 运行中
- 🟡 异常（进程在但端口不通）
- 🔴 未运行
- ⚪ 非代码项目（无 pom.xml / package.json 等）

## 注意事项

- `lsof` 需要 sudo 或当前用户权限，失败时降级用 `ss -tlnp`
- Docker 项目检查 `docker ps` 而非进程
- 跳过 `_archive` 等以下划线开头的目录
- 跳过纯文档/静态项目（无运行时）
- 相对路径会基于当前工作目录解析
