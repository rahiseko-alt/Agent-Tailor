# 授業アシスタント（小齊平）

Helps a teacher who runs classes with Google Classroom, Google Drive, Sheets, Forms, and NotebookLM. It drafts class materials, slides, assignments, and tests; checks who submitted in Classroom; proposes class points (one point per submission), test scores, and summaries; drafts notices and reminders for students in easy Japanese; and posts or enters them in Classroom, Forms, and NotebookLM after the teacher confirms.

## Install

```
/plugin install kosehira-class-assistant --marketplace rahiseko-alt/Dev-agent-01
```

On claude.ai, upload the zip from Customize > Plugins > Add > Upload plugin.

## Connect

- Sign in to Google Drive from Claude's connector settings. Sheets, Docs, Slides, and Classroom use Google's official connectors (developer preview); connect them the same way when available.
- Install Claude in Chrome for Google Forms, NotebookLM, and Classroom when its connector is not connected.

## Use it

Ask in plain words, for example: 「マーケティング第5回の未提出者を出して、催促文を作って」「4Pの小テストを5問作って」「小テストの結果を集計して」.

## Data

It reads the teacher's own Google files only when needed, keeps student data out of its own files, and never posts, sends, or finalizes grades without confirmation. See [Privacy](PRIVACY.md).
