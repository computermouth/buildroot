
#!/bin/bash -ex

## Variables

NAND_MAXLEB_COUNT=2048
NAND_SUBPAGE_SIZE=1024
NAND_ERASE_BLOCK_SIZE=262144
NAND_PAGE_SIZE=4096
NAND_OOB_SIZE=256
NAND_USABLE_PAGE_SIZE=1024
NAND_ECC_CONFIG=64/1024

## SPL Prep

SPL_INPUT=${BINARIES_DIR}/sunxi-spl.bin
SPL_OUTPUT=${BINARIES_DIR}/nand-sunxi-spl.bin

#~ echo -e "sunxi-nand-image-builder \
 #~ -c ${NAND_ECC_CONFIG} \
 #~ -p ${NAND_PAGE_SIZE} \
 #~ -o ${NAND_OOB_SIZE} \
 #~ -u ${NAND_USABLE_PAGE_SIZE} \
 #~ -e ${NAND_ERASE_BLOCK_SIZE} \
 #~ -b \
 #~ -s ${SPL_INPUT} \
 #~ ${SPL_OUTPUT}"

#~ sunxi-nand-image-builder \
 #~ -c ${NAND_ECC_CONFIG} \
 #~ -p ${NAND_PAGE_SIZE} \
 #~ -o ${NAND_OOB_SIZE} \
 #~ -u ${NAND_USABLE_PAGE_SIZE} \
 #~ -e ${NAND_ERASE_BLOCK_SIZE} \
 #~ -b \
 #~ -s ${SPL_INPUT} \
 #~ ${SPL_OUTPUT}

prepare_spl() {
  local tmpdir=`mktemp -d -t chip-spl-XXXXXX`
  local nandrepeatedspl=$1
  local spl=$2
  local eraseblocksize=$3
  local pagesize=$4
  local oobsize=$5
  local repeat=$((eraseblocksize/pagesize/64))
  local nandspl=$tmpdir/nand-spl.bin
  local nandpaddedspl=$tmpdir/nand-padded-spl.bin
  local padding=$tmpdir/padding
  local splpadding=$tmpdir/nand-spl-padding

  echo sunxi-nand-image-builder -c 64/1024 -p $pagesize -o $oobsize -u 1024 -e $eraseblocksize -b -s $spl $nandspl
  sunxi-nand-image-builder -c 64/1024 -p $pagesize -o $oobsize -u 1024 -e $eraseblocksize -b -s $spl $nandspl

  local splsize=`stat --printf="%s" $nandspl`
  local paddingsize=$((64-(splsize/(pagesize+oobsize))))
  local i=0

  while [ $i -lt $repeat ]; do
    dd if=/dev/urandom of=$padding bs=1024 count=$paddingsize
    echo sunxi-nand-image-builder -c 64/1024 -p $pagesize -o $oobsize -u 1024 -e $eraseblocksize -b -s $padding $splpadding
    sunxi-nand-image-builder -c 64/1024 -p $pagesize -o $oobsize -u 1024 -e $eraseblocksize -b -s $padding $splpadding
    cat $nandspl $splpadding > $nandpaddedspl

    if [ "$i" -eq "0" ]; then
      cat $nandpaddedspl > $nandrepeatedspl
    else
      cat $nandpaddedspl >> $nandrepeatedspl
    fi

    i=$((i+1))
  done

  rm -rf $tmpdir
}

prepare_spl $SPL_OUTPUT $SPL_INPUT $NAND_ERASE_BLOCK_SIZE $NAND_PAGE_SIZE $NAND_OOB_SIZE

## UBOOT Prep

UBOOT_INPUT=${BINARIES_DIR}/u-boot.bin
UBOOT_OUTPUT=${BINARIES_DIR}/padded-u-boot.bin

dd if=${UBOOT_INPUT} of=${UBOOT_OUTPUT} bs=${NAND_ERASE_BLOCK_SIZE} conv=sync
