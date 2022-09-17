#!/usr/bin/env bash

# Usage: measure.sh <compacting|copying> <scenario_name>

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: measure.sh  <compacting|copying> <scenario_name>"
    exit 1
fi
mkdir -p log
mkdir -p reports
OUT_FILE=log/out-$2-$1.txt
CSV_FILE=reports/measurement-$2-$1.csv
CHART_FILE=reports/chart-$2-$1.html
./run.sh $1 $2 | tee $OUT_FILE
awk '/"Step, Memory/ { gsub("_", ""); gsub("\",", ""); gsub("  \"", ""); gsub("\\\\n", "\n"); print }' $OUT_FILE > $CSV_FILE
util/target/release/report chart $CSV_FILE $CHART_FILE
