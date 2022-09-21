import Prim "mo:prim";

module {
    public type Iter<T> = {next : () -> ?T};

    public func iterate<T>(array: [T]): Iter<T> {
        object {
            var index = 0;

            public func next(): ?T {
                if (index < array.size()) {
                    let value = array[index];
                    index += 1;
                    ?value
                } else {
                    null
                }
            }
        }
    };

    public class ArrayList<T>() {
        let initialSize = 2;

        var array = Prim.Array_init<?T>(initialSize, null);
        var free = 0;

        public func add(value: T) {
            if (free == array.size()) {
                grow()
            };
            array[free] := ?value;
            free += 1
        };

        public func get(index: Nat): T {
            assert(index >= 0 and index < free);
            switch (array[index]) {
                case (?value) value;
                case null Prim.trap("Invalid element")
            }
        };

        public func remove(index: Nat): T {
            assert(index >= 0 and index < free);
            let result = get(index);
            var current = index;
            while (current + 1 < free) {
                array[current] := array[current + 1];
                current += 1
            };
            array[free - 1] := null;
            free -= 1;
            result
        };

        public func elements(): Iter<T> {
            object {
                var index = 0;

                public func next(): ?T {
                    if (index < free) {
                        let value = array[index];
                        index += 1;
                        value
                    } else {
                        null
                    }
                }
            }
        };

        public func clear() {
            array := Prim.Array_init<?T>(initialSize, null);
            free := 0
        };

        public func size(): Nat = free;

        func grow() {
            let newSize = array.size() * 3 / 2;
            let newArray = Prim.Array_init<?T>(newSize, null);
            var index = 0;
            while (index < free) {
                newArray[index] := array[index];
                index += 1
            };
            array := newArray
        }
    };

    public class LinkedList<T>() {
        type Node<T> = ?{ value: T; var next: Node<T> };

        var head: Node<T> = null;
        var tail: Node<T> = null;
        var count: Nat = 0;

        public func append(value: T) {
            let current = ?{ value; var next: Node<T> = null };
            switch tail {
                case null {
                    head := current
                };
                case (?node) {
                    node.next := current
                }
            };
            tail := current;
            count += 1
        };

        public func remove(): T {
            switch head {
                case null Prim.trap("Empty list");
                case (?node) {
                    head := node.next;
                    switch (head) {
                        case null tail := null;
                        case _ {}
                    };
                    return node.value
                }
            }
        };

        public func elements(): Iter<T> {
            object {
                var current = head;

                public func next(): ?T {
                    switch current {
                        case null null;
                        case (?node) {
                            current := node.next;
                            ?node.value
                        }
                    }
                }
            }
        };

        public func size(): Nat = count;

        public func clear() {
            head := null;
            tail := null;
            count := 0
        }
    }
}
