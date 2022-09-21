import Prim "mo:prim";
import Runtime "runtime";

actor {
    var log = "Step, " # Runtime.statisticsLegend # "\n";
    var step = 0;

    public func record(statistics: Runtime.Statistics): async () {
        Prim.debugPrint("Step " # debug_show(step));
        let values = Runtime.dumpStatistics(statistics);
        Prim.debugPrint(values);
        log #= debug_show(step) # ", " # values # "\n";
        step += 1
    };

    public func result(): async Text {
        log
    }
}
