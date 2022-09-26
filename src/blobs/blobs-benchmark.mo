import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    let buffer = Buffer.Buffer<Blob>(8);

    let blockSize = 65536;
    let headerSize = 8;

    ignore Prim.stableMemoryGrow(1);

    func allocate(amount: Nat) {
        Prim.debugPrint("Blobs allocate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            let item = Prim.stableMemoryLoadBlob(0, blockSize - headerSize);
            buffer.add(item);
            count += 1
        }
    };

    func traverse() {
        Prim.debugPrint("Blobs traverse " # debug_show(buffer.size()));
        for (value in buffer.vals()) {
            ignore value
        }
    };

    func discardAll() {
        Prim.debugPrint("Blobs discard all");
        buffer.clear()
    };
    
    let script = [
        ( 10, func() { allocate(1000) } ),
        ( 5, func() { traverse() } ),
        ( 1, func() { discardAll() } ),
        ( 24, func() { allocate(1000) } ),
        ( 5, func() { traverse() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Blobs benchmark");
        await Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 1000;
        Prim.debugPrint("Blobs limit test " # debug_show(amount));
        allocate(amount);
        (amount, Runtime.collectStatistics())
    }
}
