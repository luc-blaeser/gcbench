import Prim "mo:prim";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Random "random";
import O "mo:base/Order";
import Splay "splay/splay";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    // Source of the benchmark case: https://github.com/dfinity/canister-profiling/blob/main/collections/motoko/src/splay.mo
    func compare(x : (Nat64, Nat64), y : (Nat64, Nat64)) : O.Order = Nat64.compare(x.0, y.0);
    var map = Splay.Splay<(Nat64, Nat64)>(compare);
    let rand = Random.new(null, 42);

    func generate(size : Nat32) {
        Prim.debugPrint("Splay tree generate " # debug_show (size));
        let rand = Random.new(?size, 1);
        let iter = Iter.map<Nat64, (Nat64, Nat64)>(rand, func x = (x, x));
        for ((k, v) in iter) {
            map.insert((k, v));
        };
    };

    func batch_get(n : Nat) {
        Prim.debugPrint("Splay tree batch get " # debug_show (n));
        for (_ in Iter.range(1, n)) {
            ignore map.find((Option.get<Nat64>(rand.next(), 0), 0));
        };
    };

    func batch_put(n : Nat) {
        Prim.debugPrint("Splay tree batch put " # debug_show (n));
        for (_ in Iter.range(1, n)) {
            let k = Option.get<Nat64>(rand.next(), 0);
            map.insert((k, k));
        };
    };

    func batch_remove(n : Nat) {
        Prim.debugPrint("Splay tree batch remove " # debug_show (n));
        let rand = Random.new(null, 1);
        for (_ in Iter.range(1, n)) {
            map.remove((Option.get<Nat64>(rand.next(), 0), 0));
        };
    };
    // End of external source
    
    let script = [
        (1, func() { generate(700_000) }),
        (10, func() { batch_get(50) }),
        (1, func() { batch_put(50) }),
        (1, func() { batch_remove(50) }),
    ];

    public shared func run() : async Text {
        Prim.debugPrint("Splay tree benchmark");
        await Benchmark.measure(script);
    };

    public shared func limitTest() : async (Nat, Runtime.Statistics) {
        let amount : Nat32 = 10_000;
        Prim.debugPrint("Splay tree limit test " # debug_show (amount));
        generate(amount);
        (Nat32.toNat(amount), Runtime.collectStatistics());
    };
};
