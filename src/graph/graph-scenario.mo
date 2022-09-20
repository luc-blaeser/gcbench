import Prim "mo:prim";
import Runtime "../runtime";
import Collections "../collections";
import Scripting "../scripting";

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
    
    let script = Scripting.Script([
        ( 10, func() { populate(100) } ),
        ( 1, func() { clear() } ),
        ( 25, func() { populate(100) } ),
        ( 1, func() { clear() } ),
        ( 50, func() { populate(100) } )
    ]);

    public shared func totalSteps(): async Nat {
        script.length()
    };

    public shared func runStep(): async Runtime.Statistics {
        let operation = script.next();
        operation();
        Runtime.collectStatistics()
    };

    public shared func fill(amount: Nat): async Runtime.Statistics {
        populate(amount);
        Runtime.collectStatistics()
    }
}
