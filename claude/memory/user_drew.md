---
name: Drew Fustini - kernel developer
description: User is Drew Fustini (drew@pdp7.com / fustini@kernel.org), RISC-V kernel maintainer working on QoS/CBQRI/resctrl and T-Head SoC support
type: user
---

Drew Fustini is a Linux kernel developer and maintainer:
- Maintainer for T-Head SoCs (took over July 2024), sends pull requests to Arnd Bergmann
- Has thead-dt-fixes and thead-dt-for-next branches in linux-next
- Working on RISC-V Ssqosid/CBQRI/RQSC patch series for resctrl support (at Tenstorrent)
- Reviews external patches to arch/riscv (mm, DMA, SWIOTLB, etc.)
- Uses both /kreview (manual) and /korcreview (ORC multi-agent) for patch analysis
- Develops and tests using QEMU with RISC-V CBQRI support
- Builds kernel with: make W=1 ARCH=riscv LLVM=1 -j16
- GitHub: github.com/pdp7/linux.git
