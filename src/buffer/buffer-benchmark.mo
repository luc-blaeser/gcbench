import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import ListBenchmark "../list-benchmark";

actor {
    let list = Buffer.Buffer<Nat>(4);

    func add(value: Nat) {
        list.add(value);
    };

    func get(index: Nat) : Nat {
        list.get(index);
    };

    func set(index: Nat, value : Nat) {
        list.put(index, value);
    };

    let benchmark = ListBenchmark.ListBenchmark(
        "Buffer",
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
