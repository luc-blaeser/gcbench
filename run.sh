#!/usr/bin/env bash

# Usage: run.sh <compacting|copying> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: run.sh  <compacting|copying> <scenario_name>"
    exit 1
fi
BENCHMARK=$2-benchmark
./compile.sh $1 $BENCHMARK
if [ $? != 0 ]
then
    echo "Compilation failed"
    exit 1
fi
dfx start --clean --background
dfx deploy $BENCHMARK
dfx canister call $BENCHMARK run "()"
if [ $? != 0 ]
then
    echo "Canister call failed"
    dfx stop
    exit 1
fi
dfx stop
