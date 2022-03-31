#!/bin/bash

# NOTE: This script is not thouroughly tested. Please modify to match the behaviour of 'test.bat' as needed.

# Helper script for PLUG-Qa
# Run PLUG-QA on 'testEffect.soulpatch' and save results
# Usage sh ./test.sh

set -e

echo "populating 'results'"
echo ""

cd ../PLUG-QA

OUT_DIR=../tests/results

mkdir -p $OUT_DIR
octave qa.m ../tests/effect.soulpatch > $OUT_DIR/qa.log
rm -rf ../tests/qa.log
cp -R results $OUT_DIR

cd ../tests
