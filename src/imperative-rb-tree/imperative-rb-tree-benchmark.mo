import Prim "mo:prim";
import Iter "mo:base/Iter";
import RBTree "imperative-rb-tree";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    var tree = RBTree.empty();
    var total = 0;
    
    func populate(amount: Nat) {
        Prim.debugPrint("Imperative RB tree populate " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            RBTree.insert(tree, total, total);
            total += 1
        }
    };

    func retrieve() {
        Prim.debugPrint("Imperative RB tree retrieve " # debug_show(total));
        for (count in Iter.range(0, total - 1)) {
            let result = RBTree.get(tree, count);
            assert(result == ?count)
        }
    };
    
    func clear() {
        Prim.debugPrint("Imperative RB tree clear");
        tree := RBTree.empty();
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
        Prim.debugPrint("Imperative RB tree benchmark");
        await* Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 10_000;
        Prim.debugPrint("Imperative RB tree limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
