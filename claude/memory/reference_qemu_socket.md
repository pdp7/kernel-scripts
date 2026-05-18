---
name: QEMU serial socket for automated testing
description: How to run commands inside QEMU guest via unix domain socket and socat
type: reference
originSessionId: 42d32e6b-f72f-4fb3-9c52-b20b3cedcbc0
---
Start QEMU daemonized with a unix domain socket for the serial console:

```bash
$QEMU -display none -daemonize -pidfile /tmp/qemu.pid \
    -chardev socket,id=ser0,path=/tmp/qemu-serial.sock,server=on,wait=off \
    -serial chardev:ser0 \
    -kernel ... -append "... console=ttyS0 ..." \
    [other options]
```

Key points:
- Use `-display none` with `-daemonize` (not `-nographic`, which conflicts)
- `-chardev socket,...,server=on,wait=off` makes QEMU create the socket and not block
- Connect immediately after QEMU starts -- output is not buffered

Send commands to the guest shell via bidirectional socat:

```bash
# Single command with wait
{ echo "command here"; sleep 2; } | socat - UNIX-CONNECT:/tmp/qemu-serial.sock

# Login first
{ echo "root"; sleep 2; echo "echo LOGGED_IN"; sleep 1; } | socat - UNIX-CONNECT:/tmp/qemu-serial.sock

# Multiple commands
{
echo "mount -t resctrl resctrl /sys/fs/resctrl && echo OK"
sleep 2
echo "cat /sys/fs/resctrl/schemata"
sleep 2
} | socat - UNIX-CONNECT:/tmp/qemu-serial.sock
```

Capture serial output in background (for boot log):
```bash
socat -u UNIX-CONNECT:/tmp/qemu-serial.sock - > /tmp/serial.log &
```

Cleanup:
```bash
kill $(cat /tmp/qemu.pid)
```

**Why:** WebFetch and pipe-based stdin approaches don't work for QEMU
serial interaction. The unix socket + socat approach gives bidirectional
access to the guest shell.

**How to apply:** Use this pattern whenever testing kernel changes in
QEMU from Claude Code.
