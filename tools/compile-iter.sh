#!/bin/bash

# To display target backend list, use `--iree-hal-list-target-backends` option
#Registered target backends:
#  cuda
#  llvm-cpu
#  metal
#  metal-spirv
#  rocm
#  vmvx
#  vmvx-inline
#  vulkan
#  vulkan-spirv
set -e

MLIR_SRC_NAME=simple_abs
IREE_HAL_TARGETS=( \
"cuda" \
"llvm-cpu" \
"metal" \
"metal-spirv" \
"rocm" \
"vmvx" \
# "vmvx-inline" \
"vulkan" \
"vulkan-spirv")

# usage: compile-iter.sh [<MLIR_SRC_NAME>]
if [ $# -eq 1 ]; then
    MLIR_SRC_NAME=$1
fi

for HAL_TARGET in ${IREE_HAL_TARGETS[@]}
do
    echo -e "\e[1;32m## compile the ${MLIR_SRC_NAME}.mlir (hal backend: ${HAL_TARGET}) ##\e[0m"
    tools/compile.sh ${MLIR_SRC_NAME} ${HAL_TARGET}
    UNPACK_TARGET=${MLIR_SRC_NAME}_${HAL_TARGET}
    if [ ${HAL_TARGET} = "llvm-cpu" ]; then
        UNPACK_TARGET=${MLIR_SRC_NAME}_${HAL_TARGET}_rv32imf
    fi
    echo -e "\e[1;32m## unpack the ${UNPACK_TARGET}.vmfb ##\e[0m"
    tools/unpack.sh ${UNPACK_TARGET}
done
