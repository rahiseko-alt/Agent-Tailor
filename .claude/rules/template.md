---
paths:
  - ".template/**"
---

# ひな型そのものを直しているとき

While working on the template itself (`.template/` exists), the template's own glossary and ADRs live in `.template/CONTEXT.md` and `.template/docs/adr/` instead, so they are not copied into new projects (`.template/` is removed in a copy on its first session). Read and enforce them exactly as you would the root ones.

`.template/` がある（＝ひな型そのものを直している）ときは、ひな型自身の用語集 `.template/CONTEXT.md` と
   決めた理由 `.template/docs/adr/` も、ルールの4と6の「`CONTEXT.md`」「`docs/adr/`」と同じ扱いで読み、
   確認役に貼り付ける。ひな型の記録は複製先に写さないためにそこへ分けてあるだけで、効力は同じ。
