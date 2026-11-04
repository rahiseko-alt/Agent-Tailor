# 段階4 合格確認と納品形

目的: 申請前の検査に通し、顧客に渡せる形にまとめる。利用者には質問しない。

## 検査（両方が合格するまで、直して流し直す）

1. Anthropic 公式の検査（説明書・利用許諾・名前・書式・余計なファイル・プライバシーポリシーなど）:
   ```
   claude plugin validate --profile directory --strict <プラグインのフォルダ>
   ```
2. 追加の検査（SKILL.md に書いた check-extra.sh。`bin/`、大きすぎるファイル、中を確かめられない種類のファイル、版を決めていないパッケージ起動、Google Drive の接続）。

- 「marketplace から入れる1行が無い」と言われたら、README に `/plugin install <プラグイン名> --marketplace <spec.md の納品先の目録>` を書く。
- 「プライバシーポリシーの URL が無い」と言われたら、plugin.json の `privacyPolicyUrl` に spec.md の URL を書く。

## 納品形

1. 版番号を確かめる（plugin.json の `version`）。置き場所が git なら `claude plugin tag --dry-run` で印の名前を確かめ、利用者が望めば `claude plugin tag --push`。
2. claude.ai に上げる圧縮ファイルを作る。プラグインのフォルダ1つを最上位に入れ、**`evals/` は丸ごと入れない**（顧客の実例が入っているため）:
   ```
   cd tailor/<…> && zip -r <プラグイン名>-<版>.zip <プラグイン名> -x '*/evals/*' '*/.DS_Store'
   ```
   `zip` が無い環境（Windows など）では、エクスプローラーの「圧縮（zip 形式）フォルダーに送る」を案内する。その場合は先に `evals/` を別の場所へ移す。
3. README に「claude.ai では Customize > Plugins > Add > Upload plugin からこの zip を選ぶ」と書いてあるか確かめる。

## 利用者への報告（平易に、この形で）

```
できたもの: <プラグイン名>（<何をするか>）
出来: プラグイン有りで◯点、無しで◯点（評価できなかったときは「評価できず: <理由>」）
改善しきれなかった点: <無し／件名と理由>
検査: 公式の検査と追加の検査に合格
渡すもの: tailor/<…>/<プラグイン名>/ と <プラグイン名>-<版>.zip
```

progress.md に段階4の完了と「次にやること: なし（納品済み）」を書く。
