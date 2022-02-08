#!/bin/bash

# This script initializes/updates all submodules

git submodule foreach git pull origin master
git submodule foreach git submodule update --init --recursive
chmod +x ./PLUG-QA/SameWav/builds/SameWav.app

cd ./PLUG-QA
octave qaClear.m