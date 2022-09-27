import Prim "mo:prim";
import QR "../perf/qr";
import Trace "../trace";

actor {
    public shared func run(): async Text {
        Prim.debugPrint("QR code (Motoko perf test) benchmark");
        Prim.cyclesAdd(200_000_000_000); 
        let test = await QR.QR();
        await test.go();
        await Trace.result()
    };
}
