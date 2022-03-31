# This script initializes/updates all submodules

$CallerDir = (Get-Item .).FullName

Set-Location $PSScriptRoot/..

git submodule foreach git pull origin master
git submodule foreach git submodule update --init --recursive

Set-Location PLUG-QA

octave qaClear.m

Set-Location $CallerDir