import Prim "mo:prim";
import Iter "mo:base/Iter";
import Reversi "../perf/reversi";
import Trace "../trace";

actor {
    public shared func run(): async Text {
        Prim.debugPrint("Reversi (Motoko perf test) benchmark");
        let test = Reversi.Reversi();
        let runs = 30;
        for (count in Iter.range(0, runs - 1)) {
            await test.reset();
            await Trace.point();
            ignore await test.place(1, 2, 4);
            await Trace.point();
            ignore await test.place(2, 2, 3);
            await Trace.point();
            ignore await test.place(1, 4, 2);
            await Trace.point();
            ignore await test.board();
            await Trace.point()
        };
        await Trace.result()
    };
}
