@echo off

REM Helper script for PLUG-QA
REM Run PLUG-QA on `effect.soulpatch` and save results
REM Usage .\test.bat 

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

cd ..\tests

echo DONE!
echo: