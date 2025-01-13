import Nat "mo:base/Nat";
import MapBenchmark "../map-benchmark";
import Debug "mo:base/Debug";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";

actor {
    let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);

    func put(key : Nat, value : Nat) {
        map.put(key, value);
    };

    func get(key : Nat) : Nat {
        switch (map.get(key)) {
            case null Debug.trap("Missing key");
            case (?value) value;
        };
    };

    func update(key: Nat, value: Nat) {
        map.put(key, value);
    };

    func delete(key : Nat) {
        map.delete(key);
    };

    let benchmark = MapBenchmark.MapBenchmark(
        "Trie",
        {
            put;
            get;
            update;
            delete;
        },
    );

    public func run() : async Text {
        await benchmark.run();
    };
};
