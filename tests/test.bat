@echo off

REM Script to run PLUG-QA on 'testEffect.soulpatch' and soul errors on 'errors.soulpatch'
REM results and logs in 'results\'
REM Usage .\runAll.bat 

echo running 'soul errors'
echo:

call soul errors errors.soulpatch
if %errorlevel% neq 0 exit /b %errorlevel%

echo populating 'results'
echo:

cd ..\PLUG-QA
set OUT_DIR=..\tests\results

if exist %OUT_DIR% rmdir %OUT_DIR% /s /q > nul
mkdir %OUT_DIR%
call octave qa.m ..\tests\effect.soulpatch > %OUT_DIR%\qa.log
if %errorlevel% neq 0 exit /b %errorlevel%
del ..\tests\qa.log /s /f /q > nul
xcopy results\* %OUT_DIR% /e /h /y /i /q > nul

echo DONE!
echo: