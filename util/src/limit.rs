use crate::{common, test_case::TestCase};
use std::fmt::Write;

#[derive(Clone)]
pub struct Limit {
    pub test_case: TestCase,
    pub allocations: u64,
    pub heap: u64,
}

pub enum LimitMetric {
    AllocationLimit,
    HeapMaximum,
}

impl LimitMetric {
    pub fn name(&self) -> &str {
        match &self {
            Self::AllocationLimit => "Allocation Limit",
            Self::HeapMaximum => "Heap Maximum",
        }
    }

    pub fn all() -> Vec<LimitMetric> {
        vec![Self::AllocationLimit, Self::HeapMaximum]
    }
}

impl Limit {
    pub fn parse(file_name: &str, content: &str) -> Limit {
        fn pick(row: &[u64], index: usize) -> u64 {
            *row.get(index).unwrap()
        }
        let line = content
            .split('\n')
            .skip(1)
            .filter(|x| !x.is_empty())
            .last()
            .unwrap_or("0, 0");
        let row: Vec<u64> = line
            .split(',')
            .map(|x| x.trim().parse::<u64>().expect("invalid number"))
            .collect();
        let allocations = pick(&row, 0);
        let heap = pick(&row, 1);
        Limit {
            test_case: TestCase::new(file_name),
            allocations,
            heap,
        }
    }

    pub fn get_value(&self, metric: &LimitMetric) -> String {
        match metric {
            LimitMetric::AllocationLimit => {
                let value = self.allocations;
                let mut result = String::new();
                write!(&mut result, "{value}").unwrap();
                result
            }
            LimitMetric::HeapMaximum => {
                let value = common::to_mb(self.heap);
                let mut result = String::new();
                write!(&mut result, "{value} MB").unwrap();
                result
            }
        }
    }
}
