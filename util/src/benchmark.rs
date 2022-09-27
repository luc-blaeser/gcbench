use crate::{limit::Limit, measurement::Measurement};

pub struct Benchmark {
    pub measurements: Vec<Measurement>,
    pub limits: Vec<Limit>,
    pub gc_types: Vec<String>,
    pub measurement_scenarios: Vec<String>,
    pub limits_scenarios: Vec<String>,
}

impl Benchmark {
    pub fn new(measurements: Vec<Measurement>, limits: Vec<Limit>) -> Benchmark {
        let gc_types: Vec<String> = limits.iter().map(|l| l.test_case.gc_type.clone()).collect();
        let mut gc_types: Vec<String> = measurements
            .iter()
            .map(|m| m.test_case.gc_type.clone())
            .chain(gc_types)
            .collect();
        gc_types.sort();
        gc_types.dedup();
        let mut measurement_scenarios: Vec<String> = measurements
            .iter()
            .map(|m| String::from(&m.test_case.scenario_name))
            .collect();
        measurement_scenarios.sort();
        measurement_scenarios.dedup();
        let mut limits_scenarios: Vec<String> = limits
            .iter()
            .map(|m| String::from(&m.test_case.scenario_name))
            .collect();
        limits_scenarios.sort();
        limits_scenarios.dedup();
        Benchmark {
            measurements: measurements.to_vec(),
            limits: limits.to_vec(),
            gc_types,
            measurement_scenarios,
            limits_scenarios,
        }
    }

    pub fn get_measurement(&self, scenario_name: &str, gc_type: &str) -> Option<&Measurement> {
        self.measurements
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
