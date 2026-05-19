#!/bin/bash

HOST=192.168.0.30

make W=1 ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j16

md5sum arch/riscv/boot/dts/thead/th1520-lichee-pi-4a.dtb arch/riscv/boot/Image

ls -la arch/riscv/boot/dts/thead/th1520-lichee-pi-4a.dtb arch/riscv/boot/Image

scp -p arch/riscv/boot/dts/thead/th1520-lichee-pi-4a.dtb arch/riscv/boot/Image debian@${HOST}:.
if [ $? -eq 0 ]; then
	#read -p "Press enter to copy to board and reboot"
	ssh debian@${HOST} "./copy.sh"
else
	echo scp failed
fi


###### FILE: copy.sh
#cd $HOME
#ls -la Image th1520-lichee-pi-4a.dtb
#sudo cp -p Image /boot/vmlinuz-6.8.0-rc2 
#sudo cp -p th1520-lichee-pi-4a.dtb /boot/dtbs/linux-image-6.8.0-rc2/thead/th1520-lichee-pi-4a.dtb
#ls -la /boot/vmlinuz-6.8.0-rc2 /boot/dtbs/linux-image-6.8.0-rc2/thead/th1520-lichee-pi-4a.dtb 
#md5sum /boot/vmlinuz-6.8.0-rc2 /boot/dtbs/linux-image-6.8.0-rc2/thead/th1520-lichee-pi-4a.dtb 
#read -p "Press enter to reboot"
#sudo reboot

