#!/usr/bin/env bash

# Usage: run.sh <compacting|copying|no|generational|incremental> <performance|limit> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
    echo "Usage: run.sh <compacting|copying|no|generational|incremental> <performance|limit> <scenario_name>"
    exit 1
fi
if [ "$1" != "compacting" ] && [ "$1" != "copying" ] && [ "$1" != "no" ] && [ "$1" != "generational" ] && [ "$1" != "incremental" ]
then
    echo "First argument must be 'compacting', 'copying', 'no', 'generational', or 'incremental'"
    exit 1
fi
if [ "$2" != "performance" ] && [ "$2" != "limit" ]
then
    echo "Second argument must be 'performance' or 'limit'"
    exit 1
fi
GC_FLAG=--$1-gc
if [ "$2" == "performance" ]
then
    DFXTEMPLATE=performance-dfx.json
    CANISTER=benchmark
else
    DFXTEMPLATE=limit-dfx.json
    CANISTER=limit-tester
fi
awk '// {gsub("#SCENARIO#", "'$3'"); gsub("#GCFLAG#", "'$GC_FLAG'"); print }' $DFXTEMPLATE > dfx.json
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
