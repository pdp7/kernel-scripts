---
name: asc-l2.c reference
description: Userspace C utility for Ascalon L2 slice cache PMU and CBQRI control via OpenSBI debugfs
type: reference
originSessionId: 32225a4b-4e88-4e93-a972-c644b476a15c
---
`asc-l2.c` in the repo root is a userspace C program for interacting with the
Ascalon L2 slice cache controller. Not to be confused with `cbqri-asc-sc.c`
(bare-metal RISC-V asm test for FPGA emulation).

Runs in Linux userspace. Accesses MMRs via OpenSBI debugfs:
- `/sys/kernel/debug/opensbi-csr/get_mmr` (write addr, read "0xADDR: 0xVAL")
- `/sys/kernel/debug/opensbi-csr/set_mmr` (write "0xADDR 0xVAL")

Hardware assumed: 16 L2 slices at base `0x421a0000`, stride `0x1000`, 24 ways,
8 PMU counters per slice.

Capabilities via CLI (`getopt_long`):
- `--setup [-e EVENT]...` — program PMU event selects (default: SC2FB_RD_{U,C,O},
  SC2FB_WR, LIVELOCK_{DETECT,LIFETIME}, MSHR_{ALLOC,LIFETIME}) and enable counters
- `--read` — 1s-interval per-slice + totals display of all 8 counters
- `--disable-clockgate` / `--enable-clockgate` — toggle chicken bits
  (INTRA_SLICE_CLOCK_GATE_DISABLE bit 48, SLICE_CG_DISABLE bit 47)
- `--configure-qos` — hardwired to 4 cores (mask 0xf), evenly partitions 24 ways
  across cores, RCID == core ID, via CONFIG_LIMIT op on `cc_alloc_ctl`
- `--deconfigure-qos` — sets CHICKEN_BIT_QOS_DISABLE (bit 33)
- `--list` — enumerate PMU event names

CBQRI register layout matches `qos_resctrl.c`: OP bits 4:0, AT bits 7:5,
RCID bits 19:8, STATUS bits 38:32, BUSY bit 39.
