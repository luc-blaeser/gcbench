import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Trace "trace";

module {
    public type List<T> = {
        add : T -> ();
        get : Nat -> T;
        set : (Nat, T) -> ();
    };

    public class ListBenchmark(name : Text, list : List<Nat>) {
        let stepSize = 100_000;
        let amount = 10_000_000;

        func add() : async* () {
            Debug.print(name # " add");
            for (index in Iter.range(0, amount - 1)) {
                list.add(index);
                if ((index + 1) % stepSize == 0) {
                    Debug.print(name # " add " # debug_show (index + 1));
                    await* Trace.point();
                };
            };
        };

        func get() : async* () {
            Debug.print(name # " get ");
            for (index in Iter.range(0, amount - 1)) {
                assert (list.get(index) == index);
                if ((index + 1) % stepSize == 0) {
                    Debug.print(name # " retrieve " # debug_show (index + 1));
                    await* Trace.point();
                };
            };
        };

        func set() : async* () {
            Debug.print(name # " set ");
            for (index in Iter.range(0, amount - 1)) {
                list.set(index, 2 * index);
                if ((index + 1) % stepSize == 0) {
                    Debug.print(name # " set " # debug_show (index + 1));
                    await* Trace.point();
                };
            };
        };

        public func run() : async Text {
            Debug.print(name # " benchmark");
            await* add();
            await* get();
            await* set();
            await* Trace.result();
        };
    };
};
