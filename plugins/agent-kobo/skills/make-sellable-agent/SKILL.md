---
name: make-sellable-agent
description: Builds a Claude plugin (agent) that can be delivered to a customer, from interview to a checked, packaged release. Use when the user asks to make, build, or sell an agent or plugin for a customer or for a specific job, or asks to resume building one.
---

# 売り物になるエージェントを作る

利用者は非エンジニア。専門用語を使わず、平易な日本語で短く話す。質問するのは段階1だけ。

## 作業フォルダと進捗記録

作るエージェントごとに、利用者の作業場所に `kobo/<顧客名>-<仕事名>/` を作る（英小文字・数字・ハイフン）。
中身は `spec.md`（仕様メモ）、`progress.md`（進捗記録）、`<プラグイン名>/`（作ったプラグイン）。

**最初に必ず** `kobo/*/progress.md` を探す。同じ顧客・仕事のものがあれば、その記録の「次にやること」から再開し、
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

## 守ること

- 土台は Anthropic 公式のもの（plugin-dev の手順書、`claude plugin eval`、`claude plugin validate`、`claude plugin tag`）を使う。同じことを自作しない。
- パスワード・鍵・トークンはどのファイルにも書かない。必要なら plugin.json の `userConfig` に `sensitive: true` で聞く形にする。
- 名前に `claude`・`anthropic`・`official`・`plugin`・`test` を単独で使わない。顧客や仕事に固有の名前にする。
- 最上位に `bin/` を作らない（claude.ai と Cowork で入らなくなる）。
- 作るエージェントは**すべて、標準で利用者の Google Drive につなぐ**（利用者の決まり）。工房自身も、聞き取りの前に Drive で資料を探す。
