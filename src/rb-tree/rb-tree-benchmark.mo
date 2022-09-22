import Prim "mo:prim";
import RBBase "mo:base/RBTree";
import NatBase "mo:base/Nat";

import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    let tree = RBBase.RBTree<Nat, Nat>(NatBase.compare);

    var total = 0;

    func populate(amount: Nat) {
        Prim.debugPrint("RB tree populate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            tree.put(total, total);
            count += 1;
            total += 1
        }
    };

    func retrieve() {
        Prim.debugPrint("RB tree retrieve " # debug_show(total));
        var count = 0;
        while (count < total) {
            let result = tree.get(count);
            assert(result == ?count);
            count += 1
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("RB tree discard " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            total -= 1;
            ignore tree.remove(total);
            count += 1
        }
    };

    func deleteAll() {
        Prim.debugPrint("RB tree delete all");
        for ((key, value) in tree.entries()) {
            tree.delete(key);
        };
        total := 0
    };

    let script = [
        ( 30, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 20, func() { discard(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 20, func() { populate(10_000) } ),
        ( 1, func() { deleteAll() } ),
        ( 40, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("RB tree benchmark");
        await Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 10_000;
        Prim.debugPrint("RB tree limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
