# GC Benchmark

Initial benchmarking of GC performance of Motoko, to be extended and refined...

## Goals
* Analyze and understand the current GC properties in more detail.
* Provide a baseline for evaluating potentially new GC implementations.

## Characteristics
* **Running on DFX**: Measurements run in canisters on local replica by using DFX, in order to simulate a relatively realistic environment with the message instruction limits etc.
* **Stepwise execution**: Test scenarios define a series of message-triggered steps, to allow frequent interaction of the GC. This is becuase the current GCs only run on message ends, when the call stack is (nearly) empty. 
* **Generated charts**: Different GCs, different test scenarios, and different metrics are collected and rendered in visual charts, with a summary table showing aggregated metrics.

# Running

## Initial Preparation
1. Make sure you have DFX installed.
2. Compile the `report` helper program that converts CSV to charts and generates a summary table.

    ``` 
    cd util
    cargo build --release
    cd ..
    ``` 

## Running Benchmark
1. Open `nix-shell` in the motoko project and switch to this benchmark folder.
2. Configure DFX to use the latest Motoko compiler `moc` (required for the primitive `rts_mutator_instructions()` and `rts_collector_instructions()` calls):

    ``` 
    export DFX_MOC_PATH=<motoko_repo_path>/bin/moc
    ``` 

3. Run all benchmark cases:
 
    ```
    ./measure-all.sh
    ```

    The tests run several minutes.

4. Results are stored in the `reports` folder: 
    
    Open `summary.html` in the browser to see the aggregated measurement numbers and to navigate to the specific performance charts.

## Selective Measurements

Test cases can also be selectively measured, by choosing the GC and the scenario:

```
./measure.sh <compacting|copying> <scenario_name>
```

For example, to run the linked list test with the compacting GC:

```
./measure.sh compacting linked-list
```

The scenario names are lised below.

Moreover, GC limit tests can be selectively run (see also below):

```
./limit-test.sh <compacting|copying> <scenario_name>
```

## Reports and Charts

The `reports` folder contains the measurement results:

* CSV file per test case: Each line lists the measurement values at the end of a message call, i.e. scenario step.
* Chart file per test case: Different HTML5 charts, showing memory, allocation, and runtime behavior over the series of execution steps.
* One summary HTML page: Aggregation of different metrics for all test cases, with links to the corresponding chart pages. Additionally, it shows the maximimum number allocations and heap space that can be performed in the scenario.

# Cases

Different test scenarios are run with the available GC implementations, each such combination called a test case. 

Each scenario operates on a specific heap structure with a specific pattern, consisting of object allocation, reading and traversing pointers, and/or again making objects unreachable. 

All scenarios are configured to run successully in all cases, without hitting any limits (instruction limit, heap size limit). This is necessary for the comparability of the performance results.

## Linked List (Small Items)

A singly linked list of Nat numbers, used in a scenario of several message steps. Each line denotes a tuple of how often the step is repeated and what operation is performed in each step. E.g. the first line specifies 50 message call steps of populate(100_000), where each populate() step inserts 100_000 new elements to the list.

```
( 50, func() { populate(100_000) } ),
( 10, func() { traverse() } ),
( 25, func() { discard(100_000) } ),
( 10, func() { traverse() } ),
( 25, func() { populate(100_000) } ),
( 1, func() { clear() } ),
( 50, func() { populate(100_000) } ),
( 10, func() { traverse() } )
```

**Rationale**: Having a simplest but large-scaling case with many small objects and a very simple pointer structure, i.e. with as few pointers as possible for the amount of objects. External fragmentation should be relatively unproblematic.

## Array List (Small Items)

A simple exponentially growing array list with amortized costs (growth rate 1.5), containing simple Nat numbers. Same scenario as for linked list:

```
( 50, func() { populate(100_000) } ),
( 10, func() { traverse() } ),
( 25, func() { discard(100_000) } ),
( 10, func() { traverse() } ),
( 25, func() { populate(100_000) } ),
( 1, func() { clear() } ),
( 50, func() { populate(100_000) } ),
( 10, func() { traverse() } )
```

**Rationale**: Measuring the heap with a memory-compact data structure, except for the large-growing list-internal array. Few pointers are used. Fragmentation could become noticable with growing list.

## Blobs (Large Items)

An array list containing 64KB BLOBS as element items. Scenario of several steps:

```
( 10, func() { allocate(1000) } ),
( 5, func() { traverse() } ),
( 1, func() { discardAll() } ),
( 24, func() { allocate(1000) } ),
( 5, func() { traverse() } )
```

**Rationale**: Measuring the heap with relatively large objects and relatively few pointers. High moving costs compared to the number of objects. Fragmentation should be relatively unproblematic due to the mostly same-sized objects.

## Graph (Fully Connected)

A fully connected directed graph (clique), where each node holds an array list with pointers (directed edges) to each other node. Scales quadradically by design. Measurement scenario:

```
( 10, func() { populate(100) } ),
( 1, func() { clear() } ),
( 25, func() { populate(100) } ),
( 1, func() { clear() } ),
( 50, func() { populate(100) } )
```

In this scenario, traversal is implicitly contained in the population steps, since new nodes need to be connected to and from the other existing nodes.

**Motivation**: Analyzing a highly connected structure, with a massive amount of pointers compared to the amount of objects. This demonstrates the performance of updating pointers in moving GCs (compacting/copying), while also observing  the efficiency of write/read barriers in potential future incremental GCs. 

## Red-Black Tree

The current Motoko base library implementation of red-black trees. Scenario:

```
( 30, func() { populate(10_000) } ),
( 10, func() { retrieve() } ),
( 20, func() { discard(10_000) } ),
( 10, func() { retrieve() } ),
( 20, func() { populate(10_000) } ),
( 1, func() { clear() } ),
( 40, func() { populate(10_000) } ),
( 10, func() { retrieve() } )
```

**Motivation**: Having a real implementation and more complex data structure implementation, with more temporary object allocations.

## Scenario Summary

| Name          | Description               |
| ------------- | ------------------------- |
| `linked-list` | Small element linked list |
| `array-list`  | Large element array list  |
| `blob`        | Large blobs array list    |
| `graph`       | Fully connected graph     |
| `rb-tree`     | Red-black tree            |

The list is to be extended with more cases in future, e.g. more real and complex examples.
A current difficulty is that benchmarked programs need to be split into message sequence steps, to trigger the GC in between.

**Note**: This is NOT intended to compare data structures' efficiency, as most scenarios are deliberately different in their configuration (different allocation sizes and different access patterns).

# GCs

All scenarios are run with the following GCs of the Motoko implementation:

| Name          | Description               |
| ------------- | ------------------------- |
| `compacting`  | Compacting GC             |
| `copying`     | Copying GC                |

`NoGC`: To gain additional information, the GC was also disabled in the runtime system code and the scenarios were manually measured. See [spreadsheet](GC-Measurements.pdf) results for the corrsponding results.

# Metrics

The following metrics are computed by the benchmark:

| Name                  | Description                                   | Better    | Calculation
| --------------------- | --------------------------------------------- | --------- | ------------
| Heap Size             | Heap occupation at program end                | lower     | `LAST(heap)`
| Memory Overhead       | Memory demand on top of max heap size         | lower     | `(MAX(memory) - MAX(heap)) / MAX(heap)`
| Mutator Utilization   | Fraction of mutator of total program time     | higher    | `SUM(mutator) / (SUM(mutator) + SUM(collector))`
| Max GC Pause          | Longest GC run blocking mutator (instructions)| lower     | `MAX(collector)`
| MMU                   | Minimum mutator utilzation per call           | higher    | `MIN(mutator / (mutator + collector))`
| Instruction Total     | Number of instructions executed               | lower     | `SUM(mutator) + SUM(collector)`
| Survival Rate         | Fraction of retained objects per GC run       | neutral   | `1-AVG(reclaimed[i] / SUM(allocated[0..i]) - SUM(reclaimed[0..i-1])`


Minimum mutator utilization is the smallest value of mutator utilization, calculated for every time slice, here for every message processing. This is an indicator for real-time feasability, related to max GC pause.

Survival rate makes more sense for generational garbage collection, concentrating on the young generation(s) and the the fraction of young live objects that get promoted to the older generation.

Moreover, the benchmark performs a separate measurement for determining the maximum number of allocations and heap size that can be used (see below).

Additonal metrics that would be interesting, but currently not available:
* Throughput of instructions per time unit
* Effective costs on IC
* Reclamation latency
* Average lifetime of objects
* External fragmentation
* Heap locality
* Object structure shapes
* ...

# Charts

The generated charts show the following properties over the time axis of canister message calls (scripted steps) per benchmark test case (test scenario and GC version):

* Memory chart
    - Memory space, heap space, live objects
* Allocation chart
    - Allocated objects, reclaimed objects
* Runtime chart
    - Mutator instructions, garbage collector instructions

# Limit Tests

For data-structure-like scenarios, the maximum amoung of allocations are also examined until the program hits the message instruction limit or the heap size limit. The tests run as part of the `measure-all.sh`, and continuoulsy allocate and add new elements (populate-steps) until program failure.

The second table in the summary page `summary.html` shows the results of these measurements:

| Name                  | Description                                   | Better    |
| --------------------- | --------------------------------------------- | --------- |
| Allocations           | Maximum number of elements addded             | higher    |
| Heap Maximum          | Heap size before when the limit               | higher    |

**Note**: Graph scenario is deliberately not tested for limit, as it is not designed to scale.

Limit test can also be selectively run (see above).

# Observations

Strength:
- **Space efficiency**: Due to compaction, heap size space is quite efficiently used and external fragmentation avoided. The compacting GC minimizes space usage, while copying GC requires extra copying space (two space copy technique).

Shortcomings:
- **Long GC pauses**: High GC spikes can be observed in the runtime chart with growing scenarios (due to the stop-the-world GC design). This soon exceeds the message instruction limit, meaning that the program can only scale to relatively small heap size (e.g. linked list with small blocks can only use up to 160 MB heap space with both compacting and copying GC). An incremental GC would alleviate this limitation.
- **High runtime costs**: Mutator utlization is relatively low, meaning that the GC consumes a substantial amount of runtime (e.g. for array list with large objects, the mutator only runs 24% programs instructions, while GC accounts for the remaining 76% of the total number of instructions). Reducing GC costs, e.g. with generational or partitioned collection, would be beneficial.
- **Stack root set**: The current GC implementations do not yet scan the call stack for the root set, such that the GC can only run on very specific moments when the stack is empty, such as before or after message calls. If memory grows too fast during a message call, the GC cannot reclaim memory in meantime, such that the programs runs out of heap space.

Specific:
- **Compacting vs. copying**: For smaller objects, copying GC allows somewhat more allocations than compacting GC (`rb-tree` limit test). However, for larger objects, compacting GC scales much better than copying GC (`blobs` limit test).