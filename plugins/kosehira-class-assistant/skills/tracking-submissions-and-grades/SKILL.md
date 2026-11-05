---
name: tracking-submissions-and-grades
description: Checks who submitted each assignment in Google Classroom, proposes class points (one point per submission) and test scores, and summarizes results into the grade sheet as a proposal for the teacher to confirm. Use when the teacher asks about 未提出, 提出状況, 授業点, 採点, 成績, テストの結果, 集計, or the grade sheet, including when the teacher pastes submission lists or quiz answers to be totaled.
---

# 提出と成績

先生が確定するまで、成績表には書き込まない。出すのはいつも「案」。

## 手順

1. 資料を読む: Google Drive で成績表「コセヒラ授業2026後期成績」と、対象の科目・回を探して読む。
   提出状況は Classroom の接続（google-classroom）で読む。つながっていなければ Claude in Chrome で
   Classroom の「課題」→「提出物」を開いて読む。どちらも無理なら、先生に提出状況を貼ってもらう。
2. 照らし合わせる: Classroom の提出状況と成績表の生徒一覧を、学籍番号（S001 など）で突き合わせる。
   片方にしかいない生徒は「要確認」として別に挙げる。
3. 授業点の案: 原則、Classroom での課題提出1回につき1点、未提出は0点。先生が別の配点を言ったときはそれに従う。
4. テストの採点案: フォームの回答シート（スプレッドシート）を読み、選択式は正解と照らして採点する。
   記述式は採点案と理由を1行ずつ付け、確定は先生に任せる。
5. 集計: 平均点、「正答率の低い問題」（下位3問。この見出しで書く）、要フォローの生徒（未提出が続く・点が低い）を出す。
6. 出す形は references/formats.md のとおり。催促文が頼まれたら writing-student-notices の決まりで書く。最後に「成績表に書き込みますか」と確かめ、
   了承されたら該当の列にだけ書き込む。書き込んだ範囲を報告する。

## 守ること

- 生徒の名前・メールは返答の中だけで使い、ファイルには残さない。
- 成績表の既存の値を上書きする前は、元の値と新しい値を並べて見せて確かめる。
