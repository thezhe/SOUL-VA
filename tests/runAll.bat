@echo off

REM Script to run PLUG-QA on 'testEffect.soulpatch' and soul errors on 'errors.soulpatch'
REM results and logs in 'results\'
REM Usage .\runAll.bat <Fs>

set FS="%~1"

REM Check compilable
call soul errors errors.soulpatch
if %errorlevel% neq 0 exit /b %errorlevel%

REM PLUG-QA
set OUT_DIR=..\tests\results

cd ../PLUG-QA

if not exist %OUT_DIR% mkdir %OUT_DIR%
if %errorlevel% neq 0 exit /b %errorlevel%

call octave qaScript.m ..\tests\effect.soulpatch %FS% > %OUT_DIR%\qa.log
if %errorlevel% neq 0 exit /b %errorlevel%

del ..\tests\qa.log /s /f /q > nul
if %errorlevel% neq 0 exit /b %errorlevel%

xcopy results\* %OUT_DIR% /e /h /y /i /q > nul
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..\tests
