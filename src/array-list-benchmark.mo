import Prim "mo:prim";
import Benchmark "benchmark";
import Scenario "array-list-scenario";

actor ArrayListBenchmark {
    public shared func run(): async Text {
        Prim.debugPrint("Array List Benchmark");
        Prim.cyclesAdd(2_000_000_000_000);
        let scenario = await Scenario.ArrayListScenario();
        await Benchmark.measure(scenario)
    };
}
