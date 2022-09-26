import Runtime "runtime";

import Recorder "canister:recorder";

module {
    public func point(): async() {
        await Recorder.record(Runtime.collectStatistics());
        let statistics = Runtime.collectStatistics();
        if (statistics.collectorInstructions > 1000) {
            // gc has run during previous Recorder.record() call
            await Recorder.record(Runtime.collectStatistics())
        }
    };

    public func result(): async Text {
        await Recorder.result()
    }
}
