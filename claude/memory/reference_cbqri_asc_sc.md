---
name: cbqri-asc-sc.c reference
description: What cbqri-asc-sc.c is and where it runs
type: reference
originSessionId: e1955cba-8b57-4bdc-99e2-7dcdfda45083
---
`cbqri-asc-sc.c` in the repo root is a RISC-V assembly test for the CBQRI
(Capacity and Bandwidth QoS Register Interface) of the **L2 cache** in the
**Ascalon RISC-V core complex** (Tenstorrent).

It runs in bare-metal machine mode on FPGA emulation platforms:
- **Zebu** (Synopsys)
- **HAPS** (Synopsys)

The `;#test.*` metadata headers and `;#random_addr`/`;#page_mapping` directives
are framework directives consumed by the emulation test harness
(author: rgovindaradjou@tenstorrent.com).

MMRs are at base 0x421a00xx (sc = system/L2 cache controller).
