import Prim "mo:prim";
import Iter "mo:base/Iter";
import TrieMapBase "mo:base/TrieMap";
import NatBase "mo:base/Nat";
import Benchmark "../benchmark";
import Runtime "../runtime";

actor {
    let trie = TrieMapBase.TrieMap<Nat, Nat>(NatBase.equal, Prim.natToNat32);

    var total = 0;

    func populate(amount: Nat) {
        Prim.debugPrint("Trie map populate " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            trie.put(total, total);
            total += 1
        }
    };

    func retrieve() {
        Prim.debugPrint("Trie map retrieve " # debug_show(total));
        for (count in Iter.range(0, total - 1)) {
            let result = trie.get(count);
            assert(result == ?count)
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("Trie map discard " # debug_show(amount));
        for (count in Iter.range(0, amount - 1)) {
            total -= 1;
            ignore trie.remove(total)
        }
    };

    func deleteAll() {
        Prim.debugPrint("Trie map delete all");
        for ((key, value) in trie.entries()) {
            trie.delete(key)
        };
        total := 0
    };

    let script = [
        ( 30, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 20, func() { discard(10_000) } ),
        ( 10, func() { retrieve() } ),
        ( 20, func() { populate(10_000) } ),
        ( 1, func() { deleteAll() } ),
        ( 40, func() { populate(10_000) } ),
        ( 10, func() { retrieve() } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Trie map benchmark");
        await Benchmark.measure(script)
    };

    public shared func limitTest(): async (Nat, Runtime.Statistics) {
        let amount = 100_000;
        Prim.debugPrint("Trie map limit test " # debug_show(amount));
        populate(amount);
        (amount, Runtime.collectStatistics())
    }
}
