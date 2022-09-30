#!/usr/bin/env bash

cd util
cargo build --release
if [ $? != 0 ]
then
    cd ..
    echo "Failed to build the report tool"
    exit 1
fi
cd ..
PERFORMANCE_CASES="linked-list buffer rb-tree trie-map blobs imperative-rb-tree graph random-maze game-of-life extendable-token asset-storage qr-code reversi sha256 cancan"
for name in $PERFORMANCE_CASES
do
    if [ "$MOC_NO_GC_PATH" ]
    then
        ./performance.sh no $name    
    fi
    if [ "$MOC_EXPERIMENTAL_GC_PATH" ]
    then
        ./performance.sh experimental $name    
    fi
    ./performance.sh compacting $name
    ./performance.sh copying $name
done
LIMIT_CASES="linked-list buffer rb-tree trie-map blobs imperative-rb-tree"
for name in $LIMIT_CASES
do
    if [ "$MOC_NO_GC_PATH" ]
    then
       ./limit.sh no $name    
    fi
    if [ "$MOC_EXPERIMENTAL_GC_PATH" ]
    then
        ./limit.sh experimental $name    
    fi
    ./limit.sh compacting $name
    ./limit.sh copying $name
done
cp style.css reports/
util/target/release/report summary reports/
