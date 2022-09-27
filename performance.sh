#!/usr/bin/env bash

# Usage: performance.sh <compacting|copying|no> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: performance.sh <compacting|copying|no> <scenario_name>"
    exit 1
fi
mkdir -p log
mkdir -p reports
OUT_FILE=log/out-$2-$1.txt
CSV_FILE=reports/performance-$2-$1.csv
CHART_FILE=reports/chart-$2-$1.html
./run.sh $1 performance $2 | tee $OUT_FILE
if [ $? != 0 ]
then
    echo "Performance measurement failed"
    exit 1
fi
awk '/"Step, Memory/ { gsub("_", ""); gsub("\",", ""); gsub("  \"", ""); gsub("\\\\n", "\n"); print }' $OUT_FILE > $CSV_FILE
util/target/release/report chart $CSV_FILE $CHART_FILE
