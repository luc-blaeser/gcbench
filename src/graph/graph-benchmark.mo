import Prim "mo:prim";
import Collections "../collections";
import Benchmark "../benchmark";

actor {
    class FullyConnectedGraph() {
        public type Node = {value: Nat; edges: Collections.ArrayList<Node>};
        
        let nodes = Collections.ArrayList<Node>();
        
        public func append(value: Nat) {
            var newNode = {value; edges = Collections.ArrayList<Node>()};
            for (current in nodes.elements()) {
                newNode.edges.add(current);
            };
            for (current in nodes.elements()) {
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
        ( 25, func() { populate(100) } ),
        ( 1, func() { clear() } ),
        ( 50, func() { populate(100) } )
    ];

    public shared func run(): async Text {
        Prim.debugPrint("Graph benchmark");
        await Benchmark.measure(script)
    }
}
