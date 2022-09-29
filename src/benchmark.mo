import Prim "mo:prim";
import Runtime "runtime";
import Collections "collections";
import Iter "mo:base/Iter";
import Trace "trace";

module {
    public type Operation = () -> ();
    public type RepeatedStep = (Nat, Operation);
    public type Script = [RepeatedStep];

    public func measure(script: Script): async Text {
        for (line in Collections.iterate(script)) {
            for (repetition in Iter.range(0, line.0 - 1)) {
                let operation = line.1;
                operation();
                await Trace.point()
            }
        };
        await Trace.result()
    };

    public type AsyncOperation = () -> async ();
    public type AsyncRepeatedStep = (Nat, AsyncOperation);
    public type AsyncScript = [AsyncRepeatedStep];

    public func measureAsync(script: AsyncScript): async Text {
        for (line in Collections.iterate(script)) {
            for (repetition in Iter.range(0, line.0 - 1)) {
                let operation = line.1;
                await operation();
                await Trace.point()
            }
        };
        await Trace.result()
    }
}
