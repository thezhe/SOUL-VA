#!/bin/bash

# NOTE: This script is not thouroughly tested. Please modify to match the behaviour of 'test.bat' as needed.

# Script to run soul errors on 'errors.soulpatch' and PLUG-QA on 'testEffect.soulpatch'
# results and logs in './results/'
# Usage sh ./test.sh

set -e

echo "running 'soul errors'"
echo ""

soul errors errors.soulpatch

echo "populating 'results'"
echo ""

cd ../PLUG-QA

OUT_DIR=../tests/results

mkdir -p $OUT_DIR
octave qa.m ../tests/effect.soulpatch > $OUT_DIR/qa.log
rm -rf ../tests/qa.log
cp -R results $OUT_DIR

cd ../tests
