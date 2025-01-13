import Nat "mo:base/Nat";
import MapBenchmark "../map-benchmark";
import Debug "mo:base/Debug";
import BTree "mo:stableheapbtreemap/BTree";

actor {
    let tree = BTree.init<Nat, Nat>(null);
    
    func put(key : Nat, value : Nat) {
        ignore BTree.insert(tree, Nat.compare, key, value);
    };

    func get(key : Nat) : Nat {
        switch (BTree.get(tree, Nat.compare, key)) {
            case null Debug.trap("Missing key");
            case (?value) value;
        };
    };

    func update(key : Nat, value : Nat) {
        ignore BTree.insert(tree, Nat.compare, key, value);
    };

    func delete(key : Nat) {
        ignore BTree.delete(tree, Nat.compare, key);
    };

    let benchmark = MapBenchmark.MapBenchmark(
        "BTreeMap",
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
