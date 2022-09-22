import Prim "mo:prim";
import Runtime "runtime";

import Benchmark "canister:benchmark";

actor {
    public shared func run(): async Text {
        var limit = 0;
        var heapSize = 0;
        try {
            loop {
                Prim.debugPrint("Limit " # debug_show(limit));
                let (amount, statistics) = await Benchmark.limitTest();
                Prim.debugPrint(Runtime.dumpStatistics(statistics));
                heapSize := statistics.heapSize;
                limit += amount
            };
            Prim.trap("Unreachable")
        } catch e {
            Prim.debugPrint("Error " # debug_show(Prim.errorCode(e)) # ":" # Prim.errorMessage(e));
            "Limit, Heap\n" # debug_show(limit) # ", " # debug_show(heapSize) # "\n"
        }
    }
}
