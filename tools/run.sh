#!/bin/bash
MLIR_SRC_NAME=simple_abs
HAL_TARGET_SUFFIX="llvm-cpu_rv32imf"
IREE_MODULE_NAME="${MLIR_SRC_NAME}_${HAL_TARGET_SUFFIX}.vmfb"

echo "Enter the IREE module name (default: ${IREE_MODULE_NAME}): "
read INPUT_MODULE_NAME

if [ -z ${INPUT_MODULE_NAME} ]; then
    INPUT_MODULE_NAME=${IREE_MODULE_NAME}
fi

IREE_FLAGS="--device=local-task \
--module=${INPUT_MODULE_NAME} \
--function=abs \
--input=f32=-5
"

# $ iree-run-module \
# --device=local-task \
# --module=simple_abs_vmvx.vmfb \
# --function=abs \
# --input=f32=-5
echo "Run ${INPUT_MODULE_NAME}"
iree-run-module ${IREE_FLAGS}