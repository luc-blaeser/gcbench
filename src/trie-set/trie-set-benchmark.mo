import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Hash "mo:base/Hash";
import SetBenchmark "../set-benchmark";

actor {
    var set = TrieSet.empty<Nat>();
    
    func add(value : Nat) {
        set := TrieSet.put(set, value, Hash.hash(value), Nat.equal);
    };

    func contains(value : Nat) : Bool {
        TrieSet.contains(set, value, Hash.hash(value), Nat.equal);
    };

    func delete(value : Nat) {
        set := TrieSet.delete(set, value, Hash.hash(value), Nat.equal);
    };

    let benchmark = SetBenchmark.SetBenchmark(
        "HashSet",
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
