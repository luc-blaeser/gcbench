import Prim "mo:prim";
import Runtime "../runtime";
import Collections "../collections";
import Scripting "../scripting";

actor {
    let list = Collections.LinkedList<Nat>();

    func populate(amount: Nat) {
        Prim.debugPrint("Linked list populate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            list.append(amount);
            count += 1
        }
    };

    func traverse() {
        Prim.debugPrint("Linked list traverse " # debug_show(list.size()));
        for (value in list.elements()) {
            ignore value
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("Linked list discard " # debug_show(list.size()));
        var count = 0;
        while (count < amount) {
            ignore list.remove();
            count += 1
        }
    };

    func clear() {
        Prim.debugPrint("Linked list clear");
        list.clear()
    };

    let script = Scripting.Script([
        ( 50, func() { populate(100_000) } ),
        ( 10, func() { traverse() } ),
        ( 25, func() { discard(100_000) } ),
        ( 10, func() { traverse() } ),
        ( 25, func() { populate(100_000) } ),
        ( 1, func() { clear() } ),
        ( 50, func() { populate(100_000) } ),
        ( 10, func() { traverse() } )
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
