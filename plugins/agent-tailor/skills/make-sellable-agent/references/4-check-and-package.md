# 段階4 合格確認と納品形

目的: 申請前の検査に通し、顧客に渡せる形にまとめる。

## 検査（両方が合格するまで、直して流し直す）

```
claude plugin validate --profile directory --strict <プラグインのフォルダ>
sh ${CLAUDE_SKILL_DIR}/scripts/check-extra.sh <プラグインのフォルダ>
```

- 1つ目は Anthropic 公式の検査（説明書・利用許諾・名前・書式・余計なファイルなど）。
- 2つ目は公式が見ない項目だけの検査（`bin/`、大きすぎるファイル、中を確かめられない種類のファイル、版を決めていないパッケージ起動、Google Drive の接続）。
- README に「marketplace から入れる1行が無い」と言われたら、納品先が決まっていなければ `/plugin install <名前> --marketplace <持ち主>/<置き場所>` の形で、置き場所の部分を空けずに利用者の GitHub の置き場所名で書く。決まっていなければ利用者に1つだけ聞いてよい。

## 納品形

1. 版番号を確かめる（plugin.json の `version`）。置き場所が git なら `claude plugin tag --dry-run` で印の名前を確かめ、利用者が望めば `claude plugin tag --push`。
2. claude.ai に上げる圧縮ファイルを作る（プラグインのフォルダ1つを最上位に入れる。`evals/results/` は入れない）:
   ```
   cd tailor/<…> && zip -r <プラグイン名>-<版>.zip <プラグイン名> -x '*/evals/results/*' '*/.DS_Store'
   ```
3. README に「claude.ai では Customize > Plugins > Add > Upload plugin からこの zip を選ぶ」と書いてあるか確かめる。

## 利用者への報告（平易に、この形で）

```
できたもの: <プラグイン名>（<何をするか>）
出来: プラグイン有りで◯点、無しで◯点
検査: 公式の検査と追加の検査に合格
渡すもの: tailor/<…>/<プラグイン名>/ と <プラグイン名>-<版>.zip
```

progress.md に段階4の完了と「次にやること: なし（納品済み）」を書く。
