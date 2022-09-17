#[derive(Clone)]
pub struct Measurement {
    pub name: String,
    pub labels: Vec<u64>,
    pub memory: Vec<u64>,
    pub heap: Vec<u64>,
    pub allocated: Vec<u64>,
    pub reclaimed: Vec<u64>,
    pub live: Vec<u64>,
    pub mutator: Vec<u64>,
    pub collector: Vec<u64>,
}

impl Measurement {
    fn new(name: &str) -> Measurement {
        Measurement {
            name: String::from(name),
            labels: Vec::new(),
            memory: Vec::new(),
            heap: Vec::new(),
            allocated: Vec::new(),
            reclaimed: Vec::new(),
            live: Vec::new(),
            mutator: Vec::new(),
            collector: Vec::new(),
        }
    }

    pub fn parse(name: &str, content: &str) -> Measurement {
        fn pick(row: &[u64], index: usize) -> u64 {
            *row.get(index).unwrap()
        }
        let mut measurement = Measurement::new(name);
        for line in content.split('\n').skip(1).filter(|x| !x.is_empty()) {
            let row: Vec<u64> = line
                .split(',')
                .map(|x| x.trim().parse::<u64>().expect("invalid number"))
                .collect();
            measurement.labels.push(pick(&row, 0));
            measurement.memory.push(pick(&row, 1));
            measurement.heap.push(pick(&row, 2));
            measurement.allocated.push(pick(&row, 3));
            measurement.reclaimed.push(pick(&row, 4));
            measurement.live.push(pick(&row, 5));
            measurement.mutator.push(pick(&row, 6));
            measurement.collector.push(pick(&row, 7));
        }
        measurement
    }

    pub fn heap_size(&self) -> u64 {
        *(self.heap.last()).unwrap_or(&0)
    }

    pub fn memory_overhead(&self) -> f64 {
        let heap_max = *(self.heap.iter().max()).unwrap_or(&0);
        let mem_max = *(self.memory.iter().max()).unwrap_or(&0);
        (mem_max as f64 - heap_max as f64) / heap_max as f64
    }

    pub fn mutator_utilization(&self) -> f64 {
        let mutator_total: u64 = self.mutator.iter().sum();
        let collector_total: u64 = self.collector.iter().sum();
        mutator_total as f64 / (mutator_total as f64 + collector_total as f64)
    }

    pub fn max_gc_pause(&self) -> u64 {
        *(self.collector.iter().max()).unwrap_or(&0)
    }

    pub fn minimum_mutator_utilization(&self) -> f64 {
        self.mutator
            .iter()
            .zip(self.collector.iter())
            .map(|(m, c)| *m as f64 / (*m as f64 + *c as f64))
            .fold(f64::INFINITY, |x, y| x.min(y))
    }
}
