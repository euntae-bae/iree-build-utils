## Prerequisite
Make sure that the path where IREE developer tools (such as iree-compile, iree-run-module, iree-dump-module, etc.) are installed is registered in environment variable PATH.

```bash
$ PATH=${IREE_BUILD_PATH}/tools:${PATH}
```

or install the corresponding Python packages.

```bash
$ python -m venv .venv
$ source .venv/bin/activate
$ python -m pip install -r requirements.txt
```


## Build tools usage
### compile.sh
```bash
$ build-tools/compile.sh [<mlir_src_name> <iree_hal_target_backend>]
```

The mlir_src_name defaults to `simple_abs`
iree_hal_target_backend defaults to `llvm-cpu` with RV32IMFV configuration

The source and destination directories are fixed to mlir/ and build/, respectively. If you want to specify the desired path, modify the variables `SRC_PATH` and `DEST_PATH` in compile.sh. So, if you want to compile your model using compile.sh, place the source files in mlir/

For example, if you want to compile `your_model.mlir` with the `vulkan-spirv` HAL backend, type:
```bash
$ ./build-tools/compile.sh your_model vulkan-spirv
```
You should specify only source file name without extension (.mlir)

To see a list of all available target backends, type:
```bash
$ iree-compile --iree-hal-list-target-backends
```


### unpack.sh
```bash
$ build-tools/unpack.sh [<iree_module_name>]
```

Decompose the specified IREE bytecode module (.vmfb) and generate dump files for each component

The IREE bytecode module is decomposed into VM bytecode module (*.fb) and device executable code by `unzip`

The device executable is serialized into either a Flatbuffer (.fb) or shared object (.so) file, depending on the target backend. The latter corresponds to `llvm-cpu`

The generated dump files will have the suffix `_dump.txt`


### compile-iter.sh
```bash
$ build-tools/compile-iter.sh [<mlir_src_name>]
```

Run compile.sh repeatedly on all available HAL backends for the specified model. Then run `unpack.sh` targeting the generated IREE Flatbuffer module (.vmfb)

Same as compile.sh, the default value of mlir_src_name is `simple_abs`

The list of target backends is described in the variable `IREE_HAL_TARGETS` in compile-iter.sh
