#!/bin/sh
# agent-kobo の自作検査の検査。手で流す: sh tests/kobo-check.test.sh
# 合格見本1つと、項目ごとに1つずつ落ちる見本を作り、検査スクリプトに渡す。
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
checker="$root/plugins/agent-kobo/skills/make-sellable-agent/scripts/check-extra.sh"
fail=0
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

check() { # $1 説明, $2 条件の終了コード
  if [ "$2" -eq 0 ]; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi
}

sample() { # $1 作る場所
  mkdir -p "$1/.claude-plugin" "$1/skills/do-thing" "$1/assets"
  printf '{"name":"sample-thing","version":"1.0.0","license":"MIT"}\n' > "$1/.claude-plugin/plugin.json"
  printf -- '---\nname: do-thing\ndescription: Does a thing.\n---\nDo it.\n' > "$1/skills/do-thing/SKILL.md"
  printf '<svg xmlns="http://www.w3.org/2000/svg"/>\n' > "$1/assets/icon.svg"
  printf '# Sample\n' > "$1/README.md"
  printf '{"mcpServers":{"google-drive":{"type":"http","url":"https://drivemcp.googleapis.com/mcp/v1"}}}\n' > "$1/.mcp.json"
}

run() { sh "$checker" "$1" > "$work/out" 2>&1; }

# 合格見本
sample "$work/ok"
printf '{"mcpServers":{"google-drive":{"type":"http","url":"https://drivemcp.googleapis.com/mcp/v1"},"a":{"command":"npx","args":["-y","pkg@1.2.3"]},"b":{"command":"uvx","args":["tool==0.4.0"]}}}\n' > "$work/ok/.mcp.json"
head -c 300000 /dev/zero > "$work/ok/assets/big.png"   # 画像は大きくてもよい
run "$work/ok"; check "合格見本は終了コード0" $?

# bin/ がある
sample "$work/bin"; mkdir "$work/bin/bin"; printf '#!/bin/sh\n' > "$work/bin/bin/tool"
run "$work/bin"; e=$?; [ $e -eq 1 ]; check "bin/ があると終了コード1" $?
grep -q '^不合格 bin' "$work/out"; check "bin/ が不合格と出る" $?

# 256KiB を超える文字ファイル
sample "$work/big"; head -c 300000 /dev/zero | tr '\0' a > "$work/big/data.txt"
run "$work/big"; e=$?; [ $e -eq 1 ]; check "大きすぎるファイルで終了コード1" $?
grep -q '^不合格 大きさ' "$work/out"; check "大きすぎるファイルが不合格と出る" $?

# 中を確かめられない種類のファイル
sample "$work/zip"; printf 'PK' > "$work/zip/extra.zip"
run "$work/zip"; e=$?; [ $e -eq 1 ]; check "zip があると終了コード1" $?
grep -q '^不合格 種類' "$work/out"; check "zip が不合格と出る" $?

# 版を決めていない npx
sample "$work/npx"; printf '{"mcpServers":{"a":{"command":"npx","args":["-y","pkg"]}}}\n' > "$work/npx/.mcp.json"
run "$work/npx"; e=$?; [ $e -eq 1 ]; check "版指定なしの npx で終了コード1" $?
grep -q '^不合格 版の固定' "$work/out"; check "版指定なしの npx が不合格と出る" $?

# 版を決めていない uvx
sample "$work/uvx"; printf '{"mcpServers":{"a":{"command":"uvx","args":["tool"]}}}\n' > "$work/uvx/.mcp.json"
run "$work/uvx"; e=$?; [ $e -eq 1 ]; check "版指定なしの uvx で終了コード1" $?

# Google Drive の接続が無い
sample "$work/nodrive"; rm "$work/nodrive/.mcp.json"
run "$work/nodrive"; e=$?; [ $e -eq 1 ]; check "Drive の接続が無いと終了コード1" $?
grep -q '^不合格 Drive' "$work/out"; check "Drive の接続が無いと不合格と出る" $?

# Drive の接続を plugin.json に直接書いてもよい（公式の書き方の一つ）
sample "$work/inline"; rm "$work/inline/.mcp.json"
printf '{"name":"sample-thing","version":"1.0.0","license":"MIT","mcpServers":{"google-drive":{"type":"http","url":"https://drivemcp.googleapis.com/mcp/v1"}}}\n' > "$work/inline/.claude-plugin/plugin.json"
run "$work/inline"; check "plugin.json に書いた Drive の接続でも合格する" $?

# フォルダが無い
sh "$checker" "$work/none" > "$work/out" 2>&1; e=$?; [ $e -eq 2 ]; check "存在しないフォルダは終了コード2" $?

# agent-kobo 自身が合格する
run "$root/plugins/agent-kobo"; check "agent-kobo 自身が合格する" $?

# 公式の検査（claude が入っているときだけ）
if command -v claude >/dev/null 2>&1; then
  claude plugin validate --profile directory --strict "$root/plugins/agent-kobo" > "$work/out" 2>&1
  e=$?; [ $e -eq 0 ] || cat "$work/out"; check "agent-kobo が公式の検査に合格する" $e
  claude plugin validate --strict "$root" > "$work/out" 2>&1
  e=$?; [ $e -eq 0 ] || cat "$work/out"; check "配布用の置き場所定義が公式の検査に合格する" $e
  grep -q '"allowCrossMarketplaceDependenciesOn"' "$root/.claude-plugin/marketplace.json"
  check "別の置き場所への依存を許可している" $?
else
  echo "skip 公式の検査（claude が見つかりません）"
fi

[ $fail -eq 0 ] && echo "すべて合格" || echo "不合格あり"
exit $fail
