import Prim "mo:prim";
import Benchmark "../benchmark";
import LimitTest "../limit-test";
import Scenario "canister:linked-list-scenario";

actor {
    public shared func benchmark(): async Text {
        Prim.debugPrint("Linked List Benchmark");
        await Benchmark.measure(Scenario)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("Linked List Limit Test");
        await LimitTest.run(Scenario, 100_000)
    }
}
