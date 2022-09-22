import Prim "mo:prim";
import Collections "../collections";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    let list = Collections.ArrayList<Nat>();

    func populate(amount: Nat) {
        Prim.debugPrint("Array list populate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            list.add(count);
            count += 1
        }
    };

    func traverse() {
        Prim.debugPrint("Array list traverse " # debug_show(list.size()));
        for (value in list.elements()) {
            ignore value
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("Array list discard last " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            ignore list.remove(list.size() - 1);
            count += 1
        }
    };

    func clear() {
        Prim.debugPrint("Array list clear");
        list.clear()
    };

    let script = [
        ( 50, func() { populate(100_000) } ),
        ( 10, func() { traverse() } ),
        ( 25, func() { discard(100_000) } ),
        ( 10, func() { traverse() } ),
        ( 25, func() { populate(100_000) } ),
        ( 1, func() { clear() } ),
        ( 50, func() { populate(100_000) } ),
        ( 10, func() { traverse() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Array list benchmark");
        await Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 100_000;
        Prim.debugPrint("Array list limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
