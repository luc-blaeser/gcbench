import Prim "mo:prim";
import Benchmark "benchmark";
import Scenario "linked-list-scenario";

actor LinkedListBenchmark {
    public shared func run(): async Text {
        Prim.debugPrint("Linked List Benchmark");
        Prim.cyclesAdd(2_000_000_000_000);
        let scenario = await Scenario.LinkedListScenario();
        await Benchmark.measure(scenario)
    }
}
