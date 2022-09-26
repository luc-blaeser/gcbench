import Prim "mo:prim";
import SHA256 "../perf/sha256";
import Benchmark "../benchmark";

actor {
    let script = [
        ( 10, func() { SHA256.go() } ),
    ];

    public shared func run(): async Text {
        Prim.debugPrint("SHA 256 (Motoko perf test) benchmark");
        await Benchmark.measure(script)
    };
}
