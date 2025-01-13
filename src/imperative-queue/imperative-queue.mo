import Debug "mo:base/Debug";

module {
    type Node<T> = {
        value : T;
        var next : ?Node<T>;
    };

    public type Queue<T> = {
        var first: ?Node<T>;
        var last: ?Node<T>;
    };

    public func new<T>() : Queue<T> {
        { var first = null; var last = null; };
    };

    public func insert<T>(queue: Queue<T>, value: T) {
        let newNode: Node<T> = { value; var next = null; var previous = null };
        switch (queue.last) {
            case null {
                queue.first := ?newNode;
            };
            case (?lastNode) {
                lastNode.next := ?newNode;

            };
        };
        queue.last := ?newNode;
    };

    public func isEmpty<T>(queue: Queue<T>) : Bool {
        switch (queue.first) {
            case null true;
            case _ false;
        }
    };

    public func remove<T>(queue: Queue<T>) : T {
        switch (queue.first) {
            case null Debug.trap("Empty queue");
            case (?firstNode) {
                queue.first := firstNode.next;
                switch (queue.first) {
                    case null queue.last := null: ?Node<T>; 
                    case _ {};
                };
                firstNode.value;
            }
        };
    };
};
