#!/bin/bash

# NOTE: This script is not thouroughly tested. Please modify to match the behaviour of 'runAll.bat' as needed.

# Script to run PLUG-QA on 'testEffect.soulpatch' and soul errors on 'errors.soulpatch'
# results and logs in './results/'
# Usage sudo ./runAll.sh <Fs>

set -e

# parse arguments

FS="$1" 

# soul errors errors.soulpatch

soul errors errors.soulpatch

# PLUG-QA

cd ../PLUG-QA

OUT_DIR=../tests/results

mkdir -p $OUT_DIR
octave qa.m ../tests/effect.soulpatch > $OUT_DIR/qa.log
rm -rf ../tests/qa.log
cp -R results $OUT_DIR

cd ../tests
