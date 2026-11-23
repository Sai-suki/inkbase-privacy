#!/bin/bash
# Inkbase 隐私站一键部署：提交 → 推送 → 等待 Pages 构建 → 验证线上页面
# 用法：./deploy.sh ["提交说明"]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
OWNER_REPO="Sai-suki/inkbase-privacy"
BASE_URL="https://sai-suki.github.io/inkbase-privacy"
PAGES=("/" "/zh.html" "/support.html" "/support-zh.html")
MSG="${1:-更新隐私站内容}"

cd "$REPO_DIR"

echo "==> 1/5 检查改动"
if [ -z "$(git status --porcelain)" ]; then
  echo "无改动，直接验证线上状态"
else
  git add -A
  git -c user.name="Sai-suki" -c user.email="1272363703@qq.com" commit -m "$MSG"
fi

echo "==> 2/5 推送"
GIT_TERMINAL_PROMPT=0 git push origin main

echo "==> 3/5 读取 GitHub 凭据"
TOKEN=$(security find-generic-password -s "gh:github.com" -w 2>/dev/null | sed 's/^go-keyring-base64://' | base64 -d)
if [ -z "${TOKEN:-}" ]; then
  echo "未找到 GitHub 凭据，跳过构建状态轮询（推送已完成，Pages 会自行构建）"
else
  echo "==> 4/5 等待 Pages 构建"
  for i in $(seq 1 20); do
    STATUS=$(curl -s -H "Authorization: Bearer $TOKEN" \
      "https://api.github.com/repos/$OWNER_REPO/pages/builds/latest" \
      | /usr/bin/python3 -c "import sys,json;print(json.load(sys.stdin).get('status',''))" 2>/dev/null || echo "")
    echo "    [$i] $STATUS"
    [ "$STATUS" = "built" ] && break
    sleep 8
  done
fi

echo "==> 5/5 验证线上页面"
FAIL=0
for p in "${PAGES[@]}"; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$p")
  printf "    %-20s HTTP %s\n" "$p" "$CODE"
  [ "$CODE" = "200" ] || FAIL=1
done

if [ "$FAIL" = "0" ]; then
  echo "✅ 部署完成：$BASE_URL/"
else
  echo "⚠️  有页面未返回 200，请检查 Pages 构建日志"; exit 1
fi
