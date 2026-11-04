#!/bin/sh
# 申請前確認表のうち、公式の `claude plugin validate --profile directory --strict` が見ない項目と、
# Agent Tailor の決まり（Google Drive に標準でつなぐ）だけを検査する。POSIX sh と awk だけで動く。
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
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
bad=0
pass() { echo "合格   $1"; }
ng()   { echo "不合格 $1"; bad=1; }

# 検査するファイルの一覧（.git と評価結果 evals/results/ は納品物でないので除く）。空白入りの名前でも1行1件
find "$dir" -type f ! -path '*/.git/*' ! -path '*/evals/results/*' > "$tmp/files"

# 1. bin/ があると claude.ai と Cowork で入らない
if [ -d "$dir/bin" ]; then
  ng "bin: 最上位に bin/ があります。claude.ai と Cowork で入らなくなるので、scripts/ などへ移してください"
else
  pass "bin: 最上位に bin/ はありません"
fi

# 2. 画像・フォント以外で 256KiB を超えるファイル（超えると審査待ちになる）
: > "$tmp/big"
while IFS= read -r f; do
  case $(printf '%s' "$f" | tr 'A-Z' 'a-z') in
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.woff|*.woff2|*.ttf|*.otf) continue ;;
  esac
  [ "$(wc -c < "$f")" -gt 262144 ] && printf '%s\n' "$f" >> "$tmp/big"
done < "$tmp/files"
if [ -s "$tmp/big" ]; then
  ng "大きさ: 256KiB を超えるファイルがあります。分けるか小さくしてください: $(tr '\n' ' ' < "$tmp/big")"
else
  pass "大きさ: 256KiB を超えるファイルはありません"
fi

# 3. 中を確かめられない種類のファイル（文字・SVG・PNG/JPEG/GIF/WebP・フォント以外は審査待ちになる）
#    文字かどうかは中身で判定し（grep -I）、圧縮・PDF などは中身が文字に見えても名前で落とす
: > "$tmp/odd"
while IFS= read -r f; do
  lower=$(printf '%s' "$f" | tr 'A-Z' 'a-z')
  case $lower in
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.woff|*.woff2|*.ttf|*.otf) continue ;;
    *.zip|*.pdf|*.ico|*.mcpb|*.dxt|*.tar|*.gz|*.tgz|*.7z|*.jar|*.xlsx|*.xls|*.docx|*.doc|*.pptx|*.ppt)
      printf '%s\n' "$f" >> "$tmp/odd"; continue ;;
  esac
  if [ -s "$f" ] && ! grep -Iq . "$f"; then printf '%s\n' "$f" >> "$tmp/odd"; fi
done < "$tmp/files"
if [ -s "$tmp/odd" ]; then
  ng "種類: 中を確かめられない種類のファイルがあります。外すか、文字のファイルに置き換えてください: $(tr '\n' ' ' < "$tmp/odd")"
else
  pass "種類: 中を確かめられない種類のファイルはありません"
fi

# JSON を1行に詰め、空白を消す（文字列の中の空白も消えるが、ここで見る値には影響しない）
squash() { tr -d ' \t\r\n' < "$1"; }

# サーバーの設定（"名前":{…}）を1行1件で取り出す。env と headers の中身は先に消す
servers() {
  squash "$1" | sed -e 's/"env":{[^{}]*}/"env":{}/g' -e 's/"headers":{[^{}]*}/"headers":{}/g' \
    | grep -o '"[^"]*":{[^{}]*}' || true
}

# 起動役と、その後ろの語の並びから、版が固定されているかを判定する（awk）。1行に「起動役 語 語 …」
pin_awk='
function bad_pkg(kind, p) {
  if (kind == "n") return p !~ /@[0-9]+\.[0-9]+\.[0-9]+([-+][^ ]*)?$/
  return p !~ /==[0-9]+\.[0-9]+\.[0-9]+/
}
{
  for (i = 1; i <= NF; i++) {
    w = $i; kind = ""; start = 0
    if (w == "npx" || w == "bunx") { kind = "n"; start = i + 1 }
    else if ((w == "pnpm" || w == "yarn") && $(i+1) == "dlx") { kind = "n"; start = i + 2 }
    else if (w == "uvx") { kind = "p"; start = i + 1 }
    else if (w == "pipx" && $(i+1) == "run") { kind = "p"; start = i + 2 }
    else if (w == "uv" && $(i+1) == "run") {
      locked = 0
      for (j = i + 2; j <= NF; j++) if ($j == "--locked" || $j == "--frozen") locked = 1
      if (!locked) { print "uv run（--locked か --frozen が必要）"; }
      continue
    }
    if (kind == "") continue
    for (j = start; j <= NF && $j ~ /^-/; j++) ;
    if (j > NF) continue
    if (bad_pkg(kind, $j)) print w " " $j
  }
}'

# 4. 版を決めずにパッケージを起動している（npx/bunx/pnpm dlx/yarn dlx は pkg@1.2.3、uvx/pipx run は pkg==1.2.3）
: > "$tmp/loose"
while IFS= read -r f; do
  case $f in
    *.json)
      servers "$f" | while IFS= read -r obj; do
        cmd=$(printf '%s' "$obj" | sed -n 's/.*"command":"\([^"]*\)".*/\1/p')
        [ -n "$cmd" ] || continue
        args=$(printf '%s' "$obj" | sed -n 's/.*"args":\[\([^]]*\)\].*/\1/p' | sed -e 's/","/ /g' -e 's/"//g')
        printf '%s %s\n' "$cmd" "$args" | awk "$pin_awk" | sed "s#^#$f: #"
      done >> "$tmp/loose" ;;
    *.sh)
      # 行頭が # のコメント行は見ない
      grep -v '^[[:space:]]*#' "$f" | tr ';&|()' '     ' | awk "$pin_awk" | sed "s#^#$f: #" >> "$tmp/loose" ;;
  esac
done < "$tmp/files"
if [ -s "$tmp/loose" ]; then
  ng "版の固定: 版を決めずにパッケージを起動しています。npx pkg@1.2.3 や uvx pkg==1.2.3 のように版を書いてください: $(tr '\n' ' ' < "$tmp/loose")"
else
  pass "版の固定: パッケージの起動はすべて版が決まっています"
fi

# 5. 利用者の Google Drive につながっている（Agent Tailor が作るエージェントの標準。利用者の決まり）
#    公式の接続先 https://drivemcp.googleapis.com/mcp/v1 （anthropics/knowledge-work-plugins と同じ）を
#    url の値に持ち、無効（"disabled":true）でないサーバーが1つあれば合格。
#    場所は .mcp.json、plugin.json の mcpServers、または plugin.json の mcpServers が指すファイル
cands="$dir/.mcp.json $dir/.claude-plugin/plugin.json"
if [ -f "$dir/.claude-plugin/plugin.json" ]; then
  for ref in $(squash "$dir/.claude-plugin/plugin.json" | grep -o '"mcpServers":"[^"]*"\|"mcpServers":\[[^]]*\]' \
      | sed -e 's/"mcpServers"://' | tr -d '[]"' | tr ',' ' '); do
    cands="$cands $dir/${ref#./}"
  done
fi
drive=no
for c in $cands; do
  [ -f "$c" ] || continue
  if servers "$c" | grep '"url":"https://drivemcp.googleapis.com/mcp/v1"' | grep -vq '"disabled":true'; then drive=yes; fi
done
if [ $drive = yes ]; then
  pass "Drive: Google Drive につながっています"
else
  ng "Drive: .mcp.json に Google Drive の接続（\"url\": \"https://drivemcp.googleapis.com/mcp/v1\"）を入れてください"
fi

exit $bad
