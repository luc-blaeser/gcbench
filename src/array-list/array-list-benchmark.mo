import Prim "mo:prim";
import Benchmark "../benchmark";
import LimitTest "../limit-test";
import Scenario "canister:array-list-scenario";

actor {
    public shared func benchmark(): async Text {
        Prim.debugPrint("Array List Benchmark");
        await Benchmark.measure(Scenario)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("Array List Limit Test");
        await LimitTest.run(Scenario, 100_000)
    }
}
