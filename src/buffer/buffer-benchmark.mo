import Prim "mo:prim";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    let buffer = Buffer.Buffer<Nat>(8);

    func populate(amount: Nat) {
        Prim.debugPrint("Buffer populate " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            buffer.add(count)
        }
    };

    func traverse() {
        Prim.debugPrint("Buffer traverse " # debug_show(buffer.size()));
        for (value in buffer.vals()) {
            ignore value
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("Buffer discard " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            ignore buffer.removeLast()
        }
    };

    func clear() {
        Prim.debugPrint("Buffer clear");
        buffer.clear()
    };

    let script = [
        ( 50, func() { populate(100_000) } ),
        ( 10, func() { traverse() } ),
        ( 25, func() { discard(100_000) } ),
        ( 10, func() { traverse() } ),
        ( 25, func() { populate(100_000) } ),
        ( 1, func() { clear() } ),
        ( 45, func() { populate(100_000) } ),
        ( 10, func() { traverse() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Buffer benchmark");
        await* Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 100_000;
        Prim.debugPrint("Buffer limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
