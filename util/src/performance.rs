use crate::{
    common::{self, average_f64, max_f64},
    test_case::TestCase,
};
use std::fmt::Write;

#[derive(Clone)]
pub struct Performance {
    pub test_case: TestCase,
    pub memory: Vec<u64>,
    pub heap: Vec<u64>,
    pub allocated: Vec<u64>,
    pub reclaimed: Vec<u64>,
    pub live: Vec<u64>,
    pub mutator: Vec<u64>,
    pub collector: Vec<u64>,
    pub cycles: Vec<u64>,
}

pub enum PerformanceMetric {
    FinalHeapSize,
    MemorySize,
    TotalAllocation,
    MutatorUtilization,
    MaxGcPause,
    AverageGcPause,
    TotalInstructions,
    TotalMutator,
    SurvivalRate,
    CyclesBurned,
}

impl PerformanceMetric {
    pub fn identifier(&self) -> &str {
        match &self {
            Self::FinalHeapSize => "finalHeapSize",
            Self::MemorySize => "memorySize",
            Self::TotalAllocation => "totalAllocation",
            Self::MutatorUtilization => "mutatorUtilization",
            Self::MaxGcPause => "maxGCPause",
            Self::AverageGcPause => "averageGCPause",
            Self::TotalInstructions => "totalInstructions",
            Self::TotalMutator => "totalMutator",
            Self::SurvivalRate => "survivalRate",
            Self::CyclesBurned => "cyclesBurned",
        }
    }

    pub fn name(&self) -> &str {
        match &self {
            Self::FinalHeapSize => "Final Heap Size",
            Self::MemorySize => "Memory Size",
            Self::TotalAllocation => "Total Allocation",
            Self::MutatorUtilization => "Mutator Utilization",
            Self::MaxGcPause => "Max GC Pause",
            Self::AverageGcPause => "Average GC Pause",
            Self::TotalInstructions => "Total Instructions",
            Self::TotalMutator => "Total Mutator",
            Self::SurvivalRate => "Survival Rate",
            Self::CyclesBurned => "Cycles Burned",
        }
    }

    pub fn summary_label(&self) -> &str {
        match &self {
            Self::MaxGcPause => "Maximum",
            _ => "Average",
        }
    }

    pub fn summary_value(&self, values: Vec<f64>) -> f64 {
        match &self {
            Self::MaxGcPause => max_f64(values),
            _ => average_f64(values),
        }
    }

    pub fn all() -> Vec<PerformanceMetric> {
        vec![
            Self::FinalHeapSize,
            Self::MemorySize,
            Self::TotalAllocation,
            Self::MutatorUtilization,
            Self::MaxGcPause,
            Self::AverageGcPause,
            Self::TotalInstructions,
            Self::TotalMutator,
            Self::SurvivalRate,
            Self::CyclesBurned,
        ]
    }
}

const GC_RELEVANCE_THRESHOLD: u64 = 10_000;

impl Performance {
    fn new(file_name: &str) -> Performance {
        Performance {
            test_case: TestCase::new(file_name),
            memory: Vec::new(),
            heap: Vec::new(),
            allocated: Vec::new(),
            reclaimed: Vec::new(),
            live: Vec::new(),
            mutator: Vec::new(),
            collector: Vec::new(),
            cycles: Vec::new(),
        }
    }

    pub fn parse(file_name: &str, content: &str) -> Performance {
        fn pick(row: &[u64], index: usize) -> u64 {
            *row.get(index).unwrap()
        }
        let mut performance = Performance::new(file_name);
        for line in content.split('\n').skip(1).filter(|x| !x.is_empty()) {
            let row: Vec<u64> = line
                .split(',')
                .map(|x| x.trim().parse::<u64>().expect("invalid number"))
                .collect();
            performance.memory.push(pick(&row, 1));
            performance.heap.push(pick(&row, 2));
            performance.allocated.push(pick(&row, 3));
            performance.reclaimed.push(pick(&row, 4));
            performance.live.push(pick(&row, 5));
            performance.mutator.push(pick(&row, 6));
            performance.collector.push(pick(&row, 7));
            performance.cycles.push(pick(&row, 8));
        }
        performance
    }

    pub fn final_heap_size(&self) -> u64 {
        *(self.heap.last()).unwrap_or(&0)
    }

    pub fn memory_size(&self) -> u64 {
        *(self.memory.iter().max()).unwrap_or(&0)
    }

    pub fn total_allocation(&self) -> u64 {
        *(self.allocated.iter().max()).unwrap_or(&0)
    }

    pub fn mutator_utilization(&self, minimum_mutator: u64) -> f64 {
        minimum_mutator as f64 / self.total_instructions() as f64
    }

    pub fn max_gc_pause(&self) -> u64 {
        let value = *(self.collector.iter().max()).unwrap_or(&0);
        if value > GC_RELEVANCE_THRESHOLD {
            value
        } else {
            0
        }
    }

    pub fn average_gc_pause(&self) -> f64 {
        let collector_total: u64 = self
            .collector
            .iter()
            .map(|value| {
                if *value > GC_RELEVANCE_THRESHOLD {
                    value
                } else {
                    &0
                }
            })
            .sum();
        collector_total as f64 / self.collector.len() as f64
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

    pub fn cycles_burned(&self) -> u64 {
        self.cycles.iter().max().unwrap_or(&0) - self.cycles.iter().min().unwrap_or(&0)
    }

    pub fn get_value(&self, metric: &PerformanceMetric, performance_base: u64) -> f64 {
        match metric {
            PerformanceMetric::FinalHeapSize => self.final_heap_size() as f64,
            PerformanceMetric::MemorySize => self.memory_size() as f64,
            PerformanceMetric::TotalAllocation => self.total_allocation() as f64,
            PerformanceMetric::MutatorUtilization => self.mutator_utilization(performance_base),
            PerformanceMetric::MaxGcPause => self.max_gc_pause() as f64,
            PerformanceMetric::AverageGcPause => self.average_gc_pause(),
            PerformanceMetric::TotalInstructions => self.total_instructions() as f64,
            PerformanceMetric::TotalMutator => self.total_mutator() as f64,
            PerformanceMetric::SurvivalRate => self.survival_rate(),
            PerformanceMetric::CyclesBurned => self.cycles_burned() as f64,
        }
    }

    pub fn display_value(metric: &PerformanceMetric, value: f64) -> String {
        match metric {
            PerformanceMetric::FinalHeapSize
            | PerformanceMetric::MemorySize
            | PerformanceMetric::TotalAllocation => {
                let value = common::to_mb(value as u64);
                let mut result = String::new();
                write!(&mut result, "{value}").unwrap();
                result
            }
            PerformanceMetric::MutatorUtilization | PerformanceMetric::SurvivalRate => {
                let value = value * 100.0;
                let mut result = String::new();
                write!(&mut result, "{value:.1}").unwrap();
                result
            }
            PerformanceMetric::MaxGcPause | PerformanceMetric::AverageGcPause => {
                let mut result = String::new();
                write!(&mut result, "{value:.2e}").unwrap();
                result
            }
            PerformanceMetric::TotalInstructions
            | PerformanceMetric::TotalMutator
            | PerformanceMetric::CyclesBurned => {
                let mut result = String::new();
                write!(&mut result, "{value:.2e}").unwrap();
                result
            }
        }
    }

    pub fn unit_suffix(metric: &PerformanceMetric) -> &str {
        match metric {
            PerformanceMetric::FinalHeapSize
            | PerformanceMetric::MemorySize
            | PerformanceMetric::TotalAllocation => " MB",
            PerformanceMetric::MutatorUtilization | PerformanceMetric::SurvivalRate => " %",
            PerformanceMetric::MaxGcPause
            | PerformanceMetric::AverageGcPause
            | PerformanceMetric::TotalInstructions
            | PerformanceMetric::TotalMutator
            | PerformanceMetric::CyclesBurned => "",
        }
    }

    pub fn display_with_unit(metric: &PerformanceMetric, value: f64) -> String {
        Self::display_value(metric, value) + Self::unit_suffix(metric)
    }

    pub fn logarithmic_scale(metric: &PerformanceMetric) -> bool {
        match metric {
            PerformanceMetric::FinalHeapSize
            | PerformanceMetric::MemorySize
            | PerformanceMetric::TotalAllocation => true,
            PerformanceMetric::MutatorUtilization | PerformanceMetric::SurvivalRate => false,
            PerformanceMetric::MaxGcPause
            | PerformanceMetric::AverageGcPause
            | PerformanceMetric::TotalInstructions
            | PerformanceMetric::TotalMutator
            | PerformanceMetric::CyclesBurned => false,
        }
    }

    pub fn scientific_representation(metric: &PerformanceMetric) -> bool {
        match metric {
            PerformanceMetric::FinalHeapSize
            | PerformanceMetric::MemorySize
            | PerformanceMetric::TotalAllocation => false,
            PerformanceMetric::MutatorUtilization | PerformanceMetric::SurvivalRate => false,
            PerformanceMetric::MaxGcPause
            | PerformanceMetric::AverageGcPause
            | PerformanceMetric::TotalInstructions
            | PerformanceMetric::TotalMutator
            | PerformanceMetric::CyclesBurned => true,
        }
    }

    pub fn show_no_gc(metric: &PerformanceMetric) -> bool {
        match metric {
            PerformanceMetric::FinalHeapSize
            | PerformanceMetric::MemorySize
            | PerformanceMetric::TotalAllocation => true,
            PerformanceMetric::MutatorUtilization | PerformanceMetric::SurvivalRate => false,
            PerformanceMetric::MaxGcPause
            | PerformanceMetric::AverageGcPause
            | PerformanceMetric::TotalInstructions
            | PerformanceMetric::TotalMutator
            | PerformanceMetric::CyclesBurned => false,
        }
    }
}
