import Prim "mo:prim";
import Benchmark "benchmark";
import Scenario "rb-tree-scenario";

actor RBTreeBenchmark {
    public shared func run(): async Text {
        Prim.debugPrint("RB Tree Benchmark");
        Prim.cyclesAdd(2_000_000_000_000);
        let scenario = await Scenario.RBTreeScenario();
        await Benchmark.measure(scenario)
    };
}
