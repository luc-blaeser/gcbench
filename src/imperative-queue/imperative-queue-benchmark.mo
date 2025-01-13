import Nat "mo:base/Nat";
import ImperativeQueue "imperative-queue";
import QueueBenchmark "../queue-benchmark";

actor {
    var queue = ImperativeQueue.new<Nat>();

    func add(value: Nat) {
        ImperativeQueue.insert(queue, value);
    };

    func remove() : Nat {
        ImperativeQueue.remove(queue);
    };

    let benchmark = QueueBenchmark.QueueBenchmark(
        "Imperative Queue",
        {
            add;
            remove;
        },
    );

    public func run() : async Text {
        await benchmark.run();
    };
};
