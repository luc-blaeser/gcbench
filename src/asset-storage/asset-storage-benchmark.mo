import Prim "mo:prim";
import AssetStorage "../perf/assetstorage";
import Trace "../trace";

actor {
    public shared func run(): async Text {
        Prim.debugPrint("Asset storage (Motoko perf test) benchmark");
        let pages = 16;
        ignore Prim.stableMemoryGrow(Prim.natToNat64(pages));
        Prim.cyclesAdd(200_000_000_000); 
        let test = await AssetStorage.AssetStorage();
        let blockSize = pages * 65536;
        let headerSize = 8;
        let pathPrefix = "mypath";
        let runs = 100;
        var count = 0;
        while (count < runs) {
            let path = pathPrefix # debug_show(count);
            ignore test.list();
            await test.store(path, Prim.stableMemoryLoadBlob(0, blockSize - headerSize));
            ignore test.list();
            ignore await test.retrieve(path);
            count += 1
        };
        await Trace.result()
    };
}
