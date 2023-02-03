import Prim "mo:prim";
import Runtime "runtime";
import Buffer "mo:base/Buffer";

actor {
    let initalCapacity = 250;
    var buffer = Buffer.Buffer<Runtime.Statistics>(initalCapacity);

    public func record(statistics: Runtime.Statistics): async () {
        Prim.debugPrint("Step " # debug_show(buffer.size()));
        let values = Runtime.dumpStatistics(statistics);
        Prim.debugPrint(values);
        buffer.add(statistics);
    };

    public func state(): async [Runtime.Statistics] {
        Buffer.toArray(buffer)
    };

    public func result(): async Text {
        var text = "Step, " # Runtime.statisticsLegend # "\n";
        var step = 0;
        for (statistics in buffer.vals()) {
            let values = Runtime.dumpStatistics(statistics);
            text #= debug_show(step) # ", " # values # "\n";
            step += 1
        };
        text
    }
}
