#!/bin/bash

# TODO finished this script

set -e

soul errors errors.soulpatch

cd ../PLUG-QA
octave qaScript.m ../tests/effect.soulpatch 44100
