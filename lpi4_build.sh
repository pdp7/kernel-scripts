#!/bin/bash

make W=1 ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j16

if [[ $? -ne 0 ]] ; then
    exit 1
fi

#for file in arch/riscv/boot/dts/thead/th1520-beaglev-ahead.dtb arch/riscv/boot/Image;
#do
	#md5sum $file
	#ls -la $file
#done

#cp -p arch/riscv/boot/dts/thead/th1520-beaglev-ahead.dtb /home/pdp7/dev/ahead/xuantie-ubuntu/deploy/light-beagle.dtb
#md5sum /home/pdp7/dev/ahead/xuantie-ubuntu/deploy/light-beagle.dtb
#ls -la /home/pdp7/dev/ahead/xuantie-ubuntu/deploy/light-beagle.dtb
#cp -p arch/riscv/boot/Image /home/pdp7/dev/ahead/xuantie-ubuntu/deploy/Image
#md5sum /home/pdp7/dev/ahead/xuantie-ubuntu/deploy/Image
#ls -la /home/pdp7/dev/ahead/xuantie-ubuntu/deploy/Image

scp -p arch/riscv/boot/dts/thead/th1520-lichee-pi-4a.dtb arch/riscv/boot/Image debian@192.168.0.30:.
ssh debian@192.168.0.30 'sudo ./copy.sh'
