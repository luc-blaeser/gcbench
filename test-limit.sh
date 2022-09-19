#!/usr/bin/env bash

# Usage: test-limit.sh <compacting|copying> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: test-limit.sh  <compacting|copying> <scenario_name>"
    exit 1
fi
./compile.sh $1 limit-test
OUT_FILE=log/limit-$2-$1.txt
CSV_FILE=reports/limit-$2-$1.csv
if [ $? != 0 ]
then
    echo "Compilation failed"
    exit 1
fi
dfx start --clean --background
dfx deploy limit-test
dfx canister call limit-test run "(\"$2\")" | tee $OUT_FILE
if [ $? != 0 ]
then
    echo "Canister call failed"
    dfx stop
    exit 1
fi
dfx stop
awk '/"Limit, Heap/ { gsub("_", ""); gsub("\\(\"", ""); gsub("\")", ""); gsub("\\\\n", "\n"); print }' $OUT_FILE > $CSV_FILE
