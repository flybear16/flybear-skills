#!/usr/bin/env bash
# flybear-push.sh — 一键推送 flybear-skills
# 思路参考 ljg-push：检测变更 → README 硬 gate → version bump → 推 master
# 飞熊专用：照搬 ljg-push 的核心，简化掉 org→md 双分支（你的仓库本来就纯 md）
#
# 用法：
#   ./flybear-push.sh                  正常推
#   ./flybear-push.sh --dry-run        只看不推
#   ./flybear-push.sh --skip-readme    跳过 README 硬 gate（确认过才用）
#   ./flybear-push.sh --auto-bump      自动 bump 所有有变更 skill 的 patch 版本

set -euo pipefail

# ─── 路径配置 ────────────────────────────────────────────────
SKILLS_REPO="$HOME/ws2026/flybear-skills"
SKILLS_LOCAL="$SKILLS_REPO"   # 你的工作流就是直接改仓库
README="$SKILLS_REPO/README.md"

# ─── 颜色 ───────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; N='\033[0m'

# ─── 参数解析 ───────────────────────────────────────────────
DRY_RUN=0
SKIP_README=0
AUTO_BUMP=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)       DRY_RUN=1 ;;
    --skip-readme)   SKIP_README=1 ;;
    --auto-bump)     AUTO_BUMP=1 ;;
    -h|--help)
      sed -n '2,18p' "$0"; exit 0 ;;
    *) echo -e "${R}未知参数: $arg${N}"; exit 1 ;;
  esac
done

# ─── 前置检查 ───────────────────────────────────────────────
if [ ! -d "$SKILLS_REPO/.git" ]; then
  echo -e "${R}❌ $SKILLS_REPO 不是 git 仓库${N}"; exit 1
fi

cd "$SKILLS_REPO"

# 检查是否有变更
if git diff --quiet HEAD && [ -z "$(git status --porcelain)" ]; then
  echo -e "${Y}⚠️  没有变更，无需推送${N}"
  exit 0
fi

# 列出有变更的 skill
CHANGED_SKILLS=()
for d in */; do
  name="${d%/}"
  [ "$name" = ".github" ] && continue
  [ "$name" = ".git" ] && continue
  [ ! -f "$name/SKILL.md" ] && continue
  # 检测 skill 内是否有变更
  if ! git diff --quiet HEAD -- "$name/" 2>/dev/null || \
     [ -n "$(git status --porcelain -- "$name/")" ]; then
    CHANGED_SKILLS+=("$name")
  fi
done

# 也检测仓库级文件（README 等）
REPO_LEVEL_CHANGED=0
if ! git diff --quiet HEAD -- README.md .github/ 2>/dev/null || \
   [ -n "$(git status --porcelain -- README.md .github/)" ]; then
  REPO_LEVEL_CHANGED=1
fi

# ─── 报告 ───────────────────────────────────────────────────
echo -e "${B}📦 flybear-skills 推送检查${N}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "仓库: ${B}$SKILLS_REPO${N}"
echo -e "分支: ${B}$(git branch --show-current)${N}"
echo ""
echo -e "${B}🔍 检测到变更的 skill (${#CHANGED_SKILLS[@]} 个):${N}"
if [ ${#CHANGED_SKILLS[@]} -eq 0 ]; then
  echo -e "  ${Y}(无 skill 目录变更，只有顶层文件)${N}"
else
  for s in "${CHANGED_SKILLS[@]}"; do
    echo "  • $s"
  done
fi

if [ $REPO_LEVEL_CHANGED -eq 1 ]; then
  echo ""
  echo -e "${B}📝 顶层文件也有变更：${N}"
  git status --porcelain -- README.md .github/ | head -10 | sed 's/^/  /'
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── README 硬 gate ──────────────────────────────────────────
echo -e "${B}🔒 README 硬 gate 检查...${N}"
README_OK=1

if [ ! -f "$README" ]; then
  echo -e "${R}❌ README.md 不存在${N}"
  README_OK=0
else
  # 提取 README 里提到的 skill 名（按 `./skill-name/` 形式）
  README_SKILLS=$(grep -oP '\(\./[^)]+?/\)' "$README" | sed 's|^(./||; s|/)||' | sort -u)

  # 本地实际 skill
  LOCAL_SKILLS=$(for d in */; do
    name="${d%/}"
    [ "$name" = ".github" ] && continue
    [ "$name" = ".git" ] && continue
    [ -f "$name/SKILL.md" ] && echo "$name"
  done | sort)

  # 1) 本地有但 README 没提
  MISSING_IN_README=$(comm -23 <(echo "$LOCAL_SKILLS") <(echo "$README_SKILLS"))
  # 2) README 提了但本地没有
  PHANTOM_IN_README=$(comm -13 <(echo "$LOCAL_SKILLS") <(echo "$README_SKILLS"))

  if [ -n "$MISSING_IN_README" ]; then
    echo -e "${R}❌ README 缺失以下 skill 的引用：${N}"
    echo "$MISSING_IN_README" | sed 's/^/    /; s/$/\//' | sed 's|^|    \./|'
    README_OK=0
  fi

  if [ -n "$PHANTOM_IN_README" ]; then
    echo -e "${R}❌ README 提到了不存在的 skill：${N}"
    echo "$PHANTOM_IN_README" | sed 's/^/    \.\//; s/$/\//'
    README_OK=0
  fi

  if [ $README_OK -eq 1 ]; then
    echo -e "${G}✅ README 与本地 skill 列表一致${N}"
  fi
fi

# README 也被改了 → 不阻断（用户在主动更新）
if ! git diff --quiet HEAD -- README.md 2>/dev/null; then
  echo -e "${Y}ℹ️  README.md 本身有变更（不阻断）${N}"
  README_OK=1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── version bump ───────────────────────────────────────────
if [ $AUTO_BUMP -eq 1 ] && [ ${#CHANGED_SKILLS[@]} -gt 0 ]; then
  echo -e "${B}🔢 自动 bump version (patch)...${N}"
  for s in "${CHANGED_SKILLS[@]}"; do
    meta="$s/_meta.json"
    if [ -f "$meta" ]; then
      current=$(grep -oP '"version":\s*"\K[^"]+' "$meta")
      IFS='.' read -r major minor patch <<< "$current"
      new_patch=$((patch + 1))
      new_version="$major.$minor.$new_patch"
      new_ts=$(date +%s)000
      sed -i "s/\"version\": \"$current\"/\"version\": \"$new_version\"/" "$meta"
      sed -i "s/\"publishedAt\": [0-9]*/\"publishedAt\": $new_ts/" "$meta"
      echo -e "  ${G}$s: $current → $new_version${N}"
    fi
  done
  echo ""
elif [ ${#CHANGED_SKILLS[@]} -gt 0 ] && [ $DRY_RUN -eq 0 ]; then
  read -p "是否自动 bump 这些 skill 的 patch 版本? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for s in "${CHANGED_SKILLS[@]}"; do
      meta="$s/_meta.json"
      if [ -f "$meta" ]; then
        current=$(grep -oP '"version":\s*"\K[^"]+' "$meta")
        IFS='.' read -r major minor patch <<< "$current"
        new_patch=$((patch + 1))
        new_version="$major.$minor.$new_patch"
        new_ts=$(date +%s)000
        sed -i "s/\"version\": \"$current\"/\"version\": \"$new_version\"/" "$meta"
        sed -i "s/\"publishedAt\": [0-9]*/\"publishedAt\": $new_ts/" "$meta"
        echo -e "  ${G}$s: $current → $new_version${N}"
      fi
    done
  fi
fi

# ─── 阻断检查 ───────────────────────────────────────────────
if [ $README_OK -eq 0 ] && [ $SKIP_README -eq 0 ]; then
  echo -e "${R}❌ README gate 失败${N}"
  echo -e "${Y}💡 修复 README 后重跑，或加 --skip-readme 强制推送（不推荐）${N}"
  exit 1
fi

# ─── 推 ─────────────────────────────────────────────────────
if [ $DRY_RUN -eq 1 ]; then
  echo -e "${B}🔍 DRY RUN — 不会推送，只显示计划：${N}"
  echo ""
  git status --short
  echo ""
  echo -e "${Y}将执行：git add . && git commit -m \"...\" && git push origin master${N}"
  exit 0
fi

# 生成 commit message
if [ ${#CHANGED_SKILLS[@]} -eq 0 ]; then
  msg="chore: update repo files"
elif [ ${#CHANGED_SKILLS[@]} -eq 1 ]; then
  msg="feat(${CHANGED_SKILLS[0]}): update skill"
else
  msg="feat: update ${#CHANGED_SKILLS[@]} skills (${CHANGED_SKILLS[*]})"
fi

echo -e "${B}🚀 推送中...${N}"
git add .

# 二次确认
read -p "提交信息: \"$msg\"  [Enter 确认 / e 编辑] " -r
if [[ $REPLY =~ ^[Ee]$ ]]; then
  GIT_EDITOR=true git commit -e -m "$msg" || git commit -m "$msg"
else
  git commit -m "$msg"
fi

git push origin master

echo ""
echo -e "${G}✅ 推送完成！${N}"
echo -e "查看: ${B}https://github.com/flybear16/flybear-skills${N}"

# 可选：本地通知（ljg-push 的设计）
if command -v curl >/dev/null 2>&1 && [ -n "${FLYBEAR_NOTIFY:-}" ]; then
  curl -s -X POST "$FLYBEAR_NOTIFY" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"flybear-push\",\"body\":\"Pushed ${#CHANGED_SKILLS[@]} skills\"}" \
    >/dev/null 2>&1 || true
fi
