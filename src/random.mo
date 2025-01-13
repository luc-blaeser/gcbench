import Nat64 "mo:base/Nat64";

module {
    public class Random(seed : Nat) {
        var number = Nat64.fromNat(seed);
        public func next() : Nat {
            number := Nat64.addWrap(Nat64.mulWrap(123138118391, number), 133489131) % 999_999_999_999_999;
            Nat64.toNat(number);
        };
    };
};
