import Prim "mo:prim";
import Runtime "runtime";

module {
    public type Scenario = actor {
        totalSteps: shared () -> async Nat;
        runStep: shared () -> async Runtime.Statistics
    };

    public func measure(scenario: Scenario): async Text {
        let total = await scenario.totalSteps();
        Prim.debugPrint("Running " # debug_show(total) # " steps");
        var log = "Step, " # Runtime.statisticsLegend # "\n";
        var step = 0;
        while (step < total) {
            Prim.debugPrint("Step " # debug_show(step));
            let statistics = await scenario.runStep();
            let values = Runtime.dumpStatistics(statistics);
            Prim.debugPrint(values);
            log #= debug_show(step) # ", " # values # "\n";
            step += 1
        };
        Prim.debugPrint("Completed");
        log
    }
}
