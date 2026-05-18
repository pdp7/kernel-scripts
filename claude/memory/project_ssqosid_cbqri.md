---
name: Ssqosid/CBQRI/RQSC patch series status
description: Tracking status of RISC-V QoS resctrl patch series; v4 sent 2026-05-10, v5 prep on b4/ssqosid-cbqri-rqsc with all sashiko-driven fixes folded
type: project
originSessionId: d92ab308-473e-49a2-b5d9-57e308527149
---
## 2026-05-14: v5 prep on b4/ssqosid-cbqri-rqsc

All sashiko v4 fixes are folded in via `git commit --fixup=` +
`git rebase --autosquash`. Tip `f3ba981889e6`. base-commit
`ef5f46b630235b75beec43174348c3d01d6fc49a` (unchanged from v4).
Cover commit carries the v4-to-v5 changelog; `b4 prep --show-info`
reports revision 5, change-id `20260329-ssqosid-cbqri-rqsc-v7-0-b0c788bab48a`.

Same 18-patch shape as v4 send. Per-commit `checkpatch.pl --strict`
clean, `ARCH=riscv LLVM=1 W=1` build clean, sparse clean on
drivers/resctrl/. ./build-matrix.sh in progress as of last check.

Pre-fixes archive at `refs/backup/b4-ssqosid-cbqri-rqsc-pre-fixes`
(`bb7fce761c9d`, the v4-as-sent state). The published v4 thread is
preserved on lore and at remote ref `tt-fustini/ssqosid-cbqri-rqsc-v4`.

P14 (MB_WGHT) had no sashiko LLM review (tool timed out 4x). Manual
follow-up uncovered one real bug: `mweight_cache` kcalloc-zeroed at
probe, first MB_MIN domain init therefore commits Mweight=0 to every
RCID — CBQRI 4.5 hard cap for ~32ms until MB_WGHT init catches up.
Fix folded into P09. See [[project_sashiko_v4_findings]] for full
disposition.

Deferred (documented limitations, not in v5):
- P12 #4 / P15 #3 — mon-only CCs and BW gated on L3 OCCUP, blocked
  on `cbqri_l3_mon_dom` decoupling refactor.
- P13 #1 — group-removal MB_MIN reset, blocked on a new
  `resctrl_arch_*` callback in fs/resctrl.

## 2026-05-10: v4 sent to lists

Series sent: `[PATCH RFC v4 00-18/18] riscv: add Ssqosid and CBQRI
resctrl support`.  Cover message-id:
`20260510-ssqosid-cbqri-rqsc-v7-0-v4-0-eb53831ef683@kernel.org`.
Lists: linux-riscv, linux-kernel, x86, linux-acpi, acpica-devel,
devicetree, linux-rt-devel, linux-doc.  Local mbox copy at
`~/dev/linux/v4-mbox/20260510-...mbx`.

Final shape sent (18 patches, no selftests/docs in this drop):
1. dt-bindings: riscv: Add Ssqosid extension description
2. riscv: detect the Ssqosid extension
3. riscv: add support for srmcfg CSR from Ssqosid extension
4. fs/resctrl: Add resctrl_is_membw() helper
5. fs/resctrl: Add RDT_RESOURCE_MB_MIN and RDT_RESOURCE_MB_WGHT
6. fs/resctrl: Let bandwidth resources default to min_bw at reset
7. riscv_cbqri: Add capacity controller probe and allocation device ops
8. riscv_cbqri: Add capacity controller monitoring device ops
9. riscv_cbqri: Add bandwidth controller probe and allocation device ops
10. riscv_cbqri: Add bandwidth controller monitoring device ops
11. riscv_cbqri: resctrl: Add cache allocation via capacity block mask
12. riscv_cbqri: resctrl: Add L3 cache occupancy monitoring
13. riscv_cbqri: resctrl: Add MB_MIN bandwidth allocation via Rbwb
14. riscv_cbqri: resctrl: Add MB_WGHT bandwidth allocation via Mweight
15. riscv_cbqri: resctrl: Add mbm_total_bytes bandwidth monitoring
16. ACPI: RISC-V: Parse RISC-V Quality of Service Controller (RQSC) table
17. ACPI: RISC-V: Add support for RISC-V Quality of Service Controller (RQSC)
18. riscv: enable resctrl filesystem for Ssqosid

Two-file driver split kept: `cbqri_devices.c` (P7-10, device ops) +
`cbqri_resctrl.c` (P11-15, resctrl integration).  base-commit:
`ef5f46b630235b75beec43174348c3d01d6fc49a`.  Diffstat: 27 files,
3326 insertions(+), 9 deletions(-).  No Documentation/ or selftests
patches in this drop (the 22-patch candidate from 2026-05-07 dropped
those before send).

## 2026-05-07: mpam-style restructure moved to b4 branch as v4

`b4/ssqosid-cbqri-rqsc` reset to `dfustini/cbqri-mpam-style` HEAD
(`fb0ca3777dab`). Prior tip preserved at tag
`backup/b4-ssqosid-cbqri-rqsc-pre-mpam-restructure` (`0835b5956dd9`,
the post-fold 17-patch v4 candidate from 2026-05-06).

### New series shape (cover + 22 patches)
1 cover (`riscv: add Ssqosid and CBQRI resctrl support` -
`f15c96b33bdd`)
- 01-03: dt-bindings + Ssqosid ISA detection + srmcfg CSR
- 04-06: fs/resctrl helpers (`resctrl_is_membw`, MB_MIN/MB_WGHT
  resources, `default_at_min` reset)
- 07-10: CBQRI device ops in `cbqri_devices.c` - capacity probe+alloc,
  capacity mon, bandwidth probe+alloc, bandwidth mon (4 patches, no
  `riscv_cbqri:` resctrl prefix)
- 11-15: CBQRI resctrl integration in `cbqri_resctrl.c` - cache alloc,
  L3 cache mon, MB_MIN bw alloc (Rbwb), MB_WGHT bw alloc (Mweight),
  mbm_total_bytes (5 patches, all `riscv_cbqri: resctrl:` prefix)
- 16-17: ACPI RQSC parse + init
- 18: enable resctrl filesystem for Ssqosid
- 19: Documentation describe MB_MIN/MB_WGHT
- 20-22: selftests/resctrl

Two-file driver split (`cbqri_devices.c` + `cbqri_resctrl.c`) is the
defining structural change vs. the prior 17-patch shape, which had a
single `cbqri_resctrl.c` reached via 5 feature commits on top of a
scaffolding commit. Cover letter on `f15c96b33bdd` already updated to
match (b4 prep tracker still v4, change-id unchanged).

## 2026-05-06: comment-punctuation polish folded into originating patches

Series tip: `cc54b226f062`.  P11 (BW mon) and P12 (Parse RQSC) were
re-touching comments introduced by P07-P11 to swap mid-sentence `;`
for `.` (or `,`).  All 50 such churn pairs (4 in P11, 46 in P12) were
folded back into the patches that introduced each comment, using a
`git rebase --exec` driving a per-commit text-replace script keyed by
commit subject.  Tree at HEAD is byte-identical to pre-fold backup
tag `backup-pre-punct-fold` (1911489ffef2).

Effect on P12 cbqri_resctrl.c: 112 lines changed -> 24 lines (just
the new `riscv_cbqri_unregister_last()` rollback helper, no comment
edits).  Effect on P11: 264 -> 264 lines but 11 deletions -> 7 (comment
churn gone, brace expansion for the 2-stmt loop body kept).

The legitimate `for (i = 0; i < max_rmid; i++) {` brace expansion in P11
is preserved (needed because P11 grows the loop body to two statements).
Each amended commit is checkpatch --strict clean and W=1 LLVM riscv build
succeeds at HEAD.

## 2026-05-05: fold + Sashiko cleanups landed on `b4/ssqosid-cbqri-rqsc`

Series tip: `38417385b193`.  Two passes of work landed today:

**Pass 1: controller-registration refactor folded.**
The mbm patch's rework (`OLD qos_register_*` family removed, `NEW
qos_create_ctrl_domain / qos_attach_cpu_to_*` family added) has been
folded back into the three earlier cbqri feature patches, so each patch
presents its scaffolding in final form.  After this pass, tree at HEAD
was byte-identical to original `e8b91d9279ac` (tree
`31bf0ca33314e08284d5b593e71165e188b56afc`).

**Pass 2: Sashiko #45 cleanups.**
- B (Kconfig help text wording)
- D (mutex_init moved from cbqri_probe_controller to register_controller)
- E (cbqri_wait_busy_flag forward decl dropped)
- F (wasted ioread64 in cbqri_cc_alloc_op dropped)
- Plus per-commit bisectability fix: dropped orphan
  `acpi_pptt_get_cache_size_from_id()` call from scaffolding's
  register_controller (function was never defined in v4 since v3's
  PPTT helper patch was dropped).

After pass 2, tree at HEAD intentionally differs from original
`e8b91d9279ac` (the cleanups are real code changes).

Diff stats per cbqri feature patch (vs scaffolding base / previous):
- cache-alloc (`3d1063059eb4`): +1116 / -59  (was +949 / -18)
- cache-mon   (`252dd1822937`): +419  / -16  (was +380 / -18)
- bw-alloc    (`7a8d87eb1c88`): +624  / -22  (was +619 / -20)
- bw-mon      (`0e185c0255bb`): +412  / -10  (was +989 / -270)

Patch 4 deletions dropped from 270 to 10; the reworked-then-deleted
scaffolding never appears in patches 1-3 to begin with.

build-matrix.sh: 5/6 PASS (current, x86_64-defconfig, arm64-defconfig,
rv64-defconfig, rv64-allnoconfig).  rv64-randconfig FAIL is unrelated
unused-but-set-variable -Werror in `drivers/rapidio/rio_cm.c` and
`drivers/leds/leds-pca9532.c`; CBQRI compiled clean in randconfig.
checkpatch --strict and sparse clean per cbqri patch.

Worktree at `.worktrees/cbqri-resplit` retains the construction state
on branch `cbqri-resplit`.

## 2026-04-29 (afternoon): default_at_min swap on `b4/ssqosid-cbqri-rqsc-fixups`

Per Drew's request to minimise the fs/resctrl footprint, replaced
`u32 resctrl_membw::default_ctrl` (with magic-zero sentinel) with
`bool resctrl_membw::default_at_min`.  Effect:

- `include/linux/resctrl.h`: same shape, bool not u32; doc updated
- `arch/x86/kernel/cpu/resctrl/core.c`: **2 lines deleted** (no need
  to populate the field; default_at_min=false → fallback returns
  @max_bw, preserving existing MBA/SMBA behaviour)
- `drivers/resctrl/cbqri_resctrl.c`: 1 line at MB_MIN setup
  (`res->membw.default_at_min = true;`) plus 2 comment updates
- `fs/resctrl/`: untouched beyond what was already in P04

Amended into P04 (`fs/resctrl: add RDT_RESOURCE_MB_MIN and
RDT_RESOURCE_MB_WGHT`) and P09 (`RISC-V: QoS: add CBQRI bandwidth
allocation support`).  P04 commit message rewritten to drop the
"populates @default_ctrl for x86" paragraph.

QEMU 1bc test: 41/0/1 buildroot + 3/0 kselftest = 44/0/1 (matches
baseline; sum-overflow rejection still fires for invalid writes).
W=1 LLVM riscv build clean.  Backup tag at
`backup-pre-default-at-min`.

Trade-off vs `u32 default_ctrl`: less general — a hypothetical future
driver wanting a default that's neither min nor max would need to
widen it.  No such driver today.

## 2026-04-29: v4 candidate on `b4/ssqosid-cbqri-rqsc`

`b4/ssqosid-cbqri-rqsc` (in `~/dev/linux`) holds the v4 candidate:
17 patches + b4 cover.  Pre-split monolithic state (HEAD `463a00d1fe31`)
preserved in tag `backup-b4-pre-split`.  `b4 prep --check` reports 17/0/0
(success/warning/error).  Cover letter rewritten 2026-04-28 to v4 form
(Series organisation / Key design decisions / Open issues / grouped
Changelog with v3+v2 preserved verbatim).  `b4 send -o /tmp/v4-out
--no-sign` generates 18 well-formed .eml messages.  All 17 commits are
`checkpatch --strict` clean (0/0/0).

### Series structure (17 patches + cover)
```
01: dt-bindings: riscv: Add Ssqosid extension description
02: RISC-V: Detect the Ssqosid extension
03: RISC-V: Add support for srmcfg CSR from Ssqosid extension
04: fs/resctrl: add RDT_RESOURCE_MB_MIN and RDT_RESOURCE_MB_WGHT
05: ACPI: PPTT: Add acpi_pptt_get_cache_size_from_id helper
06: RISC-V: QoS: add CBQRI driver scaffolding
07: RISC-V: QoS: add CBQRI cache allocation support
08: RISC-V: QoS: add CBQRI cache occupancy monitoring
09: RISC-V: QoS: add CBQRI bandwidth allocation support
10: RISC-V: QoS: add CBQRI bandwidth monitoring (MBM_TOTAL)
11: ACPI: RISC-V: Parse RQSC table
12: ACPI: RISC-V: Add support for RQSC
13: RISC-V: QoS: enable resctrl filesystem for Ssqosid
14: Documentation: resctrl: describe MB_MIN and MB_WGHT schemata
15: selftests/resctrl: look up domain ID from schemata for non-cache resources
16: selftests/resctrl: add MB_MIN and MB_WGHT interface tests
17: selftests/resctrl: add CBQRI MBM_TOTAL interface test
```

### Naming
- Kernel enum: `RDT_RESOURCE_MB_MIN`, `RDT_RESOURCE_MB_WGHT`
- User-visible schema: `MB_MIN`, `MB_WGHT` (fits 8-byte `struct resctrl_schema::name`)
- "WGHT" matches CBQRI's `Mweight` field; MPAM's MBW_MIN/MBW_PROP register
  fields encode the same semantics — cross-arch correspondence is in
  prose, not name parallelism.

### Driver split (feature axis with alloc/mon sub-split)
- Per-feature locality: each P_N for N ∈ {7,8,9,10} adds its own
  `struct cbqri_controller` field, hardware-caps struct, and CBQRI
  spec #defines into `cbqri_internal.h` rather than declaring them
  upfront in P6.  P9 owns BC alloc + `rbwb_cache`; P10 owns BC mon +
  `mbm_total_states` + `struct cbqri_bc_mon_state`.  cbqri_internal.h
  diff-stat per commit: P6=90 P7=49 P8=12,-5 P9=46 P10=38,-5.
- P1 scaffolding (06): headers, Kconfig, Makefile, MAINTAINERS, all
  resctrl_arch_* with safe stubs and full kerneldoc on the 11
  prototypes in `arch/riscv/include/asm/resctrl.h`, late_initcall,
  register_controller, no controller types supported in probe.
  Selects ARCH_HAS_CPU_RESCTRL on RISCV_ISA_SSQOSID so
  `<linux/resctrl.h>` pulls in the prototypes from `<asm/resctrl.h>`.
- P2 cache alloc (07): cap HW + L2/L3 schemata + pick_caches +
  register_cap_controller (no mon).
- P3 cache mon (08): cc_mon_op + qos_init_mon_counters + L3 mon_domain +
  OCCUP_EVENT.
- P4 bw alloc (09): bw HW + MB_MIN/MB_WGHT schemata + pick_bw_alloc +
  register_bw_controller.
- P5 bw mon (10): bc_mon_op + MBM_TOTAL + paired_bc + find_only_mon_bc
  + pick_counters + qos_init_bc_mon_counters.

Each patch is W=1 clean (verified per-commit) and self-contained (no
`__maybe_unused`).

### Bug fixes folded into the series during v4 prep
- `drivers/acpi/riscv/rqsc.h`: added `__packed` on three on-wire structs
  (resource subtable was being mis-sized 24 vs 20 bytes, parser rejected
  every controller).
- `include/linux/resctrl.h::resctrl_get_default_ctrl()`: restored
  `r->membw.default_ctrl ? : r->membw.max_bw` fallback so MPAM MBA (which
  doesn't populate default_ctrl) doesn't regress to MB=0 on every new
  group.
- selftests bisection break: `&cbqri_mbm_test` reference moved from the
  bw-alloc-test commit to the MBM-test commit (where the symbol is
  defined).
- ACPI Add-support commit was lost during an earlier rebase (init.c
  changes silently merged into FS-enable commit); split back out so the
  series is `Parse → Add support → FS-enable`.

### How to test
- Build: `./llvm.sh` (LLVM=1 W=1)
- QEMU: `~/dev/qemu/run-acpi-sock-1bc.sh` (1-BC SoC).  Auto-runs
  `/root/test-resctrl.sh` which now also invokes `/root/resctrl_tests`
  (the cross-compiled kernel selftest) for the CBQRI subgroup.
- Test counts: 41/0/1 buildroot script + 3/0 kselftest = 44/0/1 total.

### Pre-existing kreview note
`resctrl_arch_reset_rmid_all()` uses hw_res->max_mcid as loop bound
(from first L3 CC controller). If a second controller has fewer MCIDs,
loop issues ops to invalid indices. Low severity — requires mismatched
multi-controller config. qos_init_cache_resource mismatch check doesn't
validate mcid_count.  Not addressed in v4.

## v3 sent
Lore: 20260414-ssqosid-cbqri-rqsc-v7-0-v3-0-b3b2e7e9847a@kernel.org
