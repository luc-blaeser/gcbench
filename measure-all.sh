#!/usr/bin/env bash

MEASUREMENT_CASES="linked-list buffer rb-tree trie-map blobs graph random-maze extendable-token asset-storage qr-code reversi sha256 cancan"
for name in $MEASUREMENT_CASES
do
    if [ "$MOC_NO_GC_PATH" ]
    then
        ./measure.sh none $name    
    fi
    ./measure.sh compacting $name
    ./measure.sh copying $name
done
LIMIT_CASES="linked-list buffer rb-tree trie-map blobs"
for name in $LIMIT_CASES
do
    if [ "$MOC_NO_GC_PATH" ]
    then
       ./limit-test.sh none $name    
    fi
    ./limit-test.sh compacting $name
    ./limit-test.sh copying $name
done
util/target/release/report summary reports/
