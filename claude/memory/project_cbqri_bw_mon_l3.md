---
name: CBQRI BW monitoring via L3 scope (experimental)
description: Throwaway branch cbqri-bw-mon-l3-scope that adds CBQRI BC bandwidth monitoring as QOS_L3_MBM_TOTAL_EVENT_ID, MPAM-style
type: project
originSessionId: f5fb39a3-85eb-4335-bd18-1156ada1469e
---
Branches: `cbqri-bw-mon-l3-scope` AND `cbqri-bw-schemata` (user fast-forward-merged the four BW-mon commits into the schemata branch on 2026-04-23). Both worktrees point at the same tip commit `e047b0116eb4`.

Experimental, not for upstream as-is. Plumbs CBQRI bandwidth controller monitoring into the existing L3 monitoring domain by mimicking MPAM's "memory class wears L3's clothes" trick. Commits (4):

1. `0025b8b5046a` internal.h: BC MON register offsets + event IDs + bc_mon_ctr_val layout.
2. `1808bd76ac37` qos_resctrl.c: `cbqri_bc_mon_op()` helper + BC mon probe in `cbqri_probe_bc()`.
3. `42f2f4ac8688` qos_resctrl.c: `bc_matches_l3_domain()` + `cbqri_find_bc_for_l3_domain()` helpers (permissive topology check).
4. `e047b0116eb4` qos_resctrl.c: end-to-end wiring — enable `QOS_L3_MBM_TOTAL_EVENT_ID` when BC pairs with L3, `qos_init_bc_mon_counters()`, rmid_read/reset_rmid switch, reset_rmid_all extension.

**Why:** Reinette's "Part 3" scope-as-schema-property idea hasn't landed; CBQRI BC is at memory-controller scope but resctrl only supports L2_CACHE/L3_CACHE/L3_NODE/PACKAGE. Same constraint MPAM MB hits. This branch proves the MPAM workaround also fits CBQRI.

**How to apply:** Useful as a prototype for reviewer discussion and as a baseline for the follow-up BW-monitoring series mentioned in `cover-letter-v4.txt:167-172`. Do NOT fold into the main cbqri-bw-schemata series without reviewer buy-in — it's a deliberate ABI hack until per-control scopes land.

Known gaps, flagged in commit 4 message:
- No overflow worker; bc_mon_ctr_val is 62-bit CTR, assumes no wrap.
- Only MBM_TOTAL, not MBM_LOCAL (semantic ambiguity at memory-controller scope).
- Topology check is permissive (any CPU overlap with an L3), not MPAM's strict single-L3/no-L4.
- QEMU at `~/dev/qemu` emulates BC mon registers but never advances the counter — reads return INVALID+CTR=0. Proves plumbing, not correctness.

Builds clean with `./llvm.sh` (LLVM=1 W=1); no new warnings.
