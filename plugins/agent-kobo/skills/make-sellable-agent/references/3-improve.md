# 段階3 磨く

目的: 作ったプラグインが、プラグイン無しの Claude より良い結果を出すかを数字で確かめ、出なければ直す。

## 始める前に

1. `claude --version` を流す。`claude plugin eval --help` が使えなければ、Claude Code を新しくするよう案内して段階4へ進む（progress.md に「評価できず」と書く）。
2. 利用者に一言: 「出来を測るため、Claude を何回か動かします。ご契約の利用枠を少し使います。」

## 評価を書く（spec.md の実例3件から）

プラグインのフォルダの `evals/<実例の短い名前>/` に、1件につき次の3ファイルを作る。

`prompt.md`（顧客が実際に打ちそうな言い方。スキル名は書かない。必要な入力は本文に貼る）:

```markdown
---
max_turns: 10
allowed_tools: [Read, Write, Glob, Grep, Skill]
---

<実例の入力と依頼>
```

`graders/skill-fired.md`（プラグインのスキルが使われたか）:

```markdown
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?<スキル名>"'
---
```

`graders/result.md`（結果の確認。**初回は費用のかからない regex で書く**。「期待する出力の要点」に必ず出る語句を選ぶ）:

```markdown
---
type: regex
pattern: '<期待する出力に必ず含まれる語句>'
flags: i
---
```

## 測る

```
claude plugin eval <プラグインのフォルダ> --trust-plugin --runs 2
```

- `Δ`（プラグイン有りの点 − 無しの点）を見る。全件で `Δ` が 0 より大きく、`skill-fired` が通っていれば合格。
- 合格しなければ、点が低い件の `NOTES` を読んで、スキルの `description` か本文を直し、もう一度測る。**直して測るのは最大2回**。
- 最後に1回だけ、`graders/result.md` を `type: llm`（本文に PASS／FAIL の条件を書く）に替えて `--runs 1` で測る。

## 書くもの

progress.md に、件ごとの「有り／無し／Δ」と、直した内容を1行ずつ書く。利用者には「プラグイン有りで◯点、無しで◯点」を平易に伝える。
