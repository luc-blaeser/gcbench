import Prim "mo:prim";
import Runtime "runtime";

import Recorder "canister:recorder";

module {
    public type Operation = (Nat) -> async ();

    public func run(batchSize: Nat, fill: Operation): async Text {
        var limit = 0;
        var heapSize = 0;
        try {
            loop {
                Prim.debugPrint("Limit " # debug_show(limit));
                await fill(batchSize);
                let statistics = Runtime.collectStatistics();
                await Recorder.record(statistics);
                heapSize := statistics.heapSize;
                limit += batchSize
            };
            Prim.trap("Unreachable")
        } catch e {
            Prim.debugPrint("Error " # debug_show(Prim.errorCode(e)) # ":" # Prim.errorMessage(e));
            "Limit, Heap\n" # debug_show(limit) # ", " # debug_show(heapSize) # "\n"
        }
    }
}
