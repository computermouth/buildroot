#!/bin/bash -e

sunxi-fel spl sunxi-spl.bin
sleep 2

sunxi-fel write 0x4a000000 u-boot.bin
sunxi-fel write 0x43000000 sunxi-spl-with-ecc.bin
sunxi-fel write 0x43100000 boot.scr
sunxi-fel exe 0x4a000000
sleep 8

fastboot -i 0x1f3a flash uboot u-boot.bin
fastboot -i 0x1f3a flash uboot-backup u-boot.bin
fastboot -i 0x1f3a flash UBI rootfs.ubi.sparse
fastboot -i 0x1f3a continue
