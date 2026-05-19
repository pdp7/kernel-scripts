#!/bin/bash

make W=1 ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j16
md5sum arch/riscv/boot/dts/thead/th1520-lichee-pi-4a.dtb arch/riscv/boot/Image
ls -la arch/riscv/boot/dts/thead/th1520-lichee-pi-4a.dtb arch/riscv/boot/Image
