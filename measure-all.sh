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
GC_MODES="compacting copying no generational"
PERFORMANCE_CASES="linked-list buffer rb-tree trie-map blobs imperative-rb-tree graph random-maze game-of-life extendable-token asset-storage qr-code reversi sha256 cancan"
for name in $PERFORMANCE_CASES
do
    for gc in $GC_MODES
    do
        ./performance.sh $gc $name
    done    
done
LIMIT_CASES="linked-list buffer rb-tree trie-map blobs imperative-rb-tree"
for name in $LIMIT_CASES
do
    for gc in $GC_MODES
    do
        ./limit.sh $gc $name 
    done
done
cp style.css reports/
util/target/release/report summary reports/
