import Prim "mo:prim";
import Iter "mo:base/Iter";
import AssetStorage "../perf/assetstorage";
import Trace "../trace";

actor {
    public shared func run(): async Text {
        Prim.debugPrint("Asset storage (Motoko perf test) benchmark");
        let pages = 16;
        ignore Prim.stableMemoryGrow(Prim.natToNat64(pages));
        Prim.cyclesAdd<system>(200_000_000_000); 
        let test = await AssetStorage.AssetStorage();
        let blockSize = pages * 65536;
        let headerSize = 8;
        let pathPrefix = "mypath";
        let runs = 70;
        for (count in Iter.range(0, runs - 1)) {
            Prim.debugPrint("Iteration " # debug_show(count));
            let path = pathPrefix # debug_show(count);
            ignore test.list();
            await test.store(path, Prim.stableMemoryLoadBlob(0, blockSize - headerSize));
            ignore test.list();
            ignore await test.retrieve(path);
            await* Trace.point();
        };
        await* Trace.result()
    };
}
