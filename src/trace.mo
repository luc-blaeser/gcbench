import Runtime "runtime";

import Recorder "canister:recorder";

module {
    public func point(): async() {
        await Recorder.record(Runtime.collectStatistics());
    };

    public func result(): async Text {
        await Recorder.result()
    }
}
