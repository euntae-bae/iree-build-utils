#!/bin/bash

set -e

SRC_PATH=mlir/
DEST_PATH=build/
MLIR_SRC_NAME=simple_abs
IREE_HAL_TARGET="llvm-cpu"

# usage: compile.sh [<MLIR_SRC> <IREE_HAL_TARGET_BACKEND>]
if [ $# -eq 2 ]; then
    MLIR_SRC_NAME=$1
    IREE_HAL_TARGET=$2
fi

echo "Input source file: ${SRC_PATH}${MLIR_SRC_NAME}.mlir"
echo -e "HAL target backend: ${IREE_HAL_TARGET}\n"

IREE_FLAGS="--iree-hal-target-backends=${IREE_HAL_TARGET}"

if [ ${IREE_HAL_TARGET} = "llvm-cpu" ]; then
	IREE_LLVMCPU_FLAGS="--iree-llvmcpu-target-triple=riscv32-pc-linux-elf \
--iree-llvmcpu-target-cpu=generic-rv32 \
--iree-llvmcpu-target-cpu-features=+m,+f,+zvl512b,+zve32x \
--iree-llvmcpu-target-abi=ilp32 \
--iree-llvmcpu-debug-symbols=false"
    IREE_FLAGS="${IREE_FLAGS} ${IREE_LLVMCPU_FLAGS}"
    HAL_TARGET_SUFFIX="llvm-cpu_rv32imf"
else
    HAL_TARGET_SUFFIX=${IREE_HAL_TARGET}
# elif [ ${IREE_HAL_TARGET} = "vmvx" ]; then
#     HAL_TARGET_SUFFIX="vmvx"
# elif [ ${IREE_HAL_TARGET} = "cuda" ]; then
#     HAL_TARGET_SUFFIX="cuda"
# elif [ ${IREE_HAL_TARGET} = "vulkan-spirv" ]; then
#     HAL_TARGET_SUFFIX="vulkan-spirv"
fi

#IREE_COMPILE_LEVELS=("flow" "stream" "hal" "vm")
IREE_COMPILE_LEVELS=("input" "flow" "stream" "executable-sources" "executable-configurations" "executable-targets" "hal" "vm")
IREE_MODULE_TARGETS=("bytecode" "c")

echo "IREE_FLAGS: ${IREE_FLAGS}"
echo -e "HAL_TARGET_SUFFIX: ${HAL_TARGET_SUFFIX}\n"

# HAL backend independant MLIR code generation
echo "HAL backend independant MLIR code generation"
iree-compile ${SRC_PATH}${MLIR_SRC_NAME}.mlir --compile-to=flow -o ${DEST_PATH}${MLIR_SRC_NAME}_flow.mlir
echo ">> ${DEST_PATH}/${MLIR_SRC_NAME}_flow.mlir is generated"
iree-compile ${SRC_PATH}${MLIR_SRC_NAME}.mlir --compile-to=stream -o ${DEST_PATH}${MLIR_SRC_NAME}_stream.mlir
echo -e ">> ${DEST_PATH}${MLIR_SRC_NAME}_stream.mlir is generated\n"

for LEVEL in "${IREE_COMPILE_LEVELS[@]}"
do
    echo "Compile level: ${LEVEL}"
    OUTPUT_TARGET=${DEST_PATH}${MLIR_SRC_NAME}_${HAL_TARGET_SUFFIX}_${LEVEL}.mlir
    iree-compile ${SRC_PATH}${MLIR_SRC_NAME}.mlir ${IREE_FLAGS} --compile-to=${LEVEL} -o ${OUTPUT_TARGET}
    echo ">> ${OUTPUT_TARGET} is generated"
done

OUTPUT_TARGET=${DEST_PATH}${MLIR_SRC_NAME}_${HAL_TARGET_SUFFIX}.vmfb
iree-compile ${SRC_PATH}${MLIR_SRC_NAME}.mlir ${IREE_FLAGS} -o ${OUTPUT_TARGET}
echo ">> VM bytecode module ${OUTPUT_TARGET} is generated"


# STATIC_LIB_FLAGS="--iree-hal-target
# "

## Additional flags
# --output-format=vm-bytecode / vm-c
# --iree-llvmcpu-debug-symbols=false
# --iree-vm-bytecode-module-strip-source-map=true
# --iree-vm-emit-polyglot-zip=false
# --iree-llvmcpu-link-embedded=false
# --iree-llvmcpu-link-static
# --iree-llvmcpu-static-library-output-path=<string>
# --iree-hal-executable-object-search-path

# --compile-to=<value>                                                       - Compilation phase to run up until before emitting output.
# =start                                                                   -   Entry point to the compilation pipeline.
# =input                                                                   -   Performs input processing and lowering into core IREE input dialects (linalg/etc).
# =abi                                                                     -   Adjusts program ABI for the specified execution environment.
# =preprocessing                                                           -   Compiles up to the `preprocessing` specified
# =global-optimization                                                     -   Compiles up to global optimization.
# =flow                                                                    -   Compiles up to the `flow` dialect.
# =stream                                                                  -   Compiles up to the `stream` dialect.
# =executable-sources                                                      -   Compiles up to just before `hal.executable`s are configured, excluding codegen.
# =executable-configurations                                               -   Compiles up to just before `hal.executable`s are translated, including selection of translation strategies for codegen.
# =executable-targets                                                      -   Compiles up to translated `hal.executable`s, including codegen.
# =hal                                                                     -   Compiles up to the `hal` dialect, including codegen.
# =vm                                                                      -   Compiles up to the `vm` dialect.
# =end                                                                     -   Complete the full compilation pipeline.
