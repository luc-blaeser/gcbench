import Nat "mo:base/Nat";
import MapBenchmark "../map-benchmark";
import Debug "mo:base/Debug";
import RBTree "mo:base/RBTree";

actor {
    var tree = RBTree.RBTree<Nat, Nat>(Nat.compare);

    func put(key : Nat, value : Nat) {
        tree.put(key, value);
    };

    func get(key : Nat) : Nat {
        switch (tree.get(key)) {
            case null Debug.trap("Missing key");
            case (?value) value;
        };
    };

    func update(key : Nat, value: Nat) {
        tree.put(key, value);
    };

    func delete(key : Nat) {
        ignore tree.remove(key);
    };

    let benchmark = MapBenchmark.MapBenchmark(
        "RBTree",
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
