use crate::{benchmark::Benchmark, limit::LimitMetric, performance::PerformanceMetric};
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
        output.push_str("<!DOCTYPE html><html><head><title>GC Benchmark</title><link rel=\"stylesheet\" href=\"style.css\"/></head>");
        output.push_str("<body><h1>GC Benchmark</h1>");
        output.push_str("<h2>Performance</h2>");
        for metric in PerformanceMetric::all() {
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
        output.push_str("<h3>Performance</h3>");
        output.push_str("<table><thead><th>Scenario</th>");
        for metric in PerformanceMetric::all() {
            let metric_name = metric.name();
            write!(output, "<th>{metric_name}</th>").unwrap()
        }
        output.push_str("</thead>");
        for performance in &self.benchmark.performance {
            let scenario_name = &performance.test_case.scenario_name;
            let gc_type = &performance.test_case.gc_type;
            write!(output, "<tr><td><a href=\"chart-{scenario_name}-{gc_type}.html\">{scenario_name} ({gc_type} GC)</a></td>").unwrap();
            for metric in PerformanceMetric::all() {
                let value = performance.get_value(&metric);
                write!(output, "<td>{value}</td>").unwrap()
            }
            output.push_str("</tr>")
        }
        output.push_str("</table>");
    }

    fn render_performance_metric(&self, output: &mut String, metric: PerformanceMetric) {
        let metric_name = metric.name();
        write!(output, "<h3>{metric_name}</h3>").unwrap();
        output.push_str("<table><thead><th>Scenario</th>");
        for gc_type in &self.benchmark.gc_types {
            write!(output, "<th>{gc_type} GC</th>").unwrap();
        }
        output.push_str("</thead>");
        for scenario_name in &self.benchmark.performance_scenarios {
            write!(output, "<tr><td>{scenario_name}</td>").unwrap();
            for gc_type in &self.benchmark.gc_types {
                match self.benchmark.get_performance(scenario_name, gc_type) {
                    Some(performance) => {
                        let value = performance.get_value(&metric);
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
        output.push_str("<h3>Limits</h3>");
        output.push_str("<table><thead><th>Scenario</th>");
        for metric in LimitMetric::all() {
            let metric_name = metric.name();
            write!(output, "<th>{metric_name}</th>").unwrap()
        }
        output.push_str("</thead>");
        for limits in &self.benchmark.limits {
            let scenario_name = &limits.test_case.scenario_name;
            let gc_type = &limits.test_case.gc_type;
            write!(output, "<tr><td>{scenario_name} ({gc_type} GC)</td>").unwrap();
            for metric in LimitMetric::all() {
                let value = limits.get_value(&metric);
                write!(output, "<td>{value}</td>").unwrap()
            }
            output.push_str("</tr>")
        }
        output.push_str("</table>");
    }

    fn render_limit_metric(&self, output: &mut String, metric: LimitMetric) {
        let metric_name = metric.name();
        write!(output, "<h3>{metric_name}</h3>").unwrap();
        output.push_str("<table><thead><th>Scenario</th>");
        for gc_type in &self.benchmark.gc_types {
            write!(output, "<th>{gc_type} GC</th>").unwrap();
        }
        output.push_str("</thead>");
        for scenario_name in &self.benchmark.limits_scenarios {
            write!(output, "<tr><td>{scenario_name}</td>").unwrap();
            for gc_type in &self.benchmark.gc_types {
                match self.benchmark.get_limits(scenario_name, gc_type) {
                    Some(limits) => {
                        let value = limits.get_value(&metric);
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
