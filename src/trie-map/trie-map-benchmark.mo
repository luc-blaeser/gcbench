import Prim "mo:prim";
import Benchmark "../benchmark";
import LimitTest "../limit-test";

import TrieMapBase "mo:base/TrieMap";
import NatBase "mo:base/Nat";

actor {
    let trie = TrieMapBase.TrieMap<Nat, Nat>(NatBase.equal, Prim.natToNat32);

    var total = 0;

    func populate(amount: Nat) {
        Prim.debugPrint("Trie map populate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            trie.put(total, total);
            count += 1;
            total += 1
        }
    };

    func retrieve() {
        Prim.debugPrint("Trie map retrieve " # debug_show(total));
        var count = 0;
        while (count < total) {
            let result = trie.get(count);
            assert(result == ?count);
            count += 1
        }
    };

    func discard(amount: Nat) {
        Prim.debugPrint("Trie map discard " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            total -= 1;
            ignore trie.remove(total);
            count += 1
        }
    };

    func deleteAll() {
        Prim.debugPrint("Trie map delete all");
        for ((key, value) in trie.entries()) {
            trie.delete(key);
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

    public shared func benchmark(): async Text {
        Prim.debugPrint("Trie map benchmark");
        await Benchmark.measure(script)
    };

    public shared func limit(): async Text {
        Prim.debugPrint("Trie map limit test");
        await LimitTest.run(10_000, func (amount: Nat): async () { populate(amount) })
    }
}
