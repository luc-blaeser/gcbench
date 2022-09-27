use crate::{limit::Limit, performance::Performance};

pub struct Benchmark {
    pub performance: Vec<Performance>,
    pub limits: Vec<Limit>,
    pub gc_types: Vec<String>,
    pub performance_scenarios: Vec<String>,
    pub limits_scenarios: Vec<String>,
}

impl Benchmark {
    pub fn new(performance: Vec<Performance>, limits: Vec<Limit>) -> Benchmark {
        let gc_types: Vec<String> = limits.iter().map(|l| l.test_case.gc_type.clone()).collect();
        let mut gc_types: Vec<String> = performance
            .iter()
            .map(|m| m.test_case.gc_type.clone())
            .chain(gc_types)
            .collect();
        gc_types.sort();
        gc_types.dedup();
        let mut performance_scenarios: Vec<String> = performance
            .iter()
            .map(|m| String::from(&m.test_case.scenario_name))
            .collect();
        performance_scenarios.sort();
        performance_scenarios.dedup();
        let mut limits_scenarios: Vec<String> = limits
            .iter()
            .map(|m| String::from(&m.test_case.scenario_name))
            .collect();
        limits_scenarios.sort();
        limits_scenarios.dedup();
        Benchmark {
            performance: performance.to_vec(),
            limits: limits.to_vec(),
            gc_types,
            performance_scenarios,
            limits_scenarios,
        }
    }

    pub fn get_performance(&self, scenario_name: &str, gc_type: &str) -> Option<&Performance> {
        self.performance
            .iter()
            .filter(|m| {
                m.test_case.scenario_name == scenario_name && m.test_case.gc_type == gc_type
            })
            .last()
    }

    pub fn get_limits(&self, scenario_name: &str, gc_type: &str) -> Option<&Limit> {
        self.limits
            .iter()
            .filter(|m| {
                m.test_case.scenario_name == scenario_name && m.test_case.gc_type == gc_type
            })
            .last()
    }
}
