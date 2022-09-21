import Prim "mo:prim";
import Runtime "runtime";
import Collections "collections";
import Trace "trace";

module {
    public type Operation = () -> ();
    public type RepeatedStep = (Nat, Operation);
    public type Script = [RepeatedStep];

    public func measure(script: Script): async Text {
        for (line in Collections.iterate(script)) {
            var repetition = 0;
            while (repetition < line.0) {
                let operation = line.1;
                operation();
                await Trace.point();
                repetition += 1
            }
        };
        await Trace.result()
    };

    public type AsyncOperation = () -> async ();
    public type AsyncRepeatedStep = (Nat, AsyncOperation);
    public type AsyncScript = [AsyncRepeatedStep];

    public func measureAsync(script: AsyncScript): async Text {
        for (line in Collections.iterate(script)) {
            var repetition = 0;
            while (repetition < line.0) {
                let operation = line.1;
                await operation();
                await Trace.point();
                repetition += 1
            }
        };
        await Trace.result()
    }
}
