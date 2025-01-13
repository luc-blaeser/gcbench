import Nat "mo:base/Nat";
import ListBenchmark "../list-benchmark";
import Vector "mo:vector";

actor {
    let list = Vector.new<Nat>();

    func add(value: Nat) {
        Vector.add(list, value);
    };

    func get(index: Nat) : Nat {
        Vector.get(list, index);
    };

    func set(index: Nat, value : Nat) {
        Vector.put(list, index, value);
    };

    let benchmark = ListBenchmark.ListBenchmark(
        "Vector",
        {
            add;
            get;
            set;
        },
    );

    public func run() : async Text {
        await benchmark.run();
    };
};
