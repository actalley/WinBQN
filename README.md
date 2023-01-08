# WinBQN

WinBQN is a work in progress attempt at providing an easy to install and configure distribution of [CBQN](https://github.com/dzaima/CBQN) for Windows.

| Download                                 | Description     |
| -----------------------------------------|-----------------|
| [dzaima-cbqn-dev-381460e-llvm-mingw-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.10-alpha/dzaima-cbqn-dev-381460e-llvm-mingw-x86_64.zip) | Native CBQN built with [llvm-mingw](https://github.com/mstorsjo/llvm-mingw) from [dzaima/cbqn:develop 381460e](https://github.com/dzaima/CBQN/tree/381460e) |
| [dll-dzaima-cbqn-dev-381460e-llvm-mingw-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.10-alpha/dll-dzaima-cbqn-dev-381460e-llvm-mingw-x86_64.zip) | Native `cbqn.dll` built with [llvm-mingw](https://github.com/mstorsjo/llvm-mingw) from [dzaima/cbqn:develop 381460e](https://github.com/dzaima/CBQN/tree/381460e) |
| [dllstatic-dzaima-cbqn-dev-381460e-llvm-mingw-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.10-alpha/dllstatic-dzaima-cbqn-dev-381460e-llvm-mingw-x86_64.zip) | Native static linked `cbqn.dll` built with [llvm-mingw](https://github.com/mstorsjo/llvm-mingw) from [dzaima/cbqn:develop 381460e](https://github.com/dzaima/CBQN/tree/381460e) |

Native builds currently do not handle double-struck character input correctly. It is possible to run `.bqn` files via `-f`, however they must have Unix line endings (for now). `UTF-8` console output has not been addressed. No `•FFI` or `•SH` yet. Early days.

Old MSYS2 and Cygwin builds are still available in [Releases](https://github.com/actalley/WinBQN/releases), but there will be no new versions.

## Short(ish) Term Goals
- [x] Produce native builds with no Cygwin/MSYS2 dependencies
- [x] Provide native `cbqn.dll`
- [ ] Provide `•FFI`
- [ ] Provide `•SH`
- [ ] Provide usable repl without mintty
