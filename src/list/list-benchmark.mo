import Nat "mo:base/Nat";
import List "mo:base/List";
import Debug "mo:base/Debug";
import ListBenchmark "../list-benchmark";

actor {
    var list = List.nil<Nat>();
    var size = 0;

    func add(value: Nat) {
        list := List.push(value, list);
        size += 1;
    };

    func get(index: Nat) : Nat {
        switch (List.get(list, size - index - 1 : Nat)) {
            case null Debug.trap("Invalid index");
            case (?value) value;
        }
    };

    func set(index: Nat, value : Nat) {
        var current = 0;
        list := List.map<Nat, Nat>(list, func oldValue {
            let newValue = if (current == index) {
                value
            } else {
                oldValue
            };
            current += 1;
            newValue
        });
    };

    let benchmark = ListBenchmark.ListBenchmark(
        "List",
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
