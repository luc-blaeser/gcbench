import Prim "mo:prim";
import Collections "collections";
import Runtime "runtime";
import Scenario "linked-list-scenario";

actor LinkedListLimitTest {
    public shared func run(): async Text {
        Prim.debugPrint("Linked List Limit Test");
        Prim.cyclesAdd(2_000_000_000_000);
        let scenario = await Scenario.LinkedListScenario();
        let batchSize = 100_000;
        var limit = 0;
        var heapSize = 0;
        try {
            loop {
                Prim.debugPrint("Limit " # debug_show(limit));
                let statistics = await scenario.fill(batchSize);
                heapSize := statistics.heapSize;
                Prim.debugPrint(Runtime.dumpStatistics(statistics));
                limit += batchSize
            };
            Prim.trap("Unreachable")
        } catch e {
            Prim.debugPrint("Error " # debug_show(Prim.errorCode(e)) # ":" # Prim.errorMessage(e));
            "Limit, Heap\n" # debug_show(limit) # ", " # debug_show(heapSize) # "\n"
        }
    }
}
