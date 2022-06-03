@echo off

set HOME=%HOMEDRIVE%%HOMEPATH%
set INPUTRC=%~dp0.bqn.inputrc

%~dp0usr\bin\mintty.exe %~dp0usr\bin\rlwrap.exe %~dp0usr\bin\bqn.exe %*