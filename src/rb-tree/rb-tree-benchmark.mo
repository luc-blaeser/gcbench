import Prim "mo:prim";
import Benchmark "../benchmark";
import LimitTest "../limit-test";
import Scenario "canister:rb-tree-scenario";

actor {
    public shared func benchmark(): async Text {
        Prim.debugPrint("RB Tree Benchmark");
        await Benchmark.measure(Scenario)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("RB Tree Limit Test");
        await LimitTest.run(Scenario, 10_000)
    }
}
