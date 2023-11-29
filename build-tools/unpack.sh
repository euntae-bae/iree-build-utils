#!/bin/bash

# SRC_PATH=mlir/
# DEST_PATH=build/
SRC_PATH=build/
DEST_PATH=${SRC_PATH}
#IREE_MODULE_NAME=mnist_vulkan-spirv
IREE_MODULE_NAME=simple_abs_llvm-cpu_rv32imf
DUMP_FILE_SUFFIX=_dump.txt

set -e

if [ $# -eq 1 ]; then
    IREE_MODULE_NAME=$1
fi

DEST_PATH=${DEST_PATH}${IREE_MODULE_NAME}
unzip -d ${DEST_PATH} ${SRC_PATH}${IREE_MODULE_NAME}.vmfb
chmod 0644 ${DEST_PATH}/*
iree-dump-module ${SRC_PATH}${IREE_MODULE_NAME}.vmfb > ${DEST_PATH}/${IREE_MODULE_NAME}${DUMP_FILE_SUFFIX}
echo ">> ${DEST_PATH}/${IREE_MODULE_NAME}${DUMP_FILE_SUFFIX} is generated"

FB_FILE_LIST="${DEST_PATH}/*.fb"
for FB_FILE in ${FB_FILE_LIST[@]}
do
    DUMP_FILE_NAME="$(basename -s .fb ${FB_FILE})${DUMP_FILE_SUFFIX}"
    xxd ${FB_FILE} ${DEST_PATH}/${DUMP_FILE_NAME}
    echo ">> ${DEST_PATH}/${DUMP_FILE_NAME} is generated"
done

if [ ! -e "${DEST_PATH}/"*.so ]; then
    exit 0;
fi

SO_FILE_LIST="${DEST_PATH}/*.so"
OBJDUMP_PATH="/home/euntae/build/riscv/rv32imf-llvm/bin/riscv32-unknown-elf-objdump"
#OBJDUMP_PATH="/home/euntae/build/riscv/rv32imf-llvm/bin/llvm-objdump"

for SO_FILE in ${SO_FILE_LIST[@]}
do
    DUMP_FILE_NAME="$(basename -s .so ${SO_FILE})${DUMP_FILE_SUFFIX}"
    ${OBJDUMP_PATH} -d ${SO_FILE} > "${DEST_PATH}/${DUMP_FILE_NAME}"
    echo ">>> ${DEST_PATH}/${DUMP_FILE_NAME} is generated"
done
