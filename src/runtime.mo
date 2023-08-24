import Prim "mo:prim";

module {
    public type Statistics = {
        memorySize: Nat;
        heapSize: Nat;
        allocated: Nat;
        reclaimed: Nat;
        maxLiveSize: Nat;
        mutatorInstructions: Nat;
        collectorInstructions: Nat;
        cyclesBalance: Nat;
    };

    public func collectStatistics(): Statistics {
        {
            memorySize = Prim.rts_memory_size();
            heapSize = Prim.rts_heap_size();
            allocated = Prim.rts_total_allocation();
            reclaimed = Prim.rts_reclaimed();
            maxLiveSize = Prim.rts_max_live_size();
            mutatorInstructions = Prim.rts_mutator_instructions();
            collectorInstructions = Prim.rts_collector_instructions();
            cyclesBalance = Prim.cyclesBalance();
        }
    };

    public let statisticsLegend = "Memory, Heap, Allocated, Reclaimed, Live, Mutator, Collector, Cycles";

    public func dumpStatistics(statistics: Statistics): Text {
        debug_show(statistics.memorySize) # ", " #
        debug_show(statistics.heapSize) # ", " #
        debug_show(statistics.allocated) # ", " #
        debug_show(statistics.reclaimed) # ", " #
        debug_show(statistics.maxLiveSize) # ", " #
        debug_show(statistics.mutatorInstructions) # ", " #
        debug_show(statistics.collectorInstructions) # ", " #
        debug_show(statistics.cyclesBalance)
    }
}
