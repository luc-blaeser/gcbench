import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import Benchmark "../benchmark";

actor {
    class FullyConnectedGraph() {
        public type Node = {value: Nat; edges: Buffer.Buffer<Node>};
        
        let nodes = Buffer.Buffer<Node>(4);
        
        public func append(value: Nat) {
            var newNode = {value; edges = Buffer.Buffer<Node>(4)};
            for (current in nodes.vals()) {
                newNode.edges.add(current);
            };
            for (current in nodes.vals()) {
                current.edges.add(newNode)
            };
            nodes.add(newNode);
        };

        public func clear() {
            nodes.clear()
        };

        public func size(): Nat = nodes.size()
    };

    let graph = FullyConnectedGraph();
    
    func populate(amount: Nat) {
        Prim.debugPrint("Graph populate " # debug_show(amount));
        var count = 0;
        while (count < amount) {
            graph.append(amount);
            count += 1
        }
    };

    func clear() {
        Prim.debugPrint("Graph clear");
        graph.clear()
    };
    
    let script = [
        ( 10, func() { populate(100) } ),
        ( 1, func() { clear() } ),
        ( 20, func() { populate(100) } ),
        ( 1, func() { clear() } ),
        ( 40, func() { populate(100) } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Graph benchmark");
        await Benchmark.measure(script)
    }
}
