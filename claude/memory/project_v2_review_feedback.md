---
name: v2 review feedback tracker
description: Outstanding review comments from v2 series reviewers (Reinette, Radim, others) to address in v3
type: project
---

Review feedback on [PATCH RFC v2] RISC-V: QoS: add CBQRI resctrl interface
from lore and mbox files.

**Why:** v3 must address all review comments or explain why not.

**How to apply:** Check each item against the current branch before sending v3.
Cross-reference with v3-changelog.txt.

Reinette Chatre (patch 08/17 qos_resctrl.c) - 2026-02-13:
- [fixed v3] Drop resctrl_arch_find_domain() — duplicate of resctrl_find_domain()
- [fixed v3] Define RISCV_RESCTRL_EMPTY_CLOSID instead of referencing X86 constant
- [fixed v3] Implement resctrl_arch_set_cpu_default_closid_rmid() (was no-op)
- [fixed v3] Remove unneeded ioread64() in cbqri_set_cbm()
- [fixed v3] Drop hw_dom->ctrl_val[] — read/write hardware directly
- [fixed v3] Sort domain list (use resctrl_find_domain() for insertion)
- [fixed v3] Use cache_id for domain ID instead of sequential counter
- [fixed v3] Fix max_rmid — use minimum mcid_count across controllers

Radim Krčmář (patch 08/17 qos_resctrl.c) - 2026-03-31:
- [fixed v3] Missing err = -ENOMEM after ioremap() failure in cbqri_probe_controller()
- [fixed v3] ver_major masked but not shifted — fixed by FIELD_GET(GENMASK(7,4))
- [fixed v3] Converted all mask+shift patterns to FIELD_GET()/FIELD_PREP()/GENMASK()

Mbox file: DHH5NGQGQYBE.31X8OI8AKTYRU@oss.qualcomm.com.mbx
