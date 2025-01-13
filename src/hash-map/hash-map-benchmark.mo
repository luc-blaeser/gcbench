import Nat "mo:base/Nat";
import MapBenchmark "../map-benchmark";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";

actor {
    let map = HashMap.HashMap<Nat, Nat>(4, Nat.equal, Hash.hash);

    func put(key : Nat, value : Nat) {
        map.put(key, value);
    };

    func get(key : Nat) : Nat {
        switch (map.get(key)) {
            case null Debug.trap("Missing key");
            case (?value) value;
        };
    };

    func update(key: Nat, value : Nat) {
        ignore map.replace(key, value);
    };

    func delete(key : Nat) {
        map.delete(key);
    };

    let benchmark = MapBenchmark.MapBenchmark(
        "HashMap",
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
