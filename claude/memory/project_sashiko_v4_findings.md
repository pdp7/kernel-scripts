---
name: sashiko-v4-review-findings
description: "Sashiko-bot findings against v4 of Ssqosid/CBQRI/RQSC sent 2026-05-10; all real-meaningful findings folded into b4/ssqosid-cbqri-rqsc except 3 documented deferrals"
metadata:
  node_type: memory
  type: project
  originSessionId: 369cbf1c-f4dc-48d1-a4fb-5ef5b2598277
---

## Source

Series: `[PATCH RFC v4 00-18/18] riscv: add Ssqosid and CBQRI resctrl support`
Cover msg-id: `20260510-ssqosid-cbqri-rqsc-v7-0-v4-0-eb53831ef683@kernel.org`
Web report: `https://sashiko.dev/#/patchset/<cover-msgid>`. API endpoint
`https://sashiko.dev/api/patchset?id=<msgid>` returns full per-patch
reviews, including the 8 patches whose email send was Skipped.

Local mbox: `v4-mbox/20260510-...mbx`. Reply drafts: `v5-replies/`.
Full verdict table with file:line citations and fix descriptions in
`docs/sashiko-v4-findings-handoff.md`.

## Coverage

Sashiko reviewed all 18 patches, but only emailed the 10 with findings:
P03, P07, P08, P09, P11, P12, P13, P15, P16, P18 (P15/P16/P18 arrived
later than the initial batch).

Email-Skipped patches: P01, P02, P04, P05, P06, P10, P17 had concerns
raised in intermediate stages but dismissed (final verdict "No issues
found"). **P14 had no review at all — sashiko's tool timed out four
times in a row.**

Manual follow-up done on P10 and P14 (2026-05-14): P10's dismissed
concerns either re-flag P15 #1/#2 (already fixed) or are spec false
positives. P14 had one real bug (mweight_cache kcalloc-zeroed → first
MB_MIN init commits Mweight=0 → CBQRI 4.5 hard cap), fixed in the
P09 commit.

## Final disposition (post-fix)

Branch: `b4/ssqosid-cbqri-rqsc` (the v5-prep branch). Tip
`f3ba981889e6` as of 2026-05-14. Pre-fixes backup at
`refs/backup/b4-ssqosid-cbqri-rqsc-pre-fixes` (`bb7fce761c9d`).

48 total findings across 10 reviewed patches:

- **Real meaningful (24, all addressed)**: P03 #1/2/3, P07 #1/2/3,
  P08 #2(EVT_ID)/3, P09 #2/3/4/5, P12 #1/2/3/6, P13 #2, P15 #1/2/4,
  P16 #2/4, P18 #1. Plus P09 #1 closed via the cache refactor.
- **Plus 1 manual-review finding**: mweight_cache pre-seed for
  CBQRI 4.5 hard-cap window (folded into P09).
- **Real-but-mild, intentional design choice (5)**: P07 #4, P11 #3,
  P11 #6, P12 #7, P09 #1.
- **Deferred (3, documented limitations)**: P12 #4 / P15 #3 (mon-only
  CCs and BW gated on L3 OCCUP, blocked on `cbqri_l3_mon_dom`
  decoupling), P13 #1 (group-removal MB_MIN reset, blocked on new
  `resctrl_arch_*` callback).
- **False positives (13)**: P03 #5, P07 #5, P08 #1, P11 #2/4/5/7/8,
  P12 #8, P13 #3, P16 #1/3/5.

## Cross-cutting fixes applied

- `cbqri_probe_feature()` defensive clear of OP/AT/RCID/EVT_ID closes
  P07 #2, P08 #2 (EVT_ID), P08 #3, P09 #4.
- `cbqri_apply_bc_field()` cache-driven staging closes P09 #2 and
  the timing aspect of P09 #1; the mweight seed addresses the
  P14 follow-up.
- `cancel_delayed_work_sync` -> `cancel_delayed_work` closes P12 #1
  and P12 #2.

Related: [[project_ssqosid_cbqri]], [[project_v4_reinette_review]],
[[project_sashiko_45_pending_findings]], [[reference_sashiko_local]].
