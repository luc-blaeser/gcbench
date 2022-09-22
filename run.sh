#!/usr/bin/env bash

# Usage: run.sh <compacting|copying> <benchmark|limit-test> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
    echo "Usage: run.sh <compacting|copying> <benchmark|limit> <scenario_name>"
    exit 1
fi
if [ "$1" != "compacting" ] && [ "$1" != "copying" ]
then
    echo "First argument must be 'compacting' or 'copying'"
    exit 1
fi
if [ "$2" != "benchmark" ] && [ "$2" != "limit" ]
then
    echo "Second argument must be 'benchmark' or 'limit'"
    exit 1
fi
if [ "$2" == "benchmark" ]
then
    DFXTEMPLATE=benchmark-dfx.json
    CANISTER=benchmark
else 
    DFXTEMPLATE=limit-test-dfx.json
    CANISTER=limit-tester
fi
awk '// {gsub("#SCENARIO#", "'$3'"); gsub("#GCFLAG#", "--'$1'-gc"); print }' $DFXTEMPLATE > dfx.json
dfx start --clean --background
dfx deploy
dfx canister call $CANISTER run "()"
if [ $? != 0 ]
then
    echo "Canister call failed"
    dfx stop
    exit 1
fi
dfx stop
rm dfx.json
