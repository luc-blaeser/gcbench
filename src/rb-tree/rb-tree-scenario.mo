import Prim "mo:prim";
import Runtime "../runtime";
import Scripting "../scripting";
import RBBase "mo:base/RBTree";
import NatBase "mo:base/Nat";

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

    func clear() {
        Prim.debugPrint("Linked list clear");
        for ((key, value) in tree.entries()) {
            tree.delete(key);
        };
        total := 0
    };

    let script = Scripting.Script([
        ( 30, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 20, func() { discard(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 20, func() { populate(10_000) } ),
        ( 1, func() { clear() } ),
        ( 40, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } )
    ]);

    public shared func totalSteps(): async Nat {
        script.length()
    };

    public shared func runStep(): async Runtime.Statistics {
        let operation = script.next();
        operation();
        Runtime.collectStatistics()
    };

    public shared func fill(amount: Nat): async Runtime.Statistics {
        populate(amount);
        Runtime.collectStatistics()
    }
}
