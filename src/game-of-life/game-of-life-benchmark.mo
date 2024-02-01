import Prim "mo:prim";
import Benchmark "../benchmark";

import State "state";
import Grid "grid";
import Random "random";
import Trace "../trace";

actor {
    var state =
            do {
                let rand = Random.new();
                State.new(512, func (i, j) { rand.next() % 2 == 1 });
            };
    var cur = Grid.Grid(state);
    var nxt = Grid.Grid(State.new(cur.size(), func (i, j) { false }));

    func next() : async Text {
        cur.next(nxt);
        let temp = cur;
        cur := nxt;
        nxt := temp;
        cur.toText();
    };

    func step(): async () {
        ignore await next();
        await Trace.point()
    };

    let script = [
        ( 10, func(): async () { await step() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Game of life benchmark");
        await Benchmark.measureAsync(script)
    }
}
