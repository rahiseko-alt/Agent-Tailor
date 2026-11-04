---
name: make-sellable-agent
description: Builds a Claude plugin (agent) tailored to one customer's job, from interview to a checked, packaged release, connected to the user's Google Drive by default. Use when the user asks to make, build, or sell an agent or plugin for a customer or a specific job (for example 「〇〇さん向けのエージェントを作って」「〇〇のサポートエージェントを作れ」), or asks to resume building one.
---

# 顧客専用のエージェントを仕立てる

利用者は非エンジニア。専門用語を使わず、平易な日本語で短く話す。質問するのは段階1だけ。

## 作業フォルダと進捗記録

作るエージェントごとに、利用者の作業場所に `tailor/<顧客名>-<仕事名>/` を作る（英小文字・数字・ハイフン）。
中身は `spec.md`（仕様メモ）、`progress.md`（進捗記録）、`<プラグイン名>/`（作ったプラグイン）。

顧客の資料が入るので、**作業フォルダを公開の置き場所に入れない**。作業場所が git の置き場所なら、
`.gitignore` に `tailor/` があるか確かめ、無ければ足す。

**最初に必ず** `tailor/*/progress.md` を探す。同じ顧客・仕事のものがあれば、その記録の「次にやること」から再開し、
済んだ段階はやり直さない。無ければ新しく作る。各段階が終わるたびに `progress.md` に次を追記する:

```
## 段階N 完了 <日付>
- 結果: <1〜3行>
- 次にやること: 段階N+1
```

## 進め方（この順で、1つずつ）

```
- [ ] 段階1 聞き取り          → references/1-interview.md を読んで進める
- [ ] 段階2 作る              → references/2-build.md を読んで進める
- [ ] 段階3 磨く              → references/3-improve.md を読んで進める
- [ ] 段階4 合格確認と納品形  → references/4-check-and-package.md を読んで進める
```

各段階の終わりに、利用者へ「何ができたか／次に何をするか」を2行で伝え、そのまま次の段階へ進む。
利用枠を使う操作（段階3の評価）の前だけは、一言知らせてから進める。

段階4で使う追加の検査は次のスクリプト（公式の検査が見ない項目と、Drive の接続を見る）:

```
sh ${CLAUDE_SKILL_DIR}/scripts/check-extra.sh <プラグインのフォルダ>
```

## 守ること

- 土台は Anthropic 公式のもの（plugin-dev の手順書、`claude plugin eval`、`claude plugin validate`、`claude plugin tag`）を使う。同じことを自作しない。
- パスワード・鍵・トークンはどのファイルにも書かない。必要なら plugin.json の `userConfig` に `sensitive: true` で聞く形にする。
- 名前に `claude`・`anthropic`・`official`・`plugin`・`test` を単独で使わない。顧客や仕事に固有の名前にする。
- 最上位に `bin/` を作らない（claude.ai と Cowork で入らなくなる）。
- 作るエージェントは**すべて、標準で利用者の Google Drive につなぐ**（利用者の決まり）。Agent Tailor 自身も、聞き取りで Drive の資料を探す。
- 顧客の Drive の資料の本文は、作るプラグインに写さない。プラグインは使うたびに Drive から読む。評価の入力に要る分だけ抜き出し、個人名・連絡先は伏せる。
