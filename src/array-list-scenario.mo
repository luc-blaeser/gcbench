import Prim "mo:prim";
import Runtime "runtime";
import Collections "collections";
import Scripting "scripting";

actor class ArrayListScenario() {
    let list = Collections.ArrayList<[var Nat]>();

    func populate(amount: Nat) {
        Prim.debugPrint("Array list populate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            let item = Prim.Array_init<Nat>(4096, 0);
            list.add(item);
            count += 1
        }
    };

    func traverse() {
        Prim.debugPrint("Array list traverse " # debug_show(list.size()));
        for (value in list.elements()) {
            ignore value
        }
    };

    func clear() {
        Prim.debugPrint("Array list clear");
        list.clear()
    };
    
    let script = Scripting.Script([
        ( 10, func() { populate(1000) } ),
        ( 5, func() { traverse() } ),
        ( 1, func() { clear() } ),
        ( 20, func() { populate(1000) } ),
        ( 5, func() { traverse() } ),
        ( 1, func() { clear() } ),
        ( 29, func() { populate(1000) } ),
        ( 5, func() { traverse() } )
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
