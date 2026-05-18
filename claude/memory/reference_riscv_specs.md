---
name: RISC-V spec PDFs in repo
description: Location of RISC-V spec PDFs in the linux tree for offline lookup
type: reference
originSessionId: 32225a4b-4e88-4e93-a972-c644b476a15c
---
RISC-V spec PDFs live at `/home/pdp7/dev/linux/riscv-specs/`. These are large
PDFs — read with `Read` tool and the `pages` parameter (max 20 pages per
request).

Known PDFs:
- `riscv-sbi.pdf` — RISC-V Supervisor Binary Interface v3.0 (ratified 2025-07-16,
  111 pages). Covers Base/HSM/PMU/SRST/CPPC/NACL/STA/SSE/FWFT/DBTR/MPXY and
  legacy extensions.

Prefer reading the local PDF over WebFetch for SBI questions — it's the
ratified spec and up to date.
