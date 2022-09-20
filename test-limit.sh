#!/usr/bin/env bash

# Usage: test-limit.sh <compacting|copying> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: test-limit.sh <compacting|copying> <scenario_name>"
    exit 1
fi
CANISTER=$2-limit-test
./compile.sh $1 $CANISTER
if [ $? != 0 ]
then
    echo "Compilation failed"
    exit 1
fi
OUT_FILE=log/limit-$2-$1.txt
CSV_FILE=reports/limit-$2-$1.csv
dfx start --clean --background
dfx deploy $CANISTER
dfx canister call $CANISTER run "()" | tee $OUT_FILE
if [ $? != 0 ]
then
    echo "Canister call failed"
    dfx stop
    exit 1
fi
dfx stop
awk '/"Limit, Heap/ { gsub("_", ""); gsub("\\(\"", ""); gsub("\")", ""); gsub("\\\\n", "\n"); print }' $OUT_FILE > $CSV_FILE
