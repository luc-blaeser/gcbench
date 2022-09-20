import Prim "mo:prim";
import Runtime "../runtime";
import Collections "../collections";
import Scripting "../scripting";

actor {
    let list = Collections.ArrayList<Blob>();

    let block_size = 65536;
    let header_size = 8;

    ignore Prim.stableMemoryGrow(1);

    func allocate(amount: Nat) {
        Prim.debugPrint("Blobs allocate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            let item = Prim.stableMemoryLoadBlob(0, block_size - header_size);
            list.add(item);
            count += 1
        }
    };

    func traverse() {
        Prim.debugPrint("Blobs traverse " # debug_show(list.size()));
        for (value in list.elements()) {
            ignore value
        }
    };

    func discardAll() {
        Prim.debugPrint("Blobs discard all");
        list.clear()
    };
    
    let script = Scripting.Script([
        ( 10, func() { allocate(1000) } ),
        ( 5, func() { traverse() } ),
        ( 1, func() { discardAll() } ),
        ( 24, func() { allocate(1000) } ),
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
        allocate(amount);
        Runtime.collectStatistics()
    }
}