---
name: cbqri-mpam-align branch
description: WIP branch dfustini/cbqri-mpam-align stages the v5 restructure that aligns the RISC-V CBQRI driver with the ARM64 MPAM driver layout
type: project
originSessionId: 0c2082f0-172f-48e0-98ec-d2d1e7ad249b
---
Branch `dfustini/cbqri-mpam-align` (archived at `~/dev/kernel/archive/cbqri-mpam-align`) is the **v5 restructure WIP** for the ssqosid-cbqri series. Four commits, all marked `WIP:`, intended to be folded into the v4 commits before sending v5 — there will be no intermediate "RBWB" patches in the public series.

What the four commits do (oldest → newest):

1. `96261cde` — move `arch/riscv/kernel/qos/` → `drivers/resctrl/cbqri_*.c` so CBQRI lives next to MPAM; rename `RDT_RESOURCE_RBWB` → `MBA_MIN`, `MWEIGHT` → `MBA_PROP` so MPAM can reuse the names when it exposes `MBW_MIN`/`MBW_PROP`. New Kconfig mirrors `ARM64_MPAM_DRIVER` / `ARM64_MPAM_RESCTRL_FS`.
2. `9e7b2f7b` — three-phase setup (probe/pick/init/register) mirroring `mpam_resctrl.c`; consolidates the three init helpers into one switch on rid.
3. `576bda38` — event-indexed `cbqri_resctrl_counters[QOS_NUM_EVENTS]` and `for_each_cbqri_resctrl_*` macros mirroring `mpam_resctrl_counters[]` / `for_each_mpam_resctrl_*`.
4. `09bdf786` — rename `MBA_MIN`/`MBA_PROP` → `MB_MIN`/`MB_PROP` because `struct resctrl_schema.name[8]` only fits 7+null, so `MBA_PROP` was failing `mount -t resctrl` with `-EINVAL`. Matches MPAM's `MB` schema. Plus checkpatch --strict fixes.

**Why:** The v5 series is supposed to land CBQRI in `drivers/resctrl/` directly with MPAM-aligned names and structure, not as an after-the-fact move. So the v4 series gets rebased to introduce the new layout from the start.

**How to apply:** When working on the ssqosid-cbqri series toward v5, this branch is the source of truth for the target structure. Some pieces are already partly absorbed into the main `b4/ssqosid-cbqri-rqsc` branch — the move to `drivers/resctrl/cbqri_*.c` is reflected in uncommitted changes there, and the `MB_MIN`/`MB_PROP` naming appears in main commits `fbf64d35` and `afb305605`. Before re-applying anything from the archive, diff against main to see what's already landed.
