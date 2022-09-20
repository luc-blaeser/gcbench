import Prim "mo:prim";
import Benchmark "benchmark";
import Scenario "blobs-scenario";

actor BlobsBenchmark {
    public shared func run(): async Text {
        Prim.debugPrint("Blobs Benchmark");
        Prim.cyclesAdd(2_000_000_000_000);
        let scenario = await Scenario.BlobsScenario();
        await Benchmark.measure(scenario)
    };
}
