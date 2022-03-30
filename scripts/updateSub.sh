#!/bin/bash

# This script initializes/updates all submodules

CALLERDIR=$PWD
BASEDIR=$(dirname "$0")

cd "$BASEDIR"/..

git submodule foreach git pull origin master
git submodule foreach git submodule update --init --recursive

cd ./PLUG-QA

octave qaClear.m

cd $CALLERDIR