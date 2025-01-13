import Nat "mo:base/Nat";
import MapBenchmark "../map-benchmark";
import Debug "mo:base/Debug";
import ImperativeRbTree "imperative-rb-tree";

actor {
    let tree = ImperativeRbTree.RedBlackTree<Nat, Nat>(Nat.compare);
    
    func put(key : Nat, value : Nat) {
        tree.insert(key, value);
    };

    func get(key : Nat) : Nat {
        switch (tree.get(key)) {
            case null Debug.trap("Missing key");
            case (?value) value;
        };
    };

    func update(key: Nat, value: Nat) {
        tree.insert(key, value);
    };

    func delete(key : Nat) {
        tree.delete(key);
    };

    let benchmark = MapBenchmark.MapBenchmark(
        "Imperative RB Tree",
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
