#!/bin/bash

# This script initializes/updates all submodules
git submodule update --init --recursive
git submodule foreach --recursive git pull origin master