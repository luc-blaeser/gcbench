#!/usr/bin/env bash

CASES="linked-list array-list graph rb-tree"
for name in $CASES
do
    ./measure.sh compacting $name
    ./measure.sh copying $name
    ./test-limit.sh compacting $name
    ./test-limit.sh copying $name
done
util/target/release/report summary reports/
