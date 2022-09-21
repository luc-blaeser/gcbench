import Prim "mo:prim";
import Collections "../collections";
import Benchmark "../benchmark";
import LimitTest "../limit-test";

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
    
    let script = [
        ( 10, func() { allocate(1000) } ),
        ( 5, func() { traverse() } ),
        ( 1, func() { discardAll() } ),
        ( 24, func() { allocate(1000) } ),
        ( 5, func() { traverse() } )
    ];

    public shared func benchmark(): async Text {
        Prim.debugPrint("Blobs benchmark");
        await Benchmark.measure(script)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("Blobs limit test");
        let heapReserve = 750 * 1024 * 1024;
        await LimitTest.run(1_000, heapReserve, func (amount: Nat): async () { allocate(amount) })
    }
}
