import OrderedSet "mo:base/OrderedSet";
import Nat "mo:base/Nat";
import SetBenchmark "../set-benchmark";

actor {
    let set = OrderedSet.Make<Nat>(Nat.compare);
    var setData = set.empty();

    func add(value : Nat) {
        setData := set.put(setData, value);
    };

    func contains(value : Nat) : Bool {
        set.contains(setData, value)
    };

    func delete(value : Nat) {
        setData := set.delete(setData, value);
    };

    let benchmark = SetBenchmark.SetBenchmark(
        "OrderedSet",
        {
            add;
            contains;
            delete;
        },
    );

    public func run() : async Text {
        await benchmark.run();
    };
};
