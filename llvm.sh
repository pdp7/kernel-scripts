#!/bin/bash
#make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j16
make W=1 ARCH=riscv LLVM=1 -j16

