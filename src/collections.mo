import Prim "mo:prim";
import Iter "mo:base/Iter";

module {
    public func iterate<T>(array: [T]): Iter.Iter<T> {
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

        public func elements(): Iter.Iter<T> {
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
