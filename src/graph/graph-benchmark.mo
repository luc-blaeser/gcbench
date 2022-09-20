import Prim "mo:prim";
import Benchmark "../benchmark";
import Scenario "canister:graph-scenario";

actor {
    public shared func benchmark(): async Text {
        Prim.debugPrint("Graph Benchmark");
        await Benchmark.measure(Scenario)
    }
}
