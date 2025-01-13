import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Random "random";
import Trace "trace";

module {
    public type Map<K, V> = {
        put : (K, V) -> ();
        get : K -> V;
        update : (K, V) -> ();
        delete : K -> ();
    };

    public class MapBenchmark(name : Text, map : Map<Nat, Nat>) {
        let randomSeed = 4711;
        let stepSize = 10_000;
        let amount = 200_000;

        func insert() : async* () {
            Debug.print(name # " insert");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let key = random.next();
                map.put(key, count);
                if ((count + 1) % stepSize == 0) {
                    Debug.print(name # " insert " # debug_show (count + 1));
                    await* Trace.point();
                };
            };
        };

        func retrieve() : async* () {
            Debug.print(name # " retrieve ");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let key = random.next();
                assert (map.get(key) == count);
                if ((count + 1) % stepSize == 0) {
                    Debug.print(name # " retrieve " # debug_show (count + 1));
                    await* Trace.point();
                };
            };
        };

        func update() : async* () {
            Debug.print(name # " update ");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let key = random.next();
                map.update(key, 2 * count);
                if ((count + 1) % stepSize == 0) {
                    Debug.print(name # " update " # debug_show (count + 1));
                    await* Trace.point();
                };
            };
        };

        func delete() : async* () {
            Debug.print(name # " delete ");
            let random = Random.Random(randomSeed);
            for (count in Iter.range(0, amount - 1)) {
                let key = random.next();
                map.delete(key);
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
            await* update();
            await* delete();
            await* Trace.result();
        };
    };
};
