#!/usr/bin/env python3
"""
项目体检报告 (Python 版 — 从 cli-diagnose 轻量迁移)
用法: python3 diagnose.py /path/to/project

核心逻辑:
  1. 检测项目类型 (node/python/go/unknown)
  2. 扫描 manifest 获取项目信息
  3. 检查关键文件缺失
  4. 依赖健康检查 (lock 文件 / git URL)
  5. 评分 + 风险等级
  6. 输出报告
"""

import os
import sys
import json
import time


# ============================================================
# 1. 项目类型检测
# ============================================================

def detect_project_type(root):
    """检测项目类型: node > python > go > unknown"""
    if os.path.exists(os.path.join(root, "package.json")):
        return "node"
    for marker in ("pyproject.toml", "requirements.txt", "setup.py"):
        if os.path.exists(os.path.join(root, marker)):
            return "python"
    if os.path.exists(os.path.join(root, "go.mod")):
        return "go"
    return "unknown"


# ============================================================
# 2. 扫描器
# ============================================================

def scan_node(root):
    pkg_path = os.path.join(root, "package.json")
    with open(pkg_path, encoding="utf-8") as f:
        pkg = json.load(f)
    deps = {}
    deps.update(pkg.get("dependencies", {}))
    deps.update(pkg.get("devDependencies", {}))
    return {
        "type": "node",
        "name": pkg.get("name", os.path.basename(root)),
        "version": pkg.get("version", ""),
        "description": pkg.get("description", ""),
        "deps": list(deps.keys()),
        "dep_values": deps,
        "manifest_file": pkg_path,
        "engine_version": pkg.get("engines", {}).get("node", ""),
    }


def scan_python(root):
    info = {"type": "python", "deps": [], "dep_values": {}}
    pyproject = os.path.join(root, "pyproject.toml")
    if os.path.exists(pyproject):
        with open(pyproject, encoding="utf-8") as f:
            content = f.read()
        info["manifest_file"] = pyproject
        for line in content.splitlines():
            line = line.strip()
            if line.startswith("name") and "=" in line:
                val = line.split("=", 1)[1].strip().strip('"').strip("'")
                info["name"] = val
            if line.startswith("version") and "=" in line:
                val = line.split("=", 1)[1].strip().strip('"').strip("'")
                info["version"] = val
    req_path = os.path.join(root, "requirements.txt")
    if os.path.exists(req_path):
        with open(req_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    pkg = line.split("==")[0].split(">=")[0].split("<=")[0].split("~=")[0].split("!=")[0].strip()
                    if pkg:
                        info["deps"].append(pkg)
                        info["dep_values"][pkg] = line
                        if "manifest_file" not in info:
                            info["manifest_file"] = req_path
    if "name" not in info:
        info["name"] = os.path.basename(root)
    return info


def scan_go(root):
    gomod = os.path.join(root, "go.mod")
    info = {"type": "go", "deps": [], "dep_values": {}, "manifest_file": gomod}
    with open(gomod, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("module "):
                info["name"] = line.split("module", 1)[1].strip()
            elif line.startswith("go "):
                info["engine_version"] = line.split("go", 1)[1].strip()
            elif "\t" in line and not line.startswith("require"):
                parts = line.split()
                if len(parts) >= 2:
                    info["deps"].append(parts[0])
                    info["dep_values"][parts[0]] = parts[1]
    if "name" not in info:
        info["name"] = os.path.basename(root)
    return info


def get_lock_files(root, ptype):
    lock_map = {
        "node": ["package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb"],
        "python": ["poetry.lock", "Pipfile.lock", "requirements.lock", "uv.lock"],
        "go": ["go.sum"],
    }
    found = []
    for lf in lock_map.get(ptype, []):
        if os.path.exists(os.path.join(root, lf)):
            found.append(lf)
    return found


def scan(root):
    ptype = detect_project_type(root)
    if ptype == "unknown":
        return None
    scanners = {"node": scan_node, "python": scan_python, "go": scan_go}
    project = scanners[ptype](root)
    lock_files = get_lock_files(root, ptype)
    return {"project": project, "lock_files": lock_files}


# ============================================================
# 3. 检查规则
# ============================================================

FILE_RULES = {
    "common": [".gitignore", "README.md", "LICENSE"],
    "node": [".nvmrc", ".env.example"],
    "python": [".env.example"],
    "go": [".env.example"],
}


def check_files(root, ptype):
    """检查缺失的关键文件"""
    candidates = FILE_RULES["common"] + FILE_RULES.get(ptype, [])
    return [f for f in candidates if not os.path.exists(os.path.join(root, f))]


def check_deps(lock_files, dep_values=None):
    """依赖健康检查 -> warnings"""
    warnings = []
    if not lock_files:
        warnings.append({
            "level": "warn",
            "message": "未检测到 lock 文件，依赖安装可能不可复现",
            "rule": "no-lock-file",
        })
    if dep_values:
        for name, version in dep_values.items():
            if isinstance(version, str) and (
                version.startswith("git+") or version.startswith("github:")
                or version.startswith("gitlab:") or version.startswith("bitbucket:")
            ):
                warnings.append({
                    "level": "warn",
                    "message": "依赖 %s 使用 git URL (%s)，版本不稳定" % (name, version),
                    "rule": "git-url-dep",
                })
    return warnings


def check_git(root):
    """Git 健康检查"""
    warnings = []
    git_dir = os.path.join(root, ".git")
    if not os.path.exists(git_dir):
        warnings.append({
            "level": "info",
            "message": "项目未初始化 Git",
            "rule": "no-git",
        })
    return warnings


# ============================================================
# 4. 评分
# ============================================================

def calc_score(ptype, missing_files, warnings):
    """计算评分和风险等级"""
    score = 100
    if ptype == "unknown":
        score -= 20
    for f in missing_files:
        if f in ("README.md", "LICENSE"):
            continue
        score -= 5
    if "README.md" in missing_files:
        score -= 10
    if "LICENSE" in missing_files:
        score -= 5
    if any(w["rule"] == "no-lock-file" for w in warnings):
        score -= 10
    git_deps = [w for w in warnings if w["rule"] == "git-url-dep"]
    score -= len(git_deps) * 5
    score = max(0, score)
    risk = "low" if score >= 80 else ("medium" if score >= 60 else "high")
    return score, risk


# ============================================================
# 5. 报告输出
# ============================================================

def render_report(root, result, missing_files, warnings, score, risk, duration_ms):
    proj = result["project"]
    lines = []
    lines.append("📋 项目体检报告")
    lines.append("  路径: %s" % root)
    lines.append("  类型: %s" % proj["type"])
    lines.append("  名称: %s" % proj.get("name", "N/A"))
    if proj.get("version"):
        lines.append("  版本: %s" % proj["version"])
    lines.append("  依赖数: %d" % len(proj.get("deps", [])))
    if result["lock_files"]:
        lines.append("  Lock: %s" % ", ".join(result["lock_files"]))
    lines.append("  评分: %d/100" % score)
    lines.append("  风险: %s" % risk.upper())
    lines.append("")

    if missing_files:
        lines.append("📁 缺失文件:")
        for f in missing_files:
            lines.append("  ❌ %s" % f)
        lines.append("")

    if warnings:
        level_icon = {"warn": "⚠️", "critical": "🔴", "info": "ℹ️"}
        lines.append("🔍 告警:")
        for w in warnings:
            icon = level_icon.get(w["level"], "⚠️")
            lines.append("  %s %s" % (icon, w["message"]))
        lines.append("")

    lines.append("💡 建议:")
    if "README.md" in missing_files:
        lines.append("  → 补充 README.md（项目说明文档）")
    if "LICENSE" in missing_files:
        lines.append("  → 补充 LICENSE 文件（开源协议）")
    if ".gitignore" in missing_files:
        lines.append("  → 补充 .gitignore（避免提交无关文件）")
    if any(w["rule"] == "no-lock-file" for w in warnings):
        lines.append("  → 添加 lock 文件（确保依赖可复现）")
    if not missing_files and not warnings:
        lines.append("  → 项目健康度良好，继续保持！")

    lines.append("")
    lines.append("⏱  耗时: %dms" % duration_ms)
    return "\n".join(lines)


# ============================================================
# 6. 主流程
# ============================================================

def main():
    if len(sys.argv) < 2:
        print("用法: python3 diagnose.py <project-path>")
        print("示例: python3 diagnose.py ~/ws2026/my-project")
        sys.exit(1)

    root = os.path.abspath(sys.argv[1])
    if not os.path.isdir(root):
        print("❌ 路径不存在: %s" % root)
        sys.exit(1)

    start = time.time()

    result = scan(root)
    if not result:
        print("❌ 无法识别项目类型: %s" % root)
        print("   支持: node / python / go")
        sys.exit(1)

    proj = result["project"]
    ptype = proj["type"]

    missing_files = check_files(root, ptype)
    warnings = check_deps(result["lock_files"], proj.get("dep_values"))
    warnings += check_git(root)

    score, risk = calc_score(ptype, missing_files, warnings)

    duration_ms = int((time.time() - start) * 1000)
    report = render_report(root, result, missing_files, warnings, score, risk, duration_ms)
    print(report)

    if "--save" in sys.argv:
        report_path = os.path.join(root, "DIAGNOSE-REPORT.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write("# 项目体检报告\n\n```\n%s\n```\n" % report)
        print("\n💾 报告已保存: %s" % report_path)


if __name__ == "__main__":
    main()
