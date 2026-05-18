---
name: build-matrix.sh
description: Build matrix script in linux/ for 0day-style multi-arch verification of a series before sending to lore
type: reference
originSessionId: 7f1372ba-0843-4150-948f-53c1a64bac6c
---
`/home/pdp7/dev/linux/build-matrix.sh` runs a 6-config sequential build matrix to verify a series on multiple archs before sending to lore. Mirrors what 0day-bot would catch.

**Configs (in order)**: `current` (in-tree .config), `x86_64-defconfig`, `arm64-defconfig`, `rv64-defconfig`, `rv64-allnoconfig`, `rv64-randconfig`.

**Invocation**:
- `./build-matrix.sh` — all 6 sequentially at `-j16`
- `./build-matrix.sh <name>` — just one
- `./build-matrix.sh --clean` — rm -rf build-matrix/
- `KCONFIG_SEED=<n> ./build-matrix.sh rv64-randconfig` — reproduce a specific random config

**Layout written to `build-matrix/`**:
- `SUMMARY.md` (after triage)
- `configs/<name>.config` — post-resolved .config per build
- `configs/pre-matrix.config.bak` — backup of original in-tree .config
- `configs/rv64-randconfig.seed` — KCONFIG_SEED used
- `logs/<name>.log` — line-buffered, tail-able while building
- `<name>/` — O= dir (vmlinux + objects)

**Critical design choices**:
- Source is `.worktrees/build-matrix/` (linked git worktree at HEAD), NOT the main tree. Kbuild rejects `O=` when the srctree has in-tree build artifacts; the worktree provides a clean srctree without disturbing the main tree's build state.
- Build flags: `make ARCH=<arch> LLVM=1 W=1 -j16 -k`. NOT `W=12`, NOT `KCFLAGS=-Werror`, NOT forcing CONFIG_WERROR=y — those promote upstream `-Wshadow`/`-Wunused-macros` to errors and create noise unrelated to the series.
- The in-tree `.config` is never modified.

**Triage commands** (run after the matrix completes):
```
grep -cE '^[^:]+:[0-9]+:[0-9]+: error:' build-matrix/logs/<name>.log
grep -E '^[^:]+:[0-9]+:[0-9]+:' build-matrix/logs/<name>.log \
  | grep -E '(arch/riscv/kernel/qos|drivers/resctrl|fs/resctrl|drivers/acpi/riscv|drivers/acpi/pptt|include/linux/resctrl\.h|include/acpi/actbl2\.h|include/linux/acpi\.h|tools/testing/selftests/resctrl)'
```
Adjust the second regex to whatever paths the series touches.
