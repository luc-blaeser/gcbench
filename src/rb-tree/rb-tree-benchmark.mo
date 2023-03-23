import Prim "mo:prim";
import Iter "mo:base/Iter";
import RBBase "mo:base/RBTree";
import NatBase "mo:base/Nat";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    var tree = RBBase.RBTree<Nat, Nat>(NatBase.compare);

    var total = 0;

    func populate(amount: Nat) {
        Prim.debugPrint("RB tree populate " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            tree.put(total, total);
            total += 1
        }
    };

    func retrieve() {
        Prim.debugPrint("RB tree retrieve " # debug_show(total));
        for (count in Iter.range(0, total - 1)) {
            let result = tree.get(count);
            assert(result == ?count)
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("RB tree discard " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            total -= 1;
            ignore tree.remove(total)
        }
    };

    func clear() {
        Prim.debugPrint("RB tree clear");
        tree := RBBase.RBTree<Nat, Nat>(NatBase.compare);
        total := 0
    };

    let script = [
        ( 20, func() { populate(10_000) } ),
        ( 5, func() { retrieve() } ),
        ( 10, func() { discard(10_000) } ),
        ( 5, func() { retrieve() } ),
        ( 10, func() { populate(10_000) } ),
        ( 1, func() { clear() } ),
        ( 20, func() { populate(10_000) } ),
        ( 5, func() { retrieve() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("RB tree benchmark");
        await Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 2_500;
        Prim.debugPrint("RB tree limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
