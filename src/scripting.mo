module {
    public type Operation = () -> ();

    public class Script(script: [(Nat, Operation)]) {
        var step = 0;

        public func length(): Nat {
            var index = 0;
            var sum = 0;
            while (index < script.size()) {
                sum += script[index].0;
                index += 1
            };
            sum
        };

        public func next(): Operation {
            var index = 0;
            var sum = 0;
            while (step >= sum + script[index].0) {
                sum += script[index].0;
                index += 1;
            };
            step += 1;
            script[index].1
        }
    }
}
