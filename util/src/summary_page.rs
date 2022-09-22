use crate::limit::Limit;
use crate::measurement::Measurement;
use std::fmt::Write;

pub struct SummaryPage {
    measurements: Vec<Measurement>,
    limits: Vec<Limit>,
}

impl SummaryPage {
    pub fn new(measurements: Vec<Measurement>, limits: Vec<Limit>) -> SummaryPage {
        SummaryPage {
            measurements: measurements.to_vec(),
            limits: limits.to_vec(),
        }
    }

    pub fn render(&self) -> String {
        let mut output = String::new();
        output.push_str("<html><head><title>GC Measurement Summary</title></head><body><h1>GC Measurement Summary</h1>");
        self.render_measurements(&mut output);
        self.render_limits(&mut output);
        output.push_str("</body></html>");
        output
    }

    fn render_measurements(&self, output: &mut String) {
        let prefix = "measurement-";
        let suffix = ".csv";
        let mb = 1024 * 1024;
        output.push_str("<h2>Benchmark</h2>");
        output.push_str("<table><thead><th>Scenario</th><th>Heap Size</th><th>Memory Overhead</th><th>Mutator Utilization</th><th>Max GC Pause</th><th>Minimum Mutator Utilization (MMU)</th><th>Instruction Total</th><th>Survival Rate</th></thead>");
        for measurement in &self.measurements {
            let heap_size = (measurement.heap_size() + mb - 1) / mb;
            let memory_overhead = measurement.memory_overhead() * 100.0;
            let mutator_utilization = measurement.mutator_utilization() * 100.0;
            let max_gc_pause = measurement.max_gc_pause() as f64;
            let mmu = measurement.minimum_mutator_utilization() * 100.0;
            let instruction_total = measurement.instruction_total() as f64;
            let survival_rate = measurement.survival_rate() * 100.0;
            let name = Self::cut_off(&measurement.name, prefix, suffix);
            write!(output, "<tr><td><a href=\"chart-{name}.html\">{name}</a></td><td>{heap_size} MB</td><td>{memory_overhead:.1} %</td><td>{mutator_utilization:.1} %</td><td>{max_gc_pause:.1e}</td><td>{mmu:.1} %</td><td>{instruction_total:.1e}</td><td>{survival_rate:.1} %</td></tr>").unwrap();
        }
        output.push_str("</table>");
    }

    fn render_limits(&self, output: &mut String) {
        let prefix = "limit-";
        let suffix = ".csv";
        output.push_str("<h2>Limits</h2>");
        output.push_str(
            "<table><thead><th>Scenario</th><th>Allocations</th><th>Heap Maximum</th></thead>",
        );
        for limit in &self.limits {
            let allocations = limit.allocations;
            let heap_size = limit.heap / (1024 * 1024);
            let name = Self::cut_off(&limit.name, prefix, suffix);
            write!(
                output,
                "<tr><td>{name}</td><td>{allocations}</td><td>{heap_size} MB</td></tr>"
            )
            .unwrap();
        }
        output.push_str("</table>");
    }

    fn cut_off<'a>(name: &'a str, prefix: &'a str, suffix: &'a str) -> &'a str {
        assert!(name.starts_with(prefix) && name.ends_with(suffix));
        &name[prefix.len()..name.len() - suffix.len()]
    }
}
