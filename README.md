# WinBQN

WinBQN is a work in progress attempt at providing an easy to install and configure distribution of [CBQN](https://github.com/dzaima/CBQN) for Windows.

| Download                                 | Description     |
| -----------------------------------------|-----------------|
| [dzaima-cbqn-dev-7b7c31e-llvm-mingw-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.9-alpha/dzaima-cbqn-dev-7b7c31e-llvm-mingw-x86_64.zip) | Native CBQN built with [llvm-mingw](https://github.com/mstorsjo/llvm-mingw) from [dzaima/cbqn:develop 7b7c31e](https://github.com/dzaima/CBQN/tree/7b7c31e) |

Native builds currently error on repl input. It is possible to run `.bqn` files via `-f`, however they must have Unix line endings (for now). `UTF-8` console output has not been addressed. No `•FFI`, `•SH`, or `cbqn.dll` yet. Early days.

Old MSYS2 and Cywin builds are still available in [Releases](https://github.com/actalley/WinBQN/releases), but there will be no new versions.

## Short(ish) Term Goals
- [x] Produce native builds with no Cygwin/MSYS2 dependencies
- [ ] Provide native `cbqn.dll` and `•FFI`
- [ ] Provide `•SH`
- [ ] Provide usable repl without mintty
