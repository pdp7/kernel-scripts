---
name: Atlantis SC CBQRI hardware findings
description: Empirical CBQRI behavior on Atlantis SC controller; hardware matches CBQRI v1.0 spec layout
type: project
originSessionId: 90d33f39-5fe0-49ae-963d-81b4b56b046b
---
**Hardware**: Atlantis SC controller, MMR base `0xA21a_0000`, 16 slices.
**Source**: `arch/riscv/kernel/qos_cbqri_test.c` (branch `dfustini/atl-cbqri-test`).
**Confirmed on real HAPS hardware 2026-04-27 (qos_cbqri_test driver
v1, all 6 tests pass).**

## cc_alloc_ctl bit layout — matches CBQRI v1.0 §3.4 Figure 4

Per the spec PDF at `riscv-specs/riscv-cbqri.pdf` Figure 4:

| Field  | Bits      |
|--------|-----------|
| OP     | [4:0]     |
| AT     | [7:5]     |
| RCID   | [19:8]    |
| WPRI   | [31:20], [63:40 except 39, 38:32] |
| STATUS | [38:32]   |
| BUSY   | [39]      |

Ascalon SC implements this layout exactly. Confirmed by upstream
`cbqri-asc-sc.c` asm test (`0x101 #cc_alloc_ctl : op_value=1 #access_type=0
#rcid=1` → RCID at bit 8) and Anton's `asc-l2.c` userspace utility.

**Earlier bug:** an earlier driver iteration used a fictional layout
(RCID[27:16], BUSY[31], STATUS[39:32]) that does not appear anywhere in
the spec. Writes to RCID landed in WPRI bits and the hardware read
RCID=0 every time — masquerading as "no per-RCID storage." Spec §3.4
Figure 4 is the authoritative reference; do NOT use the fictional
layout.

**How to apply:** any future CBQRI driver (resctrl arch hooks, MPAM
bridge) targeting Ascalon — or any spec-compliant CBQRI controller —
uses the v1.0 spec layout above. cc_mon_ctl (Figure 2) has a parallel
layout: OP[4:0], AT[7:5], MCID[19:8], EVT_ID[27:20], ATV[28],
WPRI[31:29], STATUS[38:32], BUSY[39].

## Findings (post bit-layout fix, 2026-04-27)

1. **`cc_capabilities = 0x0000_0000_0000_1800`**: NCBLKS=24, VER=0.0.

2. **Per-RCID storage works.** CONFIG_LIMIT for RCID 0,1,2,3 with masks
   0x111111/0x222222/0x444444/0x888888 all return `status=0x1`, and
   poisoned READ_LIMIT for each RCID returns its own mask — no leakage.
   (Test 4 of qos_cbqri_test driver.)

3. **Per-AT storage works.** AT=1 is accepted (`alloc_ctl=0x100000021`,
   `status=0x1`), READ_LIMIT AT=1 returns `0x555555`, and a follow-up
   READ_LIMIT AT=0 returns `0xaaaaaa` — AT=0 storage is preserved
   across AT=1 ops. (Test 6.)

4. **WARL trim works (via READ_LIMIT) with one quirk.** After
   CONFIG_LIMIT mask=`~0ULL`, cc_block_mask reads back
   `0x00000000ffffffff` — bits [31:24] retain the SW-written `0xff`
   even though spec §3.5 says bits [BMW-1:NCBLKS] (here [63:24]) are
   read-only zero. After READ_LIMIT, hardware writes back
   `0x0000_0000_00ff_ffff` (24 bits, correctly trimmed to NCBLKS).
   So the *stored allocation* is properly trimmed; only the
   register's RO-zero behavior on direct SW write deviates from spec.
   Harmless for correct software because the configured allocation is
   what READ_LIMIT returns.

5. **Status field semantics (driver v3, all Table 7 codes
   characterized):**
   - `status=0x1` on every successful op (CONFIG_LIMIT/READ_LIMIT for
     valid RCID/AT).
   - `status=0x2` (invalid OP) returned for OP=0 (reserved), OP=4
     (reserved), and OP=3 (FLUSH_RCID, gated by FRCID=0 in caps —
     unsupported ops surface as invalid OP, not silently ignored).
   - `status=0x3` (invalid RCID) returned for RCID ≥ 16 (see #11).
   - `status=0x4` (invalid AT) returned for AT=2 (reserved). Spec
     page 8 says "behaves as if AT was 0" for unsupported AT, but
     Ascalon chooses the stricter status=4 path.
   - `status=0x5` (invalid mask) NOT triggered by mask=0 — Ascalon
     accepts an empty mask with status=0x1. Spec §3.5 lists "at least
     one capacity block" as an OPTIONAL implementation requirement
     for triggering status=5, and Ascalon doesn't enforce it.

10. **Reset behavior matches spec §3.** READ_LIMIT for RCID=0 BEFORE
    any CONFIG_LIMIT returns `block_mask=0x00ffffff` (all NCBLKS
    bits set), as required: "controllers at reset must allocate all
    available capacity to RCID value of 0."

11. **NRCIDs = 16 on Atlantis (driver v4 confirmed).** RCIDs 0..15
    all return `status=0x1` on READ_LIMIT; RCID=16 (and 32, 64, ...,
    4095) all return `status=0x3` (invalid RCID). The supported RCID
    space is 4 bits wide. Practical ceiling for resctrl-style CLOSID
    assignment on this part is exactly 16 distinct RCIDs.

12. **Optional capability bits all OFF.** Test 1 v3 decode:
    FRCID=0 (FLUSH_RCID unsupported), CUNITS=0 (no cc_cunits limits;
    cc_cunits register also reads 0), RPFX=0 (no RCID-prefix MCID
    mode), P=0. Implications: drivers cannot rely on FLUSH_RCID for
    reclamation on workload reassignment, and cannot configure
    capacity-unit (occupancy) sub-limits within an allocation.

13. **Full 16-RCID independence (driver v5 Test 11).** All RCIDs 0..15
    configured with single-bit-per-RCID masks (1<<rcid) store and
    read back independently. Whole supported RCID space is real
    storage, not just the corner verified by Test 5.

14. **STATUS=5 (invalid mask) is never provoked on Ascalon.** Test 8
    (mask=0) and Test 12 (mask=0x1000000, only bit 24 ≥ NCBLKS=24)
    both return STATUS=1 with the stored allocation silently trimmed
    to 0. Ascalon either doesn't implement STATUS=5 or implements it
    only for some other condition we haven't probed. Drivers should
    not rely on STATUS=5 for input validation on this part.

15. **AT support is exactly {0, 1}.** AT=2 (Reserved, Test 8), AT=6,
    AT=7 (Custom range per Table 1, Test 13) all return STATUS=4
    (invalid AT). Spec page 8's "behaves as if AT was 0" path is not
    used by Ascalon — any non-{0,1} AT is rejected. Custom AT slots
    are not extended on this part.

16. **WPRI bits ignored on write, read as 0 (driver v5 Test 14).**
    Wrote `0xffffff00fff00001` to cc_alloc_ctl (sets WPRI bits in
    [31:20] and [63:40]); readback was `0x0000000100000001` (status=1
    + OP echo only, all WPRI bits cleared). Spec-conformant.

17. **Cross-RCID mask overlap is fully supported (driver v5 Test 15).**
    Two RCIDs configured with the same mask (0xff) both store and
    read back independently with status=1. Spec §3.5's "overlap
    allowed" is implemented as expected.

6. **Direct S-mode MMIO works at base 0xA21a_0000.** `ioremap` +
   `readq`/`writeq`, no SBI bounce required.

7. **Clockgate-disable latches.** sc_chicken_bits[47,48] one-shot
   write; reads back as `0x0081870000000000`. QoS-disable (bit 33) is
   already cleared at boot.

8. **Cold-boot reset values.** sc_cc_alloc_ctl and sc_cc_block_mask
   read as 0 at first probe; nonzero pre-state in older runs was
   carryover from prior driver invocations, not a hardware default.

9. **Capacity usage monitoring is NOT implemented.** Test 7 (driver
   v2): cc_mon_ctl reads `0x0` before any write, accepts a
   CONFIG_EVENT MCID=0 EVT_ID=1 (Occupancy) write but reads back
   `0x0` afterward (status=`0x0`); cc_mon_ctr_val also reads `0x0`.
   Per CBQRI §3.2 this means cc_mon_ctl is hardwired to zero,
   indicating the controller does not implement monitoring. Any
   cache-occupancy/event tracking on Atlantis comes from the SC PMU
   (Tenstorrent-specific, offsets 0x140-0x178 select / 0x1c0-0x1f8
   counter), not from CBQRI cc_mon_ctl. Implications: resctrl/MPAM
   monitoring counters (LLC_OCCUPANCY, MBM, etc.) cannot be backed by
   the SC's CBQRI interface on this part.
