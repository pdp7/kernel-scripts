---
name: Ascalon CBQRI test driver
description: Status and location of the Ascalon HAPS CBQRI test driver branch and worktree
type: project
originSessionId: 2e0bc4d7-1775-4707-8440-186a70cb4668
---
Platform driver that exercises the CBQRI L2 cache controller on the
Ascalon core complex for HAPS FPGA emulation. ACPI is disabled on
HAPS; minimal busybox rootfs available.

**Branch:** `dfustini/atl-cbqri-test` (based on `b4/ssqosid-cbqri-rqsc`)
**Worktree:** `.worktrees/ascalon-cbqri-test`

**Files:**
- `arch/riscv/kernel/qos_cbqri_test.c` — standalone built-in driver
- `arch/riscv/kernel/Makefile` — `obj-y += qos_cbqri_test.o` (no Kconfig gate)

**Key details:**
- SC MMR base `0xA21a_0000` (Atlantis layout); 16 slices, 0x1000 stride.
  Earlier attempts at `0x421a_0000` decoded an unmapped aperture to
  zero, falsely suggesting "S-mode MMIO dropped."
- CBQRI register block lives at SC + 0xc0; spec offsets within it
  (cap@0, alloc_ctl@24, block_mask@32) → absolute 0xc0/0xd8/0xe0.
- cc_alloc_ctl follows CBQRI v1.0 §3.4 Figure 4 verbatim:
  OP[4:0], AT[7:5], RCID[19:8], BUSY[39], STATUS[38:32].
- Self-registers a platform device in `__init` — runs at boot.
- Driver is unconditionally built (no Kconfig gate); output appears
  in any boot log on relevant hardware.
- Build: `make W=1 ARCH=riscv LLVM=1` via `./llvm.sh`.
- Intentionally NOT on the v4 public patch series — Ascalon-specific
  test code stays out of upstream ssqosid/CBQRI/RQSC submissions.

**Current status (2026-04-27):** All 6 tests pass on HAPS. Per-RCID
storage, per-AT storage, WARL trim (via READ_LIMIT), READ_LIMIT
functional check, and capabilities decode all confirmed working. See
`project_atlantis_sc_cbqri_findings.md` for the full hardware-confirmed
findings table including the cc_block_mask RO-zero quirk.
