@echo off

soul errors errors.soulpatch
if %errorlevel% neq 0 exit /b %errorlevel%

cd ../PLUG-QA
octave qaScript.m ../tests/effect.soulpatch 44100
if %errorlevel% neq 0 exit /b %errorlevel%