import Prim "mo:prim";
import Runtime "runtime";
import RB "base/RBTree";
import O "base/Order";
import Scripting "scripting";

actor class RBTreeScenario() {
    let tree = RB.RBTree<Nat, Nat>(func (x, y) {
        if (x < y) {
            #less
        } else if (x > y) {
            #greater
        } else {
            #equal
        }
    });

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
        tree.clear();
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
}
