# 段階2 作る

目的: spec.md から、顧客に渡せるプラグインを作る。利用者には質問しない。

## 手順

1. 公式の作り方を読み込む: `plugin-dev:plugin-structure` と `plugin-dev:skill-development` の2つのスキルを呼ぶ。
   Google Drive は必ずつなぐので、`plugin-dev:mcp-integration` も呼ぶ。
   `/plugin-dev:create-plugin` は呼ばない（質問が二重になり、後半の段階と重なるため）。
   plugin-dev が入っていなければ、利用者に次の1行を打つよう案内して止まる:
   `/plugin install plugin-dev@claude-plugins-official`
2. `tailor/<…>/<プラグイン名>/` に次を作る:
   - `.claude-plugin/plugin.json`: `name`・`displayName`・`version`（`0.1.0`）・`description`・`author`・`license`（`MIT`）・`privacyPolicyUrl`（spec.md の「プライバシーポリシーの URL」）・`repository`
   - `.mcp.json`: **必ず** Google Drive の公式の接続を入れる（Anthropic 公式プラグインと同じ書き方）。ほかの道具も `https://` URL だけを書く。鍵は書かない。
     `.mcp.json` の書き込みを止められた場合は、同じ中身を plugin.json の `mcpServers` に書いてよい
     ```json
     { "mcpServers": { "google-drive": { "type": "http", "url": "https://drivemcp.googleapis.com/mcp/v1" } } }
     ```
   - `skills/<動詞-ing などの名前>/SKILL.md`: 1つで始める。`description` は三人称で「何をするか」と「どんな場面で使うか」を、顧客が実際に言いそうな言葉で書く。本文は短く（500行未満）、手順は番号付き、確認して直す工程を入れる。spec.md の「良い結果の基準」を本文に入れる。
     本文の最初の手順に「Google Drive で、仕事に関係する資料（spec.md の『Drive で使う資料』）を探して読む。つながっていなければ貼り付けた資料で進める」を入れる。Drive のファイルを共有・移動・削除する操作は、利用者に確かめてからにする
   - 詳しい手順・書き方の見本は同じスキルの `references/` に分け、本文から直接たどれるようにする（1段まで）。顧客の Drive の資料の本文は写さない（使うたびに Drive から読む）
   - `README.md`: 40語以上。何をするか・使い方・Google Drive への接続のしかた（Claude の接続設定でサインイン）・どんなデータをどこへ送るか・入れ方の1行 `/plugin install <プラグイン名> --marketplace <spec.md の納品先の目録>`・Privacy の項（PRIVACY.md へのリンク）
   - `PRIVACY.md`: 自分では何も集めず送らないこと、Google Drive を読むこと（Google のプライバシーポリシー https://policies.google.com/privacy ）を書く
   - `LICENSE`: MIT の全文
   - `assets/icon.svg`: 簡単な図形の SVG
3. `claude plugin validate <プラグインのフォルダ>` を流し、エラーが無くなるまで直す。
4. progress.md に段階2の完了を書く。
