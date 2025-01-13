import Nat "mo:base/Nat";
import ListBenchmark "../list-benchmark";
import ScalableBuffer "scalable-buffer";

actor {
    let list = ScalableBuffer.ScalableBuffer<Nat>();

    func add(value: Nat) {
        list.add(value);
    };

    func get(index: Nat) : Nat {
        list.get(index);
    };

    func set(index: Nat, value : Nat) {
        list.set(index, value);
    };

    let benchmark = ListBenchmark.ListBenchmark(
        "Scalable Buffer",
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
