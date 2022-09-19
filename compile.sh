#!/usr/bin/env bash

# Usage: compile.sh <compacting|copying> <file_name_without_extension>

if [ -z "$2" ] || [ -z "$2" ]
then
    echo "Usage: compile.sh  <compacting|copying> <file_name_without_extension>"
    exit 1
fi
if [ "$1" = "compacting" ]
then
    gcflag=--compacting-gc
else 
    if [ "$1" = "copying" ]
    then
        gcflag=--copying-gc
    else
        echo "First argument must be 'compacting' or 'copying'"
        exit 1
    fi
fi
mkdir -p build
SOURCE_FILE=src/$2.mo
OUTPUT_FILE=build/$2.wasm
moc $gcflag --idl -o $OUTPUT_FILE $SOURCE_FILE
if [ $? != 0 ]
then
    echo "Compilation failed"
    dfx stop
    exit 1
fi
gzip -f $OUTPUT_FILE
