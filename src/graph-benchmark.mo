import Prim "mo:prim";
import Benchmark "benchmark";
import Scenario "graph-scenario";

actor GraphBenchmark {
    public shared func run(): async Text {
        Prim.debugPrint("Graph Benchmark");
        Prim.cyclesAdd(2_000_000_000_000);
        let scenario = await Scenario.GraphScenario();
        await Benchmark.measure(scenario)
    };
}
