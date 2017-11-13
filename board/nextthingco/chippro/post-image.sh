
#!/bin/bash -e

echo "##############################################################################"
echo "## $0 "
echo "##############################################################################"

echo "  Creating sparse image with 'img2simg'"
img2simg ${BINARIES_DIR}/rootfs.ubi ${BINARIES_DIR}/rootfs.ubi.sparse 262144 || echo "  E: failed to create sparse image"

echo "  Images and flashing script installed to '${BINARIES_DIR}'"
cp board/nextthingco/chippro/flash.sh ${BINARIES_DIR}/
