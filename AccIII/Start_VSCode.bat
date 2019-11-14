@echo off
SET VSDEVCMD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\
REM SET ACCIIIPATH in Environment Variables -> System variables
ECHO Starting ...
call "%VSDEVCMD_PATH%\VsDevCmd.bat"
cmd.exe /K "cd %ACCIIIPATH%\AccIII && code ."