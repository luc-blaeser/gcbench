import Prim "mo:prim";
import Runtime "runtime";
import Buffer "mo:base/Buffer";

actor {
    let initalCapacity = 100;
    var buffer = Buffer.Buffer<Runtime.Statistics>(initalCapacity);

    var log = "Step, " # Runtime.statisticsLegend # "\n";
    var step = 0;

    public func record(statistics: Runtime.Statistics): async () {
        buffer.add(statistics);
        Prim.debugPrint("Step " # debug_show(step));
        let values = Runtime.dumpStatistics(statistics);
        Prim.debugPrint(values);
        log #= debug_show(step) # ", " # values # "\n";
        step += 1
    };

    public func get(index: Nat): async ?Runtime.Statistics {
        if (index < buffer.size()) {
            ?buffer.get(index)
        } else {
            null
        }
    };

    public func result(): async Text {
        log
    }
}
