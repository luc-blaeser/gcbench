import Prim "mo:prim";
import Benchmark "../benchmark";
import LimitTest "../limit-test";
import Scenario "canister:trie-map-scenario";

actor {
    public shared func benchmark(): async Text {
        Prim.debugPrint("Trie Map Benchmark");
        await Benchmark.measure(Scenario)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("Trie Map Limit Test");
        await LimitTest.run(Scenario, 10_000)
    }
}
