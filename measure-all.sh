#!/usr/bin/env bash

PERFORMANCE_CASES="linked-list buffer rb-tree trie-map blobs graph random-maze extendable-token asset-storage qr-code reversi sha256 cancan"
for name in $PERFORMANCE_CASES
do
    if [ "$MOC_NO_GC_PATH" ]
    then
        ./performance.sh no $name    
    fi
    ./performance.sh compacting $name
    ./performance.sh copying $name
done
LIMIT_CASES="linked-list buffer rb-tree trie-map blobs"
for name in $LIMIT_CASES
do
    if [ "$MOC_NO_GC_PATH" ]
    then
       ./limit.sh no $name    
    fi
    ./limit.sh compacting $name
    ./limit.sh copying $name
done
cp style.css reports/
util/target/release/report summary reports/
