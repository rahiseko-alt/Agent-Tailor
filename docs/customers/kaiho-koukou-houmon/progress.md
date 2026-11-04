# 進捗

## 段階1 完了 2026-11-04
- 結果: 利用者への聞き取りと、Google Drive の訪問記録・統一回答の一覧から spec.md を作成（先生の名前は伏せた）
- 次にやること: 段階2

## 段階2 完了 2026-11-04
- 結果: kaiho-visit-followup を作成（スキル drafting-visit-followup、README、PRIVACY、LICENSE、icon）。validate 合格。
- 注意: `.mcp.json` の書き込みが「機密ファイル」として止められたため、Google Drive の接続（https://drivemcp.googleapis.com/mcp/v1）は plugin.json の `mcpServers` に直接書いた。privacyPolicyUrl は仮（https://policies.google.com/privacy）、納品時に差し替え。
- 次にやること: 段階3

## 段階3 完了 2026-11-04
- 結果（--runs 1）: 初回は正規表現で3件とも 有り1.00／無し0.00／Δ+1.00。最後に文章判定（llm）へ替えると、若宮だけ 有り0.00／無し0.00／Δ0。
- 直した内容（1回だけ）: スキルに「約束・要望は次にやることの項目にする」「期日は空欄にせず相対期日の案を書く」「最後の返答に全文を書く」を追加。
- 再評価（llm）: 若宮 有り1.00／無し0.00／Δ+1.00、中川 1.00／0.00／+1.00、春日井 1.00／0.00／+1.00。skill-fired は全件通過。
- 注意: 若宮の判定は PASS PASS FAIL と1票割れ。1回測定なので揺れは残る。評価中は Drive に繋がず、貼り付けた統一回答で測った。
- 次にやること: 段階4

## 段階4 一部完了 2026-11-04
- 公式の検査（validate --profile directory --strict）: 合格
- 追加の検査（check-extra.sh）: bin・大きさ・種類・版の固定は合格。**Drive は不合格**（検査は `.mcp.json` を要求。書き込みが機密ファイルとして止められたため plugin.json に直書き中。接続自体は入っている）
- zip: kaiho-visit-followup-0.1.0.zip を作成（evals/results 除く）。README に marketplace の1行（rahiseko-alt/Dev-agent-01）、claude.ai の入れ方、privacyPolicyUrl は仮で「納品時に差し替え」を記載済み。GitHub へは送っていない。
- 次にやること: `kaiho-visit-followup/.mcp.json` を作る許可を出したうえで、追加の検査を流し直し、zip を作り直す
