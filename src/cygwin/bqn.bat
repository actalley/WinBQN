@echo off

set HOME=%HOMEPATH%
set INPUTRC=%~dp0.bqn.inputrc

%~dp0bin\mintty.exe %~dp0bin\rlwrap.exe %~dp0bin\bqn.exe %*