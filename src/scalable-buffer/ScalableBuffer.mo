// Two-level buffer (based on an array list) to limit to reduce exponential copying overhead of array lists on growth.

import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";

module {
    public class ScalableBuffer<T>() {
        let InitialCapacity = 8;
        let SecondLevelBufferLimit = 1024 * 1024;

        var count = 0;
        let firstLevel = Buffer.Buffer<Buffer.Buffer<T>>(InitialCapacity);
        
        public func add(value: T) {
            let firstIndex = count / SecondLevelBufferLimit;
            if (firstIndex == firstLevel.size()) {
                firstLevel.add(Buffer.Buffer<T>(InitialCapacity));
            };
            let secondLevel = firstLevel.get(firstIndex);
            secondLevel.add(value);
            count += 1;
        };

        public func size() : Nat {
            return count;
        };

        public func get(index: Nat) : T {
            assert(index < count);
            let firstIndex = index / SecondLevelBufferLimit;
            let secondLevel = firstLevel.get(firstIndex);
            let secondIndex = index % SecondLevelBufferLimit;
            return secondLevel.get(secondIndex);
        };

        public func removeLast() : ?T {
            if (count == 0) {
                return null;
            };
            let firstIndex = count / SecondLevelBufferLimit;
            count -= 1;
            let secondLevel = firstLevel.get(firstIndex);
            return secondLevel.removeLast();
        };

        public func clear() {
            firstLevel.clear();
            count := 0;
        };

        public func vals() : Iter.Iter<T> = object {
            var nextIndex = 0;
            public func next() : ?T {
                if (nextIndex >= count) {
                    return null
                };
                let nextElement = get(nextIndex);
                nextIndex += 1;
                return ?nextElement;
            }
        };
    }
}
