---
name: Ascalon CBQRI M-mode access investigation
description: Prior S-mode-MMIO-dropped finding was at the wrong base; status open after Atlantis 0xA21a_0000 fix
type: project
originSessionId: 2e0bc4d7-1775-4707-8440-186a70cb4668
---
**Status (2026-04-27, confirmed on HAPS):** Direct S-mode MMIO to the SC
CBQRI region works fine at the correct base `0xA21a_0000`. The original
"S-mode MMIO is silently dropped" conclusion was wrong — it was always
**the wrong base address**. OpenSBI commit 932b654730e8 ("tenstorrent:
atlantis: fix SC MMR base to 0xA21a_0000", Drew, 2026-04-24) explains:
"the fabric silently decoded the unmapped 0x421a_0000 aperture to zero."
Both M-mode (via TTDG GET_MMR) and S-mode reads got the same fabric-zero
— there was never an access-control block, just an unmapped aperture.

**Empirical confirmation:** qos_cbqri_test driver run on HAPS shows
identical reads via SBI vs `ioremap`+`readq`, and an MMIO write of
`block_mask=0x111222` from S-mode reads back as `0x111222` (distinct from
the SBI test's `0x403220`), proving both MMIO read and write paths reach
the SC controller from S-mode.

**Why:** Atlantis SoC MMIO is `0xA000_0000`-based, not `0x4000_0000`. The
upstream asm test (`cbqri-asc-sc.c`) and `asc-l2.c` predate the fix and
still use `0x421a_0000`; both will need the same correction.

**How to apply:** At the correct `0xA21a_0000` base, direct S-mode MMIO
should work (PMP Region05 catch-all permits S/U R/W). The SBI bounce
extension remains useful for M-mode-only state but is not strictly required
just to reach the SC MMRs. The qos_cbqri_test driver's two-test design
(SBI then direct MMIO) confirms this empirically.

---

**Original 2026-04-22 findings (kept for reference, but at the WRONG base
0x421a_0000):**
- OpenSBI PMP Region05 (catch-all) gave S/U full R/W/X — no PMP block
- Reads at 0x421a00c0 returned 0; writes silently ignored; no fault
- HAPS PMP layout had 6/16 entries used; Region05 was a global S/U R/W/X
  catch-all so the dropping was *not* PMP-enforced
- Sstinst absent → mtinst unreliable; mprv fetch needed for trap-and-emulate
- ACPI disabled on HAPS → DSM (Ved option 3) not viable

**Approaches discussed (from Ved Shanbhogue at Rivos):**
1. Trap-and-emulate: OpenSBI adds PMP entry to force a fault, then emulates
2. SBI extension: Linux calls sbi_ecall, OpenSBI does the MMIO in M-mode
3. ACPI DSM: not viable
