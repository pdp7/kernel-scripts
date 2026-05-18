---
name: Sashiko #45 — review findings status
description: Review findings from sashiko #45 on the cbqri series; status updated 2026-05-05 after applying B/D/E/F fixes via interactive rebase
type: project
originSessionId: 5a3e1061-c3b3-4e77-a54c-e4b2e0cd5373
---
## 2026-05-05: Sashiko #45 cleanup landed

The four held-pending cleanup items (B/D/E/F) have been applied via an
interactive rebase on `b4/ssqosid-cbqri-rqsc` (tip now `e853fbdedb79`):

- **B (Kconfig help text)** — scaffolding patch.  "Selected automatically
  by RISCV_ISA_SSQOSID" is now "Selected automatically when
  RISCV_ISA_SSQOSID and RESCTRL_FS are both enabled. RISCV_ISA_SSQOSID
  provides the srmcfg CSR ..."
- **D (mutex_init in register_controller)** — moved from
  `cbqri_probe_controller()` (cache-alloc patch) to
  `riscv_cbqri_register_controller()` (scaffolding patch), immediately
  after the `kzalloc()`.  Eliminates the "lock not initialised at
  alloc time" defensive concern.
- **E (forward decl unused)** — cache-alloc patch.  Dropped the
  forward declaration of `cbqri_wait_busy_flag()`; only `cbqri_set_cbm`
  sat between decl and definition and it doesn't call wait_busy_flag.
- **F (wasted ioread64)** — cache-alloc patch.  Dropped the initial
  `reg = ioread64(...)` in `cbqri_cc_alloc_op()` whose value was
  unconditionally overwritten by `cbqri_wait_busy_flag()` on the
  first poll iteration.

W=1 LLVM riscv build clean for the full series; checkpatch --strict
on amended scaffolding (911 lines) and amended cache-alloc (1331 lines)
both 0/0/0.

### Resolved earlier
- #7-A (deps on RESCTRL_FS): ✓ scaffolding's `depends on RESCTRL_FS`
- #7-C (CBQRI=y, RESCTRL_FS=n): ✓ same fix
- #7-list-leak: ✓ `cbqri_controller_destroy(ctrl)` in teardown loop
- #8-G (AT field check): ✓ guards on `ctrl->cc.supports_alloc_at_code`
- #8-H (cbqri_probe_feature unconditional init): ✓
- #8 size minimum check: ✓ `CBQRI_CTRL_MIN_REG_SPAN`
- #8 CDP_NUM_TYPES iteration: ✓
- #8 ncblks > 32: ✓ rejects in cbqri_probe_cc
- #8 u32 vs u64: ✓ explicit `lower_32_bits()`
- #4 cpu_srmcfg hotplug invalidation: ✓ in v4 changelog
- #6 PPTT helper: patch dropped in v3→v4

### Closed without action (2026-05-05)
- **#5 fs/resctrl items** ("Cannot pseudo-lock MBA" diagnostic;
  `fflags_from_resource()` switch vs `resctrl_is_membw()` early-return;
  commit-message default_ctrl phrasing).  Drew's standing rule: do not
  modify fs/resctrl code in the cbqri series unless required for cbqri
  to function.  These three are quality-of-life cleanups that fs/resctrl
  reviewers are better placed to land separately.
- **#8 `has_mon_at_code` discarded.**  `cbqri_probe_cc` and
  `cbqri_probe_bc` each call `cbqri_probe_feature()` for the mon path
  with a local `bool has_mon_at_code = false;` that is then dropped on
  the floor.  Resctrl has no event ID that carries an AT discriminator
  for L3 mon counters, so mon-side AT support has no kernel uABI path
  to a consumer.  The cost of leaving it alone is ~1ms of extra boot
  MMIO per mon probe (a wait-busy round-trip).  Acceptable.  A future
  patch can add NULL-safety to `access_type_supported` if the boot-time
  cost matters; not worth churning v4 for.

### Resolved 2026-05-05 (verified against current rqsc.c)
- **#12 RQSC parse** — all four findings already addressed in v4:
  - `rqsc->header.length < sizeof(struct acpi_table_rqsc)` rejected
    with -EINVAL.
  - `riscv_cbqri_unregister_last(num_controllers)` cleanup on every
    mid-loop error path.
  - `node->reg.space_id != ACPI_ADR_SPACE_SYSTEM_MEMORY` skipped with
    a pr_warn (no silent ioremap of System I/O / PCI config).
  - `if (res0->id1 > U32_MAX)` skipped with a pr_warn (no silent
    truncation of cache_id / prox_dom).

### Per-commit bisectability fixed
Followup amend on top of the Sashiko cleanup landed an additional
scaffolding edit: drop the orphan call to
`acpi_pptt_get_cache_size_from_id()` from
`riscv_cbqri_register_controller()`.  The function was never defined
in v4 (v3's PPTT helper patch was dropped) but the call site was
left in scaffolding.  The cache-alloc patch's diff for
register_controller no longer needs to remove that block; only the
level check + comment remain.

`git checkout <scaffolding> && make ARCH=riscv LLVM=1 W=1` now builds
clean.  Tree at HEAD is intentionally NOT byte-identical to the
original `e8b91d9279ac` since the Sashiko cleanups are real code
changes (the new tip is `38417385b193`).

## 2026-04-29: original sashiko findings on #45

#13 (ACPI: Add support for RQSC) findings already addressed — `!acpi_disabled`
dead-code dropped, gate moved to `CONFIG_RISCV_CBQRI_DRIVER` (Makefile,
asm/acpi.h, init.c).  Backup tag: `backup-pre-sashiko-fixes`.

**Still to investigate** (Drew asked to revisit after build matrix completes):

- **#7 (CBQRI driver scaffolding)** — three issues:
  - **A: Missing dependency on RESCTRL_FS** — Sashiko says CBQRI_DRIVER has
    no `depends on RESCTRL_FS` so `cbqri-y` would be empty when
    `RESCTRL_FS=n`.  *Likely already fixed* — current Kconfig has
    `depends on RISCV && RISCV_ISA_SSQOSID && RESCTRL_FS`.  Sashiko was
    reviewing an older commit SHA (`065c95cc74d0`) reused from prior
    submission DB.  Verify against current scaffolding patch.
  - **B: Misleading help text** — "Selected automatically by
    RISCV_ISA_SSQOSID" — verify whether the conditional select
    `select RISCV_CBQRI_DRIVER if RESCTRL_FS` makes this accurate or
    misleading.
  - **C: Undefined symbols at link time** — config
    `SSQOSID=y, RESCTRL_FS=y, CBQRI_DRIVER=n`: `cbqri_resctrl.c` not
    compiled, but `<asm/resctrl.h>` prototypes (resctrl_arch_*) declared.
    Currently CBQRI_DRIVER is auto-selected when both deps are set, so
    this combination shouldn't be reachable.  Verify the menuconfig
    visibility doesn't allow user to manually disable CBQRI_DRIVER while
    keeping SSQOSID and RESCTRL_FS on.
  - **D: Missing `mutex_init(&ctrl->lock)`** — REAL.
    `riscv_cbqri_register_controller()` does kzalloc + populates fields
    but never calls `mutex_init()`.  Subsequent `mutex_lock()` would
    deref NULL wait_list.  **Highest priority of the four.**

- **#8 (CBQRI cache allocation support)** — four issues:
  - **E: Forward declaration unused** — `cbqri_wait_busy_flag()` is
    forward-declared but immediately followed by its definition; the
    decl is unnecessary.  Cleanup.
  - **F: Wasted ioread64 in cbqri_cc_alloc_op** — initial read of `reg`
    is unconditionally overwritten by `cbqri_wait_busy_flag()` on the
    first poll iteration.  Cleanup; minor performance.
  - **G: AT field write doesn't check per-controller cap** — the AT
    write uses global `is_cdp_l2/l3_enabled` flags but never checks
    `ctrl->cc.supports_alloc_at_code`.  On a multi-controller platform
    where one CC supports AT and another doesn't,
    `cbqri_resctrl_pick_caches()` doesn't validate AT support either,
    so they pass the "compatible" check.  Then writing AT=CODE to a
    non-AT controller surfaces as -EIO.  **Real correctness bug.**
    Fix: include `supports_alloc_at_code` in the pick-caches mismatch
    check, AND guard the AT write on `ctrl->cc.supports_alloc_at_code`.
  - **H: cbqri_probe_feature() conditional write** — only sets
    `*access_type_supported` when `*status != 0`.  Callers must
    pre-init.  Cleanup; init unconditionally at function entry.

- **#12 (ACPI: Parse RQSC table)** — also flagged ISSUES; need to
  fetch and read the inline review.  Use:
  `sashiko-cli show 45 --format json | python3 ... patch_id->inline_review`

## How to fetch full review content

```
/home/pdp7/dev/sashiko/target/release/sashiko-cli show 45 --format json | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
patches={p['id']:p for p in d['patches']}
for r in d['reviews']:
    ir=r.get('inline_review')
    if ir and (not isinstance(ir,str) or 'No issues found' not in ir):
        p=patches.get(r['patch_id'],{})
        print(f\"=== #{p.get('part_index')}: {p.get('subject','')[:65]} ===\")
        print(ir if isinstance(ir,str) else json.dumps(ir,indent=2))
        print()
"
```

## Verification protocol

For each finding: (1) verify against current branch HEAD (sashiko reused
prior reviews so some refs may be stale); (2) classify severity (real
bug vs cleanup vs false positive); (3) propose fix; (4) build matrix +
QEMU re-test; (5) update sashiko submission if a new round needed.
