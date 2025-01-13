import Order "mo:base/Order";
module {
    private type Color = { #Red; #Black };

    private type Node<K, V> = {
        var color : Color;
        var key : K;
        var value : V;
        var left : ?Node<K, V>;
        var right : ?Node<K, V>;
    };

    public class RedBlackTree<K, V>(compare : (K, K) -> Order.Order) {
        private var root : ?Node<K, V> = null;

        private func isRed(node : ?Node<K, V>) : Bool {
            switch (node) {
                case (null) false;
                case (?n) n.color == #Red;
            };
        };

        private func rotateLeft(h : Node<K, V>) : Node<K, V> {
            switch (h.right) {
                case (null) h;
                case (?x) {
                    h.right := x.left;
                    x.left := ?h;
                    x.color := h.color;
                    h.color := #Red;
                    x;
                };
            };
        };

        private func rotateRight(h : Node<K, V>) : Node<K, V> {
            switch (h.left) {
                case (null) h;
                case (?x) {
                    h.left := x.right;
                    x.right := ?h;
                    x.color := h.color;
                    h.color := #Red;
                    x;
                };
            };
        };

        private func flipColors(h : Node<K, V>) {
            h.color := #Red;
            switch (h.left) { case (?l) l.color := #Black; case null {} };
            switch (h.right) { case (?r) r.color := #Black; case null {} };
        };

        private func insertRec(node : ?Node<K, V>, key : K, value : V) : Node<K, V> {
            switch (node) {
                case null {
                    {
                        var color = #Red;
                        var key = key;
                        var value = value;
                        var left = null;
                        var right = null;
                    };
                };
                case (?n) {
                    var h = n;
                    let cmp = compare(key, h.key);

                    if (cmp == #less) { h.left := ?insertRec(h.left, key, value) } else if (cmp == #greater) {
                        h.right := ?insertRec(h.right, key, value);
                    } else { h.value := value };

                    if (isRed(h.right) and not isRed(h.left)) {
                        h := rotateLeft(h);
                    };
                    if (isRed(h.left) and isRed(switch (h.left) { case (?l) l.left; case null null })) {
                        h := rotateRight(h);
                    };
                    if (isRed(h.left) and isRed(h.right)) { flipColors(h) };

                    h;
                };
            };
        };

        public func insert(key : K, value : V) {
            root := ?insertRec(root, key, value);
            switch (root) {
                case (?r) r.color := #Black;
                case null {};
            };
        };

        public func get(key : K) : ?V {
            var current = root;
            loop {
                switch (current) {
                    case null return null;
                    case (?n) {
                        let cmp = compare(key, n.key);
                        if (cmp == #equal) return ?n.value;
                        current := if (cmp == #less) n.left else n.right;
                    };
                };
            };
        };

        private func moveRedLeft(node : Node<K, V>) : Node<K, V> {
            var h = node;
            flipColors(h);
            switch (h.right) {
                case (?r) {
                    if (isRed(r.left)) {
                        h.right := ?rotateRight(r);
                        h := rotateLeft(h);
                        flipColors(h);
                    };
                };
                case null {};
            };
            h;
        };

        private func moveRedRight(node : Node<K, V>) : Node<K, V> {
            var h = node;
            flipColors(h);
            switch (h.left) {
                case (?l) {
                    if (isRed(l.left)) {
                        h := rotateRight(h);
                        flipColors(h);
                    };
                };
                case null {};
            };
            h;
        };

        private func deleteMin(h : Node<K, V>) : ?Node<K, V> {
            switch (h.left) {
                case null null;
                case (?l) {
                    var node = h;
                    if (not isRed(h.left) and not isRed(l.left)) {
                        node := moveRedLeft(h);
                    };
                    node.left := deleteMin(l);
                    ?balance(node);
                };
            };
        };

        private func balance(h : Node<K, V>) : Node<K, V> {
            var node = h;
            if (isRed(node.right)) { node := rotateLeft(node) };
            if (isRed(node.left) and isRed(switch (node.left) { case (?l) l.left; case null null })) {
                node := rotateRight(node);
            };
            if (isRed(node.left) and isRed(node.right)) { flipColors(node) };
            node;
        };

        private func deleteRec(node : ?Node<K, V>, key : K) : ?Node<K, V> {
            switch (node) {
                case null null;
                case (?h) {
                    var n = h;
                    if (compare(key, n.key) == #less) {
                        switch (n.left) {
                            case (?l) {
                                if (not isRed(n.left) and not isRed(l.left)) {
                                    n := moveRedLeft(n);
                                };
                            };
                            case null {};
                        };
                        n.left := deleteRec(n.left, key);
                    } else {
                        if (isRed(n.left)) { n := rotateRight(n) };
                        switch (n.right) {
                            case null {
                                if (compare(key, n.key) == #equal) {
                                    return null;
                                };
                            };
                            case (?r) {
                                if (not isRed(n.right) and not isRed(r.left)) {
                                    n := moveRedRight(n);
                                };
                            };
                        };
                        if (compare(key, n.key) == #equal) {
                            switch (n.right) {
                                case (?r) {
                                    n.key := r.key;
                                    n.value := r.value;
                                    n.right := deleteMin(r);
                                };
                                case null {};
                            };
                        } else {
                            n.right := deleteRec(n.right, key);
                        };
                    };
                    ?balance(n);
                };
            };
        };

        public func delete(key : K) {
            if (
                not isRed(root) and
                not isRed(switch (root) { case (?r) r.left; case null null })
            ) {
                switch (root) {
                    case (?r) r.color := #Red;
                    case null {};
                };
            };
            root := deleteRec(root, key);
            switch (root) {
                case (?r) r.color := #Black;
                case null {};
            };
        };
    };
};
