#!/bin/bash

# This script initializes/updates all submodules

git submodule foreach --recursive git pull origin master