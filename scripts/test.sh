#!/bin/bash

# NOTE: This script is not thouroughly tested. Please modify to match the behaviour of 'test.bat' as needed.

# Helper script for PLUG-Qa
# Run PLUG-QA on 'testEffect.soulpatch' and save results
# Usage sh ./test.sh

set -e

echo "populating 'results'"
echo ""

CALLERDIR=$PWD
BASEDIR=$(dirname "$0")

QADIR="$BASEDIR"/../PLUG-QA
TESTDIR="$BASEDIR"/../tests
RESULTDIR="$BASEDIR"/../results

cd $QADIR

mkdir -p $RESULTDIR
octave qa.m $TESTDIR/effect.soulpatch > $RESULTDIR/qa.log
rm -rf $RESULTDIR/qa.log
cp -R results $RESULTDIR

cd $CALLERDIR
