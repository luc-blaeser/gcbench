import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Random "random";
import Trace "trace";

module {
    public type Set<T> = {
        add : T -> ();
        contains : T -> Bool;
        delete : T -> ();
    };

    public class SetBenchmark(name : Text, set : Set<Nat>) {
        let randomSeed = 4711;
        let stepSize = 10_000;
        let amount = 200_000;

        func insert() : async* () {
            Debug.print(name # " add");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let value = random.next();
                set.add(value);
                if ((count + 1) % stepSize == 0) {
                    Debug.print(name # " set " # debug_show (count + 1));
                    await* Trace.point();
                };
            };
        };

        func retrieve() : async* () {
            Debug.print(name # " retrieve ");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let value = random.next();
                assert (set.contains(value));
                if ((count + 1) % stepSize == 0) {
                    Debug.print(name # " retrieve " # debug_show (count + 1));
                    await* Trace.point();
                };
            };
        };

        func delete() : async* () {
            Debug.print(name # " delete ");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let value = random.next();
                set.delete(value);
                if ((count + 1) % stepSize == 0) {
                    Debug.print(name # " delete " # debug_show (count + 1));
                    await* Trace.point();
                };
            };
        };

        public func run() : async Text {
            Debug.print(name # " benchmark");
            await* insert();
            await* retrieve();
            await* delete();
            await* Trace.result();
        };
    };
};
