use crate::{benchmark::Benchmark, limit::LimitMetric, measurement::Metric};
use std::fmt::Write;

pub struct SummaryPage {
    benchmark: Benchmark,
}

impl SummaryPage {
    pub fn new(benchmark: Benchmark) -> SummaryPage {
        SummaryPage { benchmark }
    }

    pub fn render(&self) -> String {
        let mut output = String::new();
        output
            .push_str("<html><head><title>GC Benchmark</title></head><body><h1>GC Benchmark</h1>");
        output.push_str("<h2>Performance</h2>");
        for metric in Metric::all() {
            self.render_performance_metric(&mut output, metric);
        }
        output.push_str("<h2>Limits</h2>");
        for metric in LimitMetric::all() {
            self.render_limit_metric(&mut output, metric);
        }
        output.push_str("<h2>Summary</h2>");
        self.render_performance_summary(&mut output);
        self.render_limit_summary(&mut output);
        output.push_str("</body></html>");
        output
    }

    fn render_performance_summary(&self, output: &mut String) {
        output.push_str("<h2>Performance</h2>");
        output.push_str("<table><thead><th>Scenario</th>");
        for metric in Metric::all() {
            let metric_name = metric.name();
            write!(output, "<th>{metric_name}</th>").unwrap()
        }
        output.push_str("</thead>");
        for measurement in &self.benchmark.measurements {
            let scenario_name = &measurement.test_case.scenario_name;
            let gc_type = &measurement.test_case.gc_type;
            write!(output, "<tr><td><a href=\"chart-{scenario_name}-{gc_type}.html\">{scenario_name} ({gc_type})</a></td>").unwrap();
            for metric in Metric::all() {
                let value = measurement.get_value(&metric);
                write!(output, "<td>{value}</td>").unwrap()
            }
            output.push_str("</tr>")
        }
        output.push_str("</table>");
    }

    fn render_performance_metric(&self, output: &mut String, metric: Metric) {
        let metric_name = metric.name();
        write!(output, "<h3>{metric_name}</h3>").unwrap();
        output.push_str("<table><thead><th>Scenario</th>");
        for gc_type in &self.benchmark.gc_types {
            write!(output, "<th>{gc_type}</th>").unwrap();
        }
        output.push_str("</thead>");
        for scenario_name in &self.benchmark.measurement_scenarios {
            write!(output, "<tr><td>{scenario_name}</td>").unwrap();
            for gc_type in &self.benchmark.gc_types {
                match self.benchmark.get_measurement(scenario_name, gc_type) {
                    Some(measurement) => {
                        let value = measurement.get_value(&metric);
                        write!(
                            output,
                            "<td><a href=\"chart-{scenario_name}-{gc_type}.html\">{value}</a></td>"
                        )
                        .unwrap()
                    }
                    None => output.push_str("<td>--</td>"),
                }
            }
            output.push_str("</tr>");
        }
        output.push_str("</table>");
    }

    fn render_limit_summary(&self, output: &mut String) {
        output.push_str("<h2>Limits</h2>");
        output.push_str(
            "<table><thead><th>Scenario</th><th>Allocations</th><th>Heap Maximum</th></thead>",
        );
        for limit in &self.benchmark.limits {
            let allocations = limit.allocations;
            let heap_size = limit.heap / (1024 * 1024);
            let name = &limit.test_case.scenario_name;
            let gc_type = &limit.test_case.gc_type;
            write!(
                output,
                "<tr><td>{name} ({gc_type})</td><td>{allocations}</td><td>{heap_size} MB</td></tr>"
            )
            .unwrap();
        }
        output.push_str("</table>");
    }

    fn render_limit_metric(&self, output: &mut String, metric: LimitMetric) {
        let metric_name = metric.name();
        write!(output, "<h3>{metric_name}</h3>").unwrap();
        output.push_str("<table><thead><th>Scenario</th>");
        for gc_type in &self.benchmark.gc_types {
            write!(output, "<th>{gc_type}</th>").unwrap();
        }
        output.push_str("</thead>");
        for scenario_name in &self.benchmark.limits_scenarios {
            write!(output, "<tr><td>{scenario_name}</td>").unwrap();
            for gc_type in &self.benchmark.gc_types {
                match self.benchmark.get_limits(scenario_name, gc_type) {
                    Some(measurement) => {
                        let value = measurement.get_value(&metric);
                        write!(
                            output,
                            "<td><a href=\"chart-{scenario_name}-{gc_type}.html\">{value}</a></td>"
                        )
                        .unwrap()
                    }
                    None => output.push_str("<td>--</td>"),
                }
            }
            output.push_str("</tr>");
        }
        output.push_str("</table>");
    }
}
