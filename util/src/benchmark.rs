use crate::{
    dirty_pages::DirtyPages,
    limit::Limit,
    performance::{Performance, PerformanceMetric},
};

pub struct Benchmark {
    pub performance: Vec<Performance>,
    pub limits: Vec<Limit>,
    pub dirty_pages: Vec<DirtyPages>,
    pub gc_types: Vec<String>,
    pub performance_scenarios: Vec<String>,
    pub limits_scenarios: Vec<String>,
    pub dirty_pages_scenarios: Vec<String>,
}

impl Benchmark {
    pub fn new(
        performance: Vec<Performance>,
        limits: Vec<Limit>,
        dirty_pages: Vec<DirtyPages>,
    ) -> Benchmark {
        let gc_types: Vec<String> = limits.iter().map(|l| l.test_case.gc_type.clone()).collect();
        let mut gc_types: Vec<String> = performance
            .iter()
            .map(|m| m.test_case.gc_type.clone())
            .chain(gc_types)
            .collect();
        gc_types = Self::arrange_gc_types(&mut gc_types);
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
        let mut dirty_pages_scenarios: Vec<String> = dirty_pages
            .iter()
            .map(|m| String::from(&m.test_case.scenario_name))
            .collect();
        dirty_pages_scenarios.sort();
        dirty_pages_scenarios.dedup();
        Benchmark {
            performance: performance.to_vec(),
            limits: limits.to_vec(),
            dirty_pages: dirty_pages.to_vec(),
            gc_types,
            performance_scenarios,
            limits_scenarios,
            dirty_pages_scenarios,
        }
    }

    fn arrange_gc_types(gc_types: &mut Vec<String>) -> Vec<String> {
        gc_types.sort();
        gc_types.dedup();
        let expected = vec!["incremental", "generational", "compacting", "copying", "no"];
        let mut result: Vec<String> = vec![];
        for gc_name in expected.iter().map(|str| String::from(*str)) {
            if gc_types.contains(&gc_name) {
                result.push(gc_name);
            }
        }
        for gc_name in gc_types {
            if !expected.contains(&gc_name.as_str()) {
                result.push(gc_name.clone());
            }
        }
        result
    }

    pub fn get_performance(&self, scenario_name: &str, gc_type: &str) -> Option<&Performance> {
        self.performance
            .iter()
            .filter(|m| {
                m.test_case.scenario_name == scenario_name && m.test_case.gc_type == gc_type
            })
            .last()
    }

    pub fn get_performance_base(&self, scenario_name: &str, metric: &PerformanceMetric) -> u64 {
        match metric {
            PerformanceMetric::MutatorUtilization => self
                .performance
                .iter()
                .filter(|m| m.test_case.scenario_name == scenario_name)
                .map(|p| p.total_mutator())
                .min()
                .unwrap_or(0),
            _ => 0,
        }
    }

    pub fn get_limits(&self, scenario_name: &str, gc_type: &str) -> Option<&Limit> {
        self.limits
            .iter()
            .filter(|m| {
                m.test_case.scenario_name == scenario_name && m.test_case.gc_type == gc_type
            })
            .last()
    }

    pub fn get_dirty_pages(&self, scenario_name: &str, gc_type: &str) -> Option<&DirtyPages> {
        self.dirty_pages
            .iter()
            .filter(|m| {
                m.test_case.scenario_name == scenario_name && m.test_case.gc_type == gc_type
            })
            .last()
    }
}
