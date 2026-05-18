---
name: QEMU ACPI/CBQRI test scripts
description: Daemonized socket-based QEMU launchers for resctrl autorun testing — single-BC (MBM_TOTAL works) and multi-BC (MBM_TOTAL suppressed) variants
type: reference
originSessionId: edefd009-4f27-401c-8677-defdd3d43783
---
Two daemonized launchers live in `~/dev/qemu/` for automated resctrl testing
of the CBQRI series. Both use a chardev unix socket at `/tmp/qemu-acpi.sock`
with a logfile at `/tmp/qemu-acpi.log`, so `tail -f /tmp/qemu-acpi.log` shows
the boot transcript and the rootfs's auto-run `/root/test-resctrl.sh` output.

- `~/dev/qemu/run-acpi-sock-1bc.sh` — 3 CC (2x L2 + 1x L3) + **1 BC**.
  Single mon-capable BC pairs with L3, so `mbm_total_bytes` IS advertised.
  Baseline as of HEAD `75108f056e7f` (2026-05-10): test-resctrl.sh
  **41 PASS / 0 FAIL / 1 SKIP** (the SKIP is the expected "CDP L3 mount
  failed"; CBQRI does not support CDP for L3, only L2). kselftest cbqri
  suite: **3 PASS / 0 FAIL / 0 SKIP**.

- `~/dev/qemu/run-acpi-sock-3bc.sh` — 3 CC + **3 BC**.
  Multiple mon-capable BCs cause `cbqri_find_only_mon_bc()` to return NULL,
  so `mbm_total_bytes` is intentionally NOT advertised. Kernel behavior is
  correct, but the test-resctrl.sh assertion at line 218-222 unconditionally
  expects mbm_total_bytes when info/L3_MON exists, so it produces a spurious
  FAIL on this configuration. Current numbers: **36 PASS / 1 FAIL (script
  bug, not kernel) / 4 SKIP**. kselftest: **2 PASS / 0 FAIL / 1 SKIP**
  (CBQRI_MBM correctly skipped). The script should treat "no BC paired" as
  a skip the same way it does for the per-domain mbm_total_bytes file at
  line 269.

**Standard verification flow after a build**:

```
bash ~/dev/linux/llvm.sh                                       # build
rm -f /tmp/qemu-acpi.{log,sock,pid}
cd ~/dev/qemu && bash ./run-acpi-sock-1bc.sh                   # boot
until grep -qE 'buildroot login:' /tmp/qemu-acpi.log; do sleep 4; done
grep -cE 'Oops|Unable to handle|Kernel BUG|panic' /tmp/qemu-acpi.log  # expect 0
grep -E "^  (PASS|FAIL|SKIP):" /tmp/qemu-acpi.log | sort | uniq -c | sort -rn   # summary
grep '  FAIL:' /tmp/qemu-acpi.log | sort -u                    # expect empty
pkill -9 -f qemu-system-riscv64
rm -f /tmp/qemu-acpi.sock /tmp/qemu-acpi.pid
```

Anything other than the expected baseline is a regression.

The autorun test source is `~/dev/linux/tmp/rootfs/test-resctrl.sh`.  The
rootfs.ext2 copy at `/root/test-resctrl.sh` can be updated in-place via
`debugfs -w` without a buildroot rebuild:

```
cd ~/dev/buildroot/output/images
debugfs -w -R "rm /root/test-resctrl.sh" rootfs.ext2
debugfs -w -R "write ~/dev/linux/tmp/rootfs/test-resctrl.sh /root/test-resctrl.sh" rootfs.ext2
```
