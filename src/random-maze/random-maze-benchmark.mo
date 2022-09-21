import Prim "mo:prim";
import Benchmark "../benchmark";
import RandomMaze "random-maze";

actor {
    func generate(size: Nat) : async () {
        ignore await RandomMaze.generate(size)
    };

    let script = [
        ( 10, func(): async () { await generate(10) } ),
        ( 10, func(): async () { await generate(100) } ),
        ( 5, func(): async () { await generate(200) } )
    ];

    public shared func benchmark(): async Text {
        Prim.debugPrint("Random maze benchmark");
        Benchmark.measureAsync(script)
    }
}
