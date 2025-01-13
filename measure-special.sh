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
GC_MODES="classical eop"
PERFORMANCE_CASES="btree-map hash-map imperative-rb-tree ordered-map rb-tree trie-map buffer scalable-buffer vector"
for name in $PERFORMANCE_CASES
do
    for gc in $GC_MODES
    do
        ./performance.sh $gc $name
    done    
done
cp style.css reports/
cp display.js reports/
util/target/release/report summary reports/
