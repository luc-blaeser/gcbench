use crate::measurement::Measurement;
use std::fmt::Write;

pub struct SummaryPage {
    measurements: Vec<Measurement>,
}

impl SummaryPage {
    pub fn new(measurements: Vec<Measurement>) -> SummaryPage {
        SummaryPage {
            measurements: measurements.to_vec(),
        }
    }

    pub fn render(&self) -> String {
        let prefix = "measurement-";
        let suffix = ".csv";
        let mut output = String::new();
        output.push_str("<html><head><title>GC Measurement Summary</title></head><body><h1>GC Measurement Summary</h1><table><thead><th>Scenario</th><th>Heap Size</th><th>Memory Overhead</th><th>Mutator Utilization</th><th>Max GC Pause</th><th>Minimum Mutator Utilization (MMU)</th></thead>");
        for measurement in &self.measurements {
            let heap_size = measurement.heap_size() / (1024 * 1024);
            let memory_overhead = measurement.memory_overhead() * 100.0;
            let mutator_utilization = measurement.mutator_utilization() * 100.0;
            let max_gc_pause = measurement.max_gc_pause() as f64 / 1e9;
            let mmu = measurement.minimum_mutator_utilization() * 100.0;
            assert!(measurement.name.starts_with(prefix) && measurement.name.ends_with(suffix));
            let name = &measurement.name[prefix.len()..measurement.name.len() - suffix.len()];
            write!(output, "<tr><td><a href=\"chart-{name}.html\">{name}</a></td><td>{heap_size} MB</td><td>{memory_overhead:.1} %</td><td>{mutator_utilization:.1} %</td><td>{max_gc_pause:0.1} E+9</td><td>{mmu:.1} %</td></tr>").unwrap();
        }
        output.push_str("</table></body></html>");
        output
    }
}
