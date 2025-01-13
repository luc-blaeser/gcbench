import OrderedMap "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import MapBenchmark "../map-benchmark";
import Debug "mo:base/Debug";

actor {
    let map = OrderedMap.Make<Nat>(Nat.compare);
    var mapData = map.empty<Nat>();

    func put(key : Nat, value : Nat) {
        mapData := map.put(mapData, key, value);
    };

    func get(key : Nat) : Nat {
        switch (map.get(mapData, key)) {
            case null Debug.trap("Missing key");
            case (?value) value;
        };
    };

    func update(key: Nat, value: Nat) {
        mapData := map.put(mapData, key, value);
    };

    func delete(key : Nat) {
        mapData := map.delete(mapData, key);
    };

    let benchmark = MapBenchmark.MapBenchmark(
        "OrderedMap",
        {
            put;
            get;
            update;
            delete;
        },
    );

    public func run() : async Text {
        await benchmark.run();
    };
};
