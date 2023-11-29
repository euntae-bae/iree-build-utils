#!/bin/bash

#IREE_MODULE_NAME=mnist_vulkan-spirv
IREE_MODULE_NAME=simple_abs_llvm-cpu_rv32imf

set -e

if [ $# -eq 1 ]; then
    IREE_MODULE_NAME=$1
    IREE_HAL_TARGET=$2
fi

DUMP_FILE_PATH=${IREE_MODULE_NAME}
unzip -d ${DUMP_FILE_PATH} ${IREE_MODULE_NAME}.vmfb
chmod 0644 ${DUMP_FILE_PATH}/*
iree-dump-module ${IREE_MODULE_NAME}.vmfb > ${DUMP_FILE_PATH}/${IREE_MODULE_NAME}_dump.txt
echo ">> ${DUMP_FILE_PATH}/${IREE_MODULE_NAME}_dump.txt is generated"

FB_FILE_LIST="${DUMP_FILE_PATH}/*.fb"
for FB_FILE in ${FB_FILE_LIST[@]}
do
    DUMP_FILE_NAME="$(basename -s .fb ${FB_FILE})_dump.txt" 
    xxd ${FB_FILE} ${DUMP_FILE_PATH}/${DUMP_FILE_NAME}
    echo ">> ${DUMP_FILE_PATH}/${DUMP_FILE_NAME} is generated"
done

if [ ! -e "${DUMP_FILE_PATH}/"*.so ]; then
    exit 0;
fi

SO_FILE_LIST="${DUMP_FILE_PATH}/*.so"
OBJDUMP_PATH="/home/euntae/build/riscv/rv32imf-llvm/bin/riscv32-unknown-elf-objdump"
#OBJDUMP_PATH="/home/euntae/build/riscv/rv32imf-llvm/bin/llvm-objdump"

for SO_FILE in ${SO_FILE_LIST[@]}
do
    DUMP_FILE_NAME="$(basename -s .so ${SO_FILE})_dump.txt"
    ${OBJDUMP_PATH} -d ${SO_FILE} > "${DUMP_FILE_PATH}/${DUMP_FILE_NAME}"
    echo ">>> ${DUMP_FILE_PATH}/${DUMP_FILE_NAME} is generated"
done
