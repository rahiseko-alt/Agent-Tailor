# 海鵬学園 高校訪問フォロー（kaiho-visit-followup）

学校法人海鵬学園 AIビジネス専門学校の、高校を回る募集担当のためのプラグインです。
高校を訪問したあとに残した箇条書きのメモから、次の2つの下書きを作ります。

1. 上司向けの訪問報告書（次にやることは期日つき、持ち帰りの確認事項つき）
2. 進路指導の先生宛てのお礼メール（学校の説明は Google Drive の統一回答の文言だけを使う）

## 入れかた

- marketplace から入れる（Claude Code）: `/plugin install kaiho-visit-followup --marketplace rahiseko-alt/Dev-agent-01`
- claude.ai では Customize > Plugins > Add > Upload plugin から、渡された zip（kaiho-visit-followup-0.1.0.zip）を選びます。

## 使いかた

訪問メモを貼って「この訪問の報告書とお礼メールを作って」と頼みます。先生の質問と、その場で答えた内容も書いておくと、統一回答との食い違いを報告書の確認事項に挙げます。

## Google Drive への接続

Claude の接続設定（コネクタ）で Google Drive にサインインしてください。つながると、次の資料を自動で探して読みます。

- 「AIビジネス専門学校_高校訪問想定質問_小斉平追記版」
- 「海鵬様＿高校訪問調査リスト＿V1.xlsx」

つながっていないときは、資料を貼り付ければ同じように進みます。

## データの扱い

このプラグインは自分では何も集めず、外部へも送りません。Google Drive の資料を読むだけで、ファイルの共有・移動・削除はしません。訪問メモと下書きは、お使いの Claude の中だけで扱われます。詳しくは PRIVACY.md を見てください。
