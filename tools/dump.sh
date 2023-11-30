#!/bin/bash

DUMP_FILE_SUFFIX="dump.txt"
IREE_MODULE_NAMES="*.vmfb"

for MODULE_NAME in ${IREE_MODULE_NAMES[@]}
do
    DUMP_FILE_NAME="$(basename -s .vmfb ${MODULE_NAME})_${DUMP_FILE_SUFFIX}"
    iree-dump-module ${MODULE_NAME} > ${DUMP_FILE_NAME}
    echo "${DUMP_FILE_NAME} is generated"
done
