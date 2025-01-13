import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Trace "trace";

module {
    public type Queue<T> = {
        add : T -> ();
        remove : () -> T;
    };

    public class QueueBenchmark(name : Text, queue : Queue<Nat>) {
        let stepSize = 100_000;
        let amount = 10_000_000;

        func add() : async* () {
            Debug.print(name # " add");
            for (index in Iter.range(0, amount - 1)) {
                queue.add(index);
                if ((index + 1) % stepSize == 0) {
                    Debug.print(name # " add " # debug_show (index + 1));
                    await* Trace.point();
                };
            };
        };

        func remove() : async* () {
            Debug.print(name # " remove ");
            for (index in Iter.range(0, amount - 1)) {
                assert (queue.remove() == index);
                if ((index + 1) % stepSize == 0) {
                    Debug.print(name # " remove " # debug_show (index + 1));
                    await* Trace.point();
                };
            };
        };

        public func run() : async Text {
            Debug.print(name # " benchmark");
            await* add();
            await* remove();
            await* Trace.result();
        };
    };
};
