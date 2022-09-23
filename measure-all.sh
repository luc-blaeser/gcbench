#!/usr/bin/env bash

MEASUREMENT_CASES="linked-list array-list rb-tree trie-map blobs graph random-maze extendable-token"
for name in $MEASUREMENT_CASES
do
    ./measure.sh compacting $name
    ./measure.sh copying $name
done
LIMIT_CASES="linked-list array-list rb-tree trie-map blobs"
for name in $LIMIT_CASES
do
    ./limit-test.sh compacting $name
    ./limit-test.sh copying $name
done
util/target/release/report summary reports/
