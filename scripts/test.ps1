# Helper script for PLUG-QA
# Run PLUG-QA on `effect.soulpatch` and save results
# Usage .\test.ps1 

$CallerDir=(Get-Item .).FullName
$BaseDir="$PSScriptRoot"

$QADir="$BaseDir\..\PLUG-QA"

Set-Location $QADir

$TestDir="..\tests"
$ResultDir="..\results"

$null=Remove-Item -Path $ResultDir -Recurse -Force -Confirm:$false
$null=New-Item -Path $ResultDir -ItemType "directory"
octave qa.m "$TestDir\effect.soulpatch" > $ResultDir/qa.log
if ($LastExitCode -ne 0) {
    Set-Location $CallerDir
    exit $LastExitCode
}

$null=Remove-Item $ResultDir/qa.log -Recurse -Force -Confirm:$false
$null=Copy-Item results\* -Destination $ResultDir -Recurse -Force

Set-Location $CallerDir