# GC Benchmark

Initial benchmarking of GC performance of Motoko, to be extended and refined...

## Goals
* Analyze and understand the current GC properties in more detail.
* Provide a baseline for evaluating potentially new GC implementations.

## Characteristics
* **Running on DFX**: Measurements run in canisters on local replica by using DFX, in order to simulate a relatively realistic environment with the message instruction limits etc.
* **GC points**: Test scenarios are decomposed in multiple steps where the GC gets a chance to run in between. This is because the current GCs only run at specific times, when the call stack is (nearly) empty. 
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

    Yout can add this configuration also as environment variable to your shell config, e.g. `~/.zshrc`.

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

* CSV file per test case: Each line lists the statistics values at measurement point, i.e. a scenario step where the GC got a chance to run.
* Chart file per test case: Different HTML5 charts, showing memory, allocation, and runtime behavior over the series of execution steps.
* One summary HTML page: Aggregation of different metrics for all test cases, with links to the corresponding chart pages. Additionally, it shows the maximimum number allocations and heap space that can be performed in the scenario.

# Cases

Different test scenarios are run with the available GC implementations, each such combination called a test case. 

All scenarios are configured to run successully in all cases, without hitting any limits (instruction limit, heap size limit). This is necessary for the comparability of the performance results.

## Linked List (Small Items)

A singly linked list of Nat numbers, used in a scenario of several steps. Each line denotes a tuple of how often the step is repeated and what operation is performed in each step. E.g. the first line specifies 50 msteps of populate(100_000), where each populate() step inserts 100_000 new elements to the list.

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

## Buffer (Small Items)

Buffer of the Motoko base library containing Nat numbers. The buffer's implementation is a simple exponentially growing array list with amortized costs (growth rate 2), containing simple Nat numbers. Same scenario as for linked list:

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

**Rationale**: Measuring the heap with a memory-compact data structure that is part of the Motoko base library. The scenario creates large-growing list-internal arrays on the heap. Few pointers are used.

## Blobs (Large Items)

A `Buffer` containing 64KB BLOBS as element items. Scenario of several steps:

```
( 10, func() { allocate(1000) } ),
( 5, func() { traverse() } ),
( 1, func() { discardAll() } ),
( 24, func() { allocate(1000) } ),
( 5, func() { traverse() } )
```

**Rationale**: Measuring the heap with relatively large objects and relatively few pointers. High moving costs compared to the number of objects. Fragmentation should be relatively unproblematic due to the mostly same-sized objects.

## Graph (Fully Connected)

A fully connected directed graph (clique), where each node holds a `Buffer` with pointers (directed edges) to each other node. Scales quadradically by design. Measurement scenario:

```
( 10, func() { populate(100) } ),
( 1, func() { clear() } ),
( 20, func() { populate(100) } ),
( 1, func() { clear() } ),
( 40, func() { populate(100) } )
```

In this scenario, traversal is implicitly contained in the population steps, since new nodes need to be connected to and from the other existing nodes.

**Motivation**: Analyzing a highly connected structure, with a massive amount of pointers compared to the amount of objects. This demonstrates the performance of updating pointers in moving GCs (compacting/copying), while also observing  the efficiency of write/read barriers in potential future incremental GCs. 

## Red-Black Tree (Small Items)

The current Motoko base library implementation of a red-black tree, storing Nat to Nat entries. Scenario:

```
( 30, func() { populate(10_000) } ),
( 10, func() { retrieve() } ),
( 20, func() { discard(10_000) } ),
( 10, func() { retrieve() } ),
( 20, func() { populate(10_000) } ),
( 1, func() { deleteAll() } ),
( 40, func() { populate(10_000) } ),
( 10, func() { retrieve() } )
```

**Motivation**: Having a real implementation and more complex data structure implementation, with more temporary object allocations.

## Trie Map (Small Items)

The current Motoko base library implementation of trie map storing Nat to Nat entries. Scenario:

```
( 30, func() { populate(10_000) } ),
( 10, func() { retrieve() } ),
( 20, func() { discard(10_000) } ),
( 10, func() { retrieve() } ),
( 20, func() { populate(10_000) } ),
( 1, func() { deleteAll() } ),
( 40, func() { populate(10_000) } ),
( 10, func() { retrieve() } )
```

**Motivation**: Same as for red-black tree.

## Random Maze (Motoko Playground)

Random Maze sample from the Motoko playground, with the following scenario. Additional GC measurement points are taken when awaiting results of message calls to the random number canister. 

```
( 10, func(): async () { await generate(10) } ),
( 10, func(): async () { await generate(100) } ),
( 5, func(): async () { await generate(200) } )
```

(Compiler warning originates from the embedded sample code.)

**Motivation**: Include a more representative example taken from the Motoko playground. The scenario is also relatively compute-intense.

## Game of Life (Motoko Playground)

Game of Life sample version 2 from the Motoko playground with size 512: 

```
( 10, func(): async () { await step() } )
```

**Motivation**: Similar to Random Maze.

## Extendable Token (Toniq Labs)

Source: [https://github.com/Toniq-Labs/extendable-token](https://github.com/Toniq-Labs/extendable-token)

Extendable Token project by Toniq Labs (MIT license), using standard extension and measuring 200 repeated transfers. Measurement trace point inserted at once place in third-party standard.mo.

(Compiler warnings originate from the third-party code.)

**Motivation**: Using a real external application with higher code complexity. 

## Asset Storage (Motoko Perf Test)

Taken from the Motoko performance tests, simulating an asset storage:

100 iterations of:
- List the storage.
- Store a new 1MB content blob (16 pages of 64KB).
- List the storage.
- Retrieving last stored content. 

The existing performance test has been slightly adjusted, in particular to insert GC trace points.

**Motivation**: Include existing Motoko performance tests that is memory-intense. 

## QR Code (Motoko Perf Test)

Taken from the Motoko performance tests:

20 iterations of:
- Compute 3 QR codes and show them

Minor code adjustment for benchmark integration.

**Motivation**: Include existing performance test that is compute-intense.

## Reversi (Motoko Perf Test)

Taken from the Motoko performance tests, 30 iterations.

- Compute 3 QR codes and show them

**Motivation**: Very simple existing performance test.

## Sha256 (Motoko Perf Test)

Taken from the Motoko performance tests, reduced to 64kb hashing due to instruction limit.

```
( 10, func() { Sha256.go() } ),
```

**Motivation**: Compute-intense existing performance test.

## Scenario Summary

| Name                  | Description                   |
| --------------------- | ------------------------- ----|
| `linked-list`         | Small element linked list     |
| `buffer`              | Small element buffer          |
| `blobs`               | Large blobs buffer            |
| `graph`               | Fully connected graph         |
| `rb-tree`             | Red-black tree                |
| `trie-map`            | Trie map                      |
| `random-maze`         | Random Maze (playground)      |
| `game-of-life`        | Game of Life (playground)     |
| `extendable-token`    | Extendable Token (Toniq Labs) |
| `asset-storage`       | Asset storage (perf test)     |
| `qr-code`             | QR code (perf test)           |
| `reversi`             | Reversi (perf test)           |
| `sha256`              | SHA256 (perf test)            |


The list is to be extended with more cases in future, e.g. more real and complex examples.
A current difficulty is that benchmarked programs need to be split into measurement steps, to give the GC a possibility to run in between.

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


Minimum mutator utilization is the smallest value of mutator utilization, calculated for every time slice, here for every scenario step. This is an indicator for real-time feasability, related to max GC pause.

Survival rate makes more sense for generational garbage collection, where the metric specifies the fraction of young live objects that get promoted to the older generation. Here, it denotes the fraction of alive objects per GC run.

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

The generated charts show the following properties over the time axis of the steps per benchmark test case (test scenario and GC version):

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
- **Long GC pauses**: High GC spikes can be observed in the runtime chart with growing and allocation-intense scenarios (due to the stop-the-world GC design). This soon exceeds the message instruction limit, meaning that the program can only scale to relatively small heap size (e.g. linked list with small blocks can only use up to 160 MB heap space with both compacting and copying GC). An incremental GC would alleviate this limitation.
- **High runtime costs**: Mutator utlization is relatively low for allocation-intense scenarios, meaning that the GC consumes a substantial amount of runtime (e.g. for blobs with the copying GC, the mutator only runs 15% of the programs instructions, while GC accounts for the remaining 85% of the total number of instructions). Reducing GC costs, e.g. with generational or partitioned collection, or simply by more sophistcated GC scheduling heurtistics, would be beneficial.
- **Stack root set**: The current GC implementations do not yet scan the call stack for the root set, such that the GC can only run on very specific moments when the stack is empty, such as before or after message calls, including continuation points (await). If memory grows too fast during a message call, the GC cannot reclaim memory in meantime, such that the programs runs out of heap space.

Specific:
- For compute-intense cases, utilization is relatively high (`extendable-token` and `random-maze`).
- Compacting GC allows many more allocations of larger objects (limit test case `blobs`).
- Copying GC scales higherr and is more efficient for smaller objects (limit cases `rb-tree` and `trie-map` and instruction total for all cases except `blobs`).
- A lot of temporary function-bound objects produce a high garbage load (e.g. cases `rb-tree`, `trie-map`).
