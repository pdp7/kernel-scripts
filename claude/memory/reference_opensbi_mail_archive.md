---
name: OpenSBI mail archive (local)
description: Local mirror of opensbi mailing list archives at ~/opensbi-mail-archive/ — monthly mbox-style .txt files for searching list traffic without web access
type: reference
originSessionId: c5a707a2-04ef-43ed-8262-1cb8676ed3d6
---
`~/opensbi-mail-archive/` holds monthly OpenSBI list archives as plain mbox-style `.txt` files (and `.txt.gz` siblings). Coverage as of 2026-05-09: `2026-January.txt` through `2026-May.txt` (~526 messages).

How to use:
- Grep across files for symbols/keywords (e.g. `grep -in -E "(ssqosid|cbqri|rqsc)" 2026-*.txt`).
- Subjects: `grep -h "^Subject:" 2026-*.txt | sort -u`.
- Message bodies follow the standard `From <addr>  <date>` separator; threading via `In-Reply-To:`/`References:` headers.

Useful when web fetches against lists.riscv.org or lore-style archives are unavailable. Grep patterns in semcode are case-insensitive, but plain `grep` here needs `-i`.
