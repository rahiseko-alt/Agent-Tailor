#!/bin/sh
# 申請前確認表のうち、公式の `claude plugin validate --profile directory --strict` が見ない項目だけを検査する。
# 使い方: sh check-extra.sh <プラグインのフォルダ>
# 終了コード: 0 = 全項目合格 / 1 = 不合格あり / 2 = フォルダが無い
#
# 公式 validate が拾うため、ここでは見ない項目（Claude Code 2.1.318 で実測）:
#   LICENSE の有無、README の語数、.DS_Store などの system ファイル、名前の規則、manifest の書式
# 根拠: https://claude.com/docs/plugins/pre-submission-checklist
set -u
dir=${1:-}
if [ -z "$dir" ] || [ ! -d "$dir" ]; then
  echo "フォルダが見つかりません: $dir" >&2
  exit 2
fi
bad=0
pass() { echo "合格   $1"; }
ng()   { echo "不合格 $1"; bad=1; }

# 1. bin/ があると claude.ai と Cowork で入らない
if [ -d "$dir/bin" ]; then
  ng "bin: 最上位に bin/ があります。claude.ai と Cowork で入らなくなるので、scripts/ などへ移してください"
else
  pass "bin: 最上位に bin/ はありません"
fi

# 2. 画像・フォント以外で 256KiB を超えるファイル（超えると審査待ちになる）
big=$(find "$dir" -type f -size +256k ! -path '*/.git/*' \
  ! -iname '*.png' ! -iname '*.jpg' ! -iname '*.jpeg' ! -iname '*.gif' ! -iname '*.webp' \
  ! -iname '*.woff' ! -iname '*.woff2' ! -iname '*.ttf' ! -iname '*.otf' 2>/dev/null)
if [ -n "$big" ]; then
  ng "大きさ: 256KiB を超えるファイルがあります。分けるか小さくしてください: $(echo "$big" | tr '\n' ' ')"
else
  pass "大きさ: 256KiB を超えるファイルはありません"
fi

# 3. 中を確かめられない種類のファイル（文字・SVG・PNG/JPEG/GIF/WebP・フォント以外は審査待ちになる）
odd=$(find "$dir" -type f ! -path '*/.git/*' \( -iname '*.zip' -o -iname '*.pdf' -o -iname '*.ico' \
  -o -iname '*.exe' -o -iname '*.dll' -o -iname '*.so' -o -iname '*.dylib' -o -iname '*.mcpb' -o -iname '*.dxt' \
  -o -iname '*.tar' -o -iname '*.gz' -o -iname '*.jar' -o -iname '*.bin' \) 2>/dev/null)
if [ -n "$odd" ]; then
  ng "種類: 中を確かめられない種類のファイルがあります。外すか、文字のファイルに置き換えてください: $(echo "$odd" | tr '\n' ' ')"
else
  pass "種類: 中を確かめられない種類のファイルはありません"
fi

# 4. 版を決めずにパッケージを起動している（npx/bunx は pkg@1.2.3、uvx/pipx は pkg==1.2.3 の形が必要）
#    設定ファイルの中で、起動役の直後に来る最初のパッケージ名だけを見る簡易判定
loose=""
for f in $(find "$dir" -type f \( -name '*.json' -o -name '*.sh' \) ! -path '*/.git/*' 2>/dev/null); do
  # npx / bunx: "command":"npx","args":["-y","pkg"] と npx -y pkg の両方の書き方を見る
  pk=$(tr -d '\n' < "$f" | grep -oE '(npx|bunx)("[[:space:]]*,[[:space:]]*"args"[[:space:]]*:[[:space:]]*\[|[[:space:]])[^]]*' \
    | sed -E 's/^(npx|bunx)//' | tr ',' '\n' | tr -d '"[ ' | sed 's/^args://' | grep -vE '^(-|$)' | head -1)
  if [ -n "$pk" ] && ! echo "$pk" | grep -qE '@[0-9]'; then loose="$loose $f"; fi
  pk=$(tr -d '\n' < "$f" | grep -oE '(uvx|pipx run)("[[:space:]]*,[[:space:]]*"args"[[:space:]]*:[[:space:]]*\[|[[:space:]])[^]]*' \
    | sed -E 's/^(uvx|pipx run)//' | tr ',' '\n' | tr -d '"[ ' | sed 's/^args://' | grep -vE '^(-|$)' | head -1)
  if [ -n "$pk" ] && ! echo "$pk" | grep -qE '==[0-9]'; then loose="$loose $f"; fi
done
if [ -n "$loose" ]; then
  ng "版の固定: 版を決めずにパッケージを起動しています。npx pkg@1.2.3 や uvx pkg==1.2.3 のように版を書いてください:$loose"
else
  pass "版の固定: パッケージの起動はすべて版が決まっています"
fi

# 5. 利用者の Google Drive につながっている（工房が作るエージェントの標準。利用者の決まり）
#    公式の接続先: https://drivemcp.googleapis.com/mcp/v1 （anthropics/knowledge-work-plugins と同じ）
#    .mcp.json と plugin.json の mcpServers のどちらに書いてもよい（manifest reference の書き方）
if grep -qs 'https://drivemcp.googleapis.com/mcp/v1' "$dir/.mcp.json" "$dir/.claude-plugin/plugin.json"; then
  pass "Drive: Google Drive につながっています"
else
  ng "Drive: .mcp.json に Google Drive の接続（https://drivemcp.googleapis.com/mcp/v1）を入れてください"
fi

exit $bad
