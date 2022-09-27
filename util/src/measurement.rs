use crate::{common, test_case::TestCase};
use std::fmt::Write;

#[derive(Clone)]
pub struct Measurement {
    pub test_case: TestCase,
    pub labels: Vec<u64>,
    pub memory: Vec<u64>,
    pub heap: Vec<u64>,
    pub allocated: Vec<u64>,
    pub reclaimed: Vec<u64>,
    pub live: Vec<u64>,
    pub mutator: Vec<u64>,
    pub collector: Vec<u64>,
}

pub enum Metric {
    HeapSize,
    MemoryOverhead,
    MutatorUtilization,
    MaxGcPause,
    MMU,
    TotalInstructions,
    TotalMutator,
    SurvivalRate,
}

impl Metric {
    pub fn name(&self) -> &str {
        match &self {
            Self::HeapSize => "Heap Size",
            Self::MemoryOverhead => "Memory Overhead",
            Self::MutatorUtilization => "Mutator Utilization",
            Self::MaxGcPause => "Max GC Pause",
            Self::MMU => "Minimum Mutator Utilization (MMU)",
            Self::TotalInstructions => "Total Instructions",
            Self::TotalMutator => "Total Mutator",
            Self::SurvivalRate => "Survival Rate",
        }
    }

    pub fn all() -> Vec<Metric> {
        vec![
            Self::HeapSize,
            Self::MemoryOverhead,
            Self::MutatorUtilization,
            Self::MaxGcPause,
            Self::MMU,
            Self::TotalInstructions,
            Self::TotalMutator,
            Self::SurvivalRate,
        ]
    }
}

const GC_RELEVANCE_THRESHOLD: u64 = 1000;

impl Measurement {
    fn new(file_name: &str) -> Measurement {
        Measurement {
            test_case: TestCase::new(file_name),
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

    pub fn parse(file_name: &str, content: &str) -> Measurement {
        fn pick(row: &[u64], index: usize) -> u64 {
            *row.get(index).unwrap()
        }
        let mut measurement = Measurement::new(file_name);
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
        let value = *(self.collector.iter().max()).unwrap_or(&0);
        if value > GC_RELEVANCE_THRESHOLD {
            value
        } else {
            0
        }
    }

    pub fn minimum_mutator_utilization(&self) -> f64 {
        self.mutator
            .iter()
            .zip(self.collector.iter())
            .map(|(m, c)| {
                if *c > GC_RELEVANCE_THRESHOLD {
                    (m, c)
                } else {
                    (m, &0)
                }
            })
            .map(|(m, c)| *m as f64 / (*m as f64 + *c as f64))
            .fold(f64::INFINITY, |x, y| x.min(y))
    }

    pub fn total_instructions(&self) -> u64 {
        self.mutator.iter().sum::<u64>() + self.collector.iter().sum::<u64>()
    }

    pub fn total_mutator(&self) -> u64 {
        self.mutator.iter().sum::<u64>()
    }

    pub fn survival_rate(&self) -> f64 {
        let mut alive = 0;
        let mut reclaimed = 0;
        let mut survival_rates: Vec<f64> = Vec::new();
        for index in 0..self.mutator.len() {
            alive += self.allocated.get(index).unwrap();
            reclaimed += self.reclaimed.get(index).unwrap();
            // ignore very low collector count as GC did not run then
            if self.collector.get(index).unwrap() > &GC_RELEVANCE_THRESHOLD {
                let rate = 1.0 - reclaimed as f64 / alive as f64;
                survival_rates.push(rate);
                alive -= reclaimed;
                reclaimed = 0;
            }
        }
        survival_rates.iter().sum::<f64>() / survival_rates.len() as f64
    }

    pub fn get_value(&self, metric: &Metric) -> String {
        match metric {
            Metric::HeapSize => {
                let value = common::to_mb(self.heap_size());
                let mut result = String::new();
                write!(&mut result, "{value} MB").unwrap();
                result
            }
            Metric::MemoryOverhead => {
                let value = self.memory_overhead() * 100.0;
                let mut result = String::new();
                write!(&mut result, "{value:.1} %").unwrap();
                result
            }
            Metric::MutatorUtilization => {
                let value = self.mutator_utilization() * 100.0;
                let mut result = String::new();
                write!(&mut result, "{value:.1} %").unwrap();
                result
            }
            Metric::MaxGcPause => {
                let value = self.max_gc_pause() as f64;
                let mut result = String::new();
                write!(&mut result, "{value:.1e}").unwrap();
                result
            }
            Metric::MMU => {
                let value = self.minimum_mutator_utilization() * 100.0;
                let mut result = String::new();
                write!(&mut result, "{value:.1} %").unwrap();
                result
            }
            Metric::TotalInstructions => {
                let value = self.total_instructions() as f64;
                let mut result = String::new();
                write!(&mut result, "{value:.1e}").unwrap();
                result
            }
            Metric::TotalMutator => {
                let value = self.total_mutator() as f64;
                let mut result = String::new();
                write!(&mut result, "{value:.1e}").unwrap();
                result
            }
            Metric::SurvivalRate => {
                let value = self.survival_rate() * 100.0;
                let mut result = String::new();
                write!(&mut result, "{value:.1} %").unwrap();
                result
            }
        }
    }
}
