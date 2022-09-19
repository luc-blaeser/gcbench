import Prim "mo:prim";
import Collections "collections";
import Runtime "runtime";
import Scenario1 "linked-list-scenario";
import Scenario2 "array-list-scenario";
import Scenario3 "graph-scenario";
import Scenario4 "rb-tree-scenario"

actor LinkedListLimitTest {
    public shared func run(scenarioName: Text): async Text {
        Prim.debugPrint("Limit test");
        Prim.cyclesAdd(2_000_000_000_000);
        let (creation, batchSize) = 
            if (scenarioName == "linked-list") {
                (Scenario1.LinkedListScenario, 100_000)
            } else if (scenarioName == "array-list") {
                (Scenario2.ArrayListScenario, 1000)
            } else if (scenarioName == "graph") {
                (Scenario3.GraphScenario, 100)
            } else if (scenarioName == "rb-tree") {
                (Scenario4.RBTreeScenario, 10_000)
            } else {
                Prim.trap("Undefined scenario name")
            };
        let scenario = await creation();
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
