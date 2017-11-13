nand erase.chip
mw ${scriptaddr} 0x0
nand write.raw.noverify 0x43000000 0 40
nand write.raw.noverify 0x43000000 40000 40
fastboot 0
reset
