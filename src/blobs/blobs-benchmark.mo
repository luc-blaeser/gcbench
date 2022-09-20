import Prim "mo:prim";
import Benchmark "../benchmark";
import LimitTest "../limit-test";
import Scenario "canister:blobs-scenario";

actor {
    public shared func benchmark(): async Text {
        Prim.debugPrint("Blobs Benchmark");
        await Benchmark.measure(Scenario)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("Blobs Limit Test");
        await LimitTest.run(Scenario, 1_000)
    }
}
