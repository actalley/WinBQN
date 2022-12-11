# WinBQN

WinBQN is a work in progress attempt at providing an easy to install and configure distribution of [CBQN](https://github.com/dzaima/CBQN) for Windows.

| Download                                 | Description     |
| -----------------------------------------|-----------------|
| [cbqn-msys2-mintty-standalone-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.8-alpha/cbqn-msys2-mintty-standalone-x86_64.zip) | Msys2 compiled CBQN, mintty, rlwrap, required libraries, and BQN character input configuration for the repl |
| [cbqn-msys2-standalone-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.8-alpha/cbqn-msys2-standalone-x86_64.zip) | Msys2 compiled CBQN and required library |
| [cbqn-cygwin-gcc-mintty-standalone-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.8-alpha/cbqn-cygwin-gcc-mintty-standalone-x86_64.zip) | Cygwin (gcc) compiled CBQN, mintty, rlwrap, required libraries, and BQN character input configuration for the repl |
| [cbqn-cygwin-gcc-standalone-x86_64.zip](https://github.com/actalley/WinBQN/releases/download/v0.0.8-alpha/cbqn-cygwin-gcc-standalone-x86_64.zip) | Cygwin (gcc) compiled CBQN and required library |

## Short(ish) Term Goals
- [x] Basic standalone xcopy-distribution
- [x] Mintty and rlwrap with input configuration
- [ ] [Double-struck letter](https://mlochbaum.github.io/BQN/#how-do-i-work-with-the-character-set) input when using BQN.exe with [bqn-vscode](https://github.com/razetime/bqn-vscode) or Vim terminal (mintty) 
- [ ] BQN character input when using BQN.exe with gVim terminal
- [ ] Stable builds
- [ ] Environment and configuration with sane defaults
- [ ] Installer(s)
- [ ] Tests
- [ ] CI/CD

## Maybe Someday
- [ ] Eliminate Cygwin/Msys2 dependencies
- [ ] Authenticode signed executables
- [ ] Useful libraries for Windows