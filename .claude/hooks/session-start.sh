#!/bin/sh
# 会話開始時に自動で動く仕組み。
# 進め方（flow-map.md）と引き継ぎメモ（handover.md）は、AGENTS.md の公式の読み込み（@）で毎回読まれる。
# ここでは、ひな型の複製の片づけと、引き継ぎメモが上限を超えたときの警告だけを行う。
# 保存の上限の正は handover-trim.sh の KEEP。
set -u

dir="${CLAUDE_PROJECT_DIR:-.}"

# 複製先なら、写ってきたひな型の作業日誌を先に片づける（ひな型そのものでは何もしない）
[ -f "$dir/.claude/hooks/template-cleanup.sh" ] && sh "$dir/.claude/hooks/template-cleanup.sh"

f="$dir/docs/agents/handover.md"
[ -f "$f" ] || exit 0
keep=$(sed -n 's/^KEEP=\([0-9]*\).*/\1/p' "$dir/.claude/hooks/handover-trim.sh" | head -1)
total=$(awk '/^```/{fence=!fence; next} !fence && /^## /{n++} END{print n+0}' "$f")
if [ -n "$keep" ] && [ "$total" -gt "$keep" ]; then
  echo "⚠ 引き継ぎメモが $total 件あります（上限 $keep 件）。古い分を移してください: sh .claude/hooks/handover-trim.sh"
fi
