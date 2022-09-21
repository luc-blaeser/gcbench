import Prim "mo:prim";
import Runtime "runtime";

module {
    public type Operation = (Nat) -> async ();

    public func run(batchSize: Nat, heapReserve: Nat, fill: Operation): async Text {
        let heapMax = 4 * 1024 * 1024 * 1024;
        var limit = 0;
        var heapSize = 0;
        try {
            loop {
                Prim.debugPrint("Limit " # debug_show(limit));
                await fill(batchSize);
                let statistics = Runtime.collectStatistics();
                Prim.debugPrint(Runtime.dumpStatistics(statistics));
                heapSize := statistics.heapSize;
                if (heapSize + heapReserve >= heapMax) {
                    Prim.debugPrint("Specific heap maximum reached");
                    return result(limit, heapSize)
                };
                limit += batchSize
            };
            Prim.trap("Unreachable")
        } catch e {
            Prim.debugPrint("Error " # debug_show(Prim.errorCode(e)) # ":" # Prim.errorMessage(e));
            result(limit, heapSize)
        }
    };

    func result(limit: Nat, heapSize: Nat): Text {
        "Limit, Heap\n" # debug_show(limit) # ", " # debug_show(heapSize) # "\n"
    }
}
