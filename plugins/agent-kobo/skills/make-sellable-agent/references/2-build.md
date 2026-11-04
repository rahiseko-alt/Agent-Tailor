# 段階2 作る

目的: spec.md から、顧客に渡せるプラグインを作る。利用者には質問しない。

## 手順

1. 公式の作り方を読み込む: `plugin-dev:plugin-structure` と `plugin-dev:skill-development` の2つのスキルを呼ぶ。
   つなぐ道具がある場合だけ `plugin-dev:mcp-integration` も呼ぶ。
   `/plugin-dev:create-plugin` は呼ばない（質問が二重になり、後半の段階と重なるため）。
   plugin-dev が入っていなければ、利用者に次の1行を打つよう案内して止まる:
   `/plugin install plugin-dev@claude-plugins-official`
2. `kobo/<…>/<プラグイン名>/` に次を作る:
   - `.claude-plugin/plugin.json`: `name`・`displayName`・`version`（`0.1.0`）・`description`・`author`・`license`（`MIT`）
   - `skills/<動詞-ing などの名前>/SKILL.md`: 1つで始める。`description` は三人称で「何をするか」と「どんな場面で使うか」を、顧客が実際に言いそうな言葉で書く。本文は短く（500行未満）、手順は番号付き、確認して直す工程を入れる。spec.md の「良い結果の基準」を本文に入れる
   - 詳しい資料・見本は同じスキルの `references/` に分け、本文から直接たどれるようにする（1段まで）
   - つなぐ道具がある場合: `.mcp.json` に接続先の `https://` URL だけを書く。鍵は書かない
   - `README.md`: 40語以上。何をするか・使い方・どんなデータをどこへ送るか（送らないならそう書く）
   - `LICENSE`: MIT の全文
   - `assets/icon.svg`: 簡単な図形の SVG
3. `claude plugin validate <プラグインのフォルダ>` を流し、エラーが無くなるまで直す。
4. progress.md に段階2の完了を書く。
