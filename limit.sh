#!/usr/bin/env bash

# Usage: limit.sh <compacting|copying|no> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: limit.sh <compacting|copying|no> <scenario_name>"
    exit 1
fi
mkdir -p log
mkdir -p reports
OUT_FILE=log/limit-$2-$1.txt
CSV_FILE=reports/limit-$2-$1.csv
./run.sh $1 limit $2 | tee $OUT_FILE
if [ $? != 0 ]
then
    echo "Limit test failed"
    exit 1
fi
awk '/"Limit, Heap/ { gsub("_", ""); gsub("\\(\"", ""); gsub("\")", ""); gsub("\\\\n", "\n"); print }' $OUT_FILE > $CSV_FILE
