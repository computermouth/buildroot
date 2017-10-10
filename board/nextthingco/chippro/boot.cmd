nand erase.chip
mw ${scriptaddr} 0x0
sleep 4
fastboot 0
reset
