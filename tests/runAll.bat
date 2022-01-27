@echo off

REM Script to run PLUG-QA on 'testEffect.soulpatch' and soul errors on 'errors.soulpatch'
REM results and logs in 'results\'
REM Usage .\runAll.bat <Fs>

REM parse arguments

if "%~1"=="" goto wrongUsage
if "%~1"=="help" goto wrongUsage

if %~1 lss 44100 goto wrongFs
if %~1 gtr 96000 goto wrongFs

set FS="%~1" 

REM soul errors errors.soulpatch

call soul errors errors.soulpatch
if %errorlevel% neq 0 exit /b %errorlevel%

REM PLUG-QA

cd ..\PLUG-QA

set OUT_DIR=..\tests\results

if not exist %OUT_DIR% mkdir %OUT_DIR%
if %errorlevel% neq 0 exit /b %errorlevel%

call octave qaScript.m ..\tests\effect.soulpatch %FS% > %OUT_DIR%\qa.log
if %errorlevel% neq 0 exit /b %errorlevel%

del ..\tests\qa.log /s /f /q > nul
if %errorlevel% neq 0 exit /b %errorlevel%

xcopy results\* %OUT_DIR% /e /h /y /i /q > nul
if %errorlevel% neq 0 exit /b %errorlevel%

cd ..\tests

exit /b 0 

REM exceptions

:wrongUsage
echo Usage: .\runAll.bat ^<^Fs^>^ 
exit /b 1

:wrongFs
echo ^<^Fs^>^ must be in the range [44100, 96000] 
exit /b 1