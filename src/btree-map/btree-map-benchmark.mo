import Prim "mo:prim";
import Nat "mo:base/Nat";
import BTree "canscale-btree/BTree";
import Iter "mo:base/Iter";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    let Order = 256;

    var tree = do {
        BTree.init<Nat, Nat>(Order)
    };

    var total = 0;

    func populate(amount: Nat) {
        Prim.debugPrint("BTree populate " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            let result = BTree.insert(tree, Nat.compare, total, total);
            assert(result == null);
            total += 1;
        }
    };

    func retrieve() {
        Prim.debugPrint("BTree retrieve " # debug_show(total));
        for (count in Iter.range(0, total - 1)) {
            let result = BTree.get(tree, Nat.compare, count);
            assert(result == ?count)
        }
    };

    func clear() {
        Prim.debugPrint("BTree clear");
        tree := BTree.init<Nat, Nat>(Order);
        total := 0
    };

    let script = [
        ( 30, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 1, func() { clear() } ),
        ( 40, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("BTree benchmark");
        await Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 100_000;
        Prim.debugPrint("BTree limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
