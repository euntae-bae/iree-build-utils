#!/bin/bash
MLIR_SRC_NAME=simple_abs
TARGET_SUFFIX=cpu_rv32imf

IREE_HAL_TARGET="--iree-hal-target-backends=llvm-cpu"
IREE_LLVMCPU_FLAGS="--iree-llvmcpu-target-triple=riscv32-pc-linux-elf \
--iree-llvmcpu-target-cpu=generic-rv32 \
--iree-llvmcpu-target-cpu-features=+m,+f \
--iree-llvmcpu-target-abi=ilp32"

IREE_FLAGS="${IREE_HAL_TARGET} ${IREE_LLVMCPU_FLAGS}"

iree-compile ${MLIR_SRC_NAME}.mlir --compile-to=flow   -o ${MLIR_SRC_NAME}_flow.mlir
iree-compile ${MLIR_SRC_NAME}.mlir --compile-to=stream -o ${MLIR_SRC_NAME}_stream.mlir
iree-compile ${MLIR_SRC_NAME}.mlir ${IREE_FLAGS} --compile-to=hal -o ${MLIR_SRC_NAME}_${TARGET_SUFFIX}_hal.mlir
iree-compile ${MLIR_SRC_NAME}.mlir ${IREE_FLAGS} --compile-to=vm  -o ${MLIR_SRC_NAME}_${TARGET_SUFFIX}_vm.mlir

