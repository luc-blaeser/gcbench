use crate::{
    benchmark::Benchmark,
    common::average_u64,
    limit::{Limit, LimitMetric},
    performance::{Performance, PerformanceMetric},
};
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
        output.push_str("<!DOCTYPE html><html><head><title>GC Benchmark</title>");
        output.push_str("<link rel=\"stylesheet\" href=\"style.css\"/>");
        output.push_str("<script src=\"https://cdn.jsdelivr.net/npm/chart.js\"></script>");
        output.push_str("<script>Chart.defaults.font.size = 20;</script>");
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
            write!(output, "<tr><td><a href=\"chart-{scenario_name}-{gc_type}.html?#\">{scenario_name} ({gc_type} GC)</a></td>").unwrap();
            for metric in PerformanceMetric::all() {
                let performance_base = self.benchmark.get_performance_base(scenario_name, &metric);
                let value = Performance::display_with_unit(
                    &metric,
                    performance.get_value(&metric, performance_base),
                );
                write!(output, "<td>{value}</td>").unwrap()
            }
            output.push_str("</tr>")
        }
        output.push_str("</table>");
    }

    fn render_performance_metric(&self, output: &mut String, metric: PerformanceMetric) {
        let metric_name = metric.name();
        write!(output, "<h3>{metric_name}</h3>").unwrap();
        self.render_performance_summary_chart(output, &metric);
        output.push_str("<table><thead><tr><th>Scenario</th>");
        for gc_type in &self.benchmark.gc_types {
            write!(output, "<th>{gc_type} GC</th>").unwrap();
        }
        output.push_str("</tr></thead>");
        for scenario_name in &self.benchmark.performance_scenarios {
            let performance_base = self.benchmark.get_performance_base(scenario_name, &metric);
            write!(output, "<tr><td>{scenario_name}</td>").unwrap();
            for gc_type in &self.benchmark.gc_types {
                match self.benchmark.get_performance(scenario_name, gc_type) {
                    Some(performance) => {
                        let value = Performance::display_with_unit(
                            &metric,
                            performance.get_value(&metric, performance_base),
                        );
                        write!(
                            output,
                            "<td><a href=\"chart-{scenario_name}-{gc_type}.html?#\">{value}</a></td>"
                        )
                        .unwrap()
                    }
                    None => output.push_str("<td>--</td>"),
                }
            }
            output.push_str("</tr>");
        }
        let summary_label = metric.summary_label();
        write!(output, "<tr><tfoot><tr><td>{summary_label}</td>").unwrap();
        for gc_type in &self.benchmark.gc_types {
            let values: Vec<f64> = self
                .benchmark
                .performance_scenarios
                .iter()
                .map(|scenario_name| {
                    (
                        self.benchmark.get_performance(scenario_name, gc_type),
                        self.benchmark.get_performance_base(scenario_name, &metric),
                    )
                })
                .filter(|pair| pair.0.is_some())
                .map(|pair| pair.0.unwrap().get_value(&metric, pair.1))
                .collect();
            let summary_value =
                Performance::display_with_unit(&metric, metric.summary_value(values));
            write!(output, "<td>{summary_value}</td>").unwrap();
        }
        output.push_str("</tr></tfoot>");
        output.push_str("</table>");
    }

    fn render_performance_summary_chart(&self, output: &mut String, metric: &PerformanceMetric) {
        let chart_id = metric.identifier().to_owned() + "Id";
        let chart_variable = metric.identifier().to_owned() + "Chart";
        let chart_data = metric.identifier().to_owned() + "Data";
        let unit_suffix = Performance::unit_suffix(metric);
        write!(
            output,
            "<div class=\"summary-chart\"><canvas id=\"{chart_id}\"></canvas></div>"
        )
        .unwrap();
        write!(
            output,
            "<script>const {chart_variable} = document.getElementById('{chart_id}');"
        )
        .unwrap();
        write!(output, "const {chart_data} = {{labels: [").unwrap();
        for scenario_name in &self.benchmark.performance_scenarios {
            write!(output, "'{scenario_name}', ").unwrap();
        }
        output.push_str("], datasets: [");
        for gc_type in &self.benchmark.gc_types {
            if gc_type != "no" || Performance::show_no_gc(metric) {
                write!(output, "{{ label: '{gc_type} GC', data: [").unwrap();
                for scenario_name in &self.benchmark.performance_scenarios {
                    let performance_base =
                        self.benchmark.get_performance_base(scenario_name, metric);
                    let value = match self.benchmark.get_performance(scenario_name, gc_type) {
                        Some(performance) => performance.get_value(metric, performance_base),
                        None => 0.0,
                    };
                    let display_value = Performance::display_value(metric, value);
                    write!(output, "{display_value}, ").unwrap();
                }
                let bar_color = self.get_bar_color(gc_type);
                write!(
                    output,
                    "], borderColor: 'rgb(0, 0, 0)', backgroundColor: '{bar_color}', }},"
                )
                .unwrap();
            }
        }
        write!(output, "]}};").unwrap();
        write!(
            output,
            "new Chart({chart_variable}, {{ type: 'bar', data: {chart_data}, "
        )
        .unwrap();
        write!(output, "options: {{scales: {{y: {{").unwrap();
        if Performance::logarithmic_scale(metric) {
            write!(output, "type: 'logarithmic',").unwrap();
        }
        write!(output, "beginAtZero: true,ticks: {{maxTicksLimit: 10,").unwrap();
        write!(output, "callback: function (value, index, ticks) {{return ").unwrap();
        if Performance::scientific_representation(metric) {
            write!(output, "value.toExponential()").unwrap();
        } else {
            write!(output, "value").unwrap();
        }
        write!(output, " + \"{unit_suffix}\";}} }} }} }},").unwrap();
        write!(
            output,
            "responsive: true, plugins: {{ legend: {{ position: 'bottom', }},"
        )
        .unwrap();
        write!(output, "}} }} }});").unwrap();
        write!(output, "</script>").unwrap();
    }

    fn get_bar_color(&self, gc_type: &str) -> String {
        let total = self.benchmark.gc_types.len();
        let mut index = 0;
        while index < total && self.benchmark.gc_types.get(index).unwrap() != gc_type {
            index += 1;
        }
        let transparency = 1.0 - (1 + index) as f64 / (1 + total) as f64;
        let mut output = String::new();
        write!(output, "rgba(0, 0, 0, {transparency})").unwrap();
        output
    }

    fn render_limit_summary(&self, output: &mut String) {
        output.push_str("<h3>Limits</h3>");
        output.push_str("<table><thead><tr><th>Scenario</th>");
        for metric in LimitMetric::all() {
            let metric_name = metric.name();
            write!(output, "<th>{metric_name}</th>").unwrap()
        }
        output.push_str("</tr></thead>");
        for limits in &self.benchmark.limits {
            let scenario_name = &limits.test_case.scenario_name;
            let gc_type = &limits.test_case.gc_type;
            write!(output, "<tr><td>{scenario_name} ({gc_type} GC)</td>").unwrap();
            for metric in LimitMetric::all() {
                let value = Limit::display_with_unit(&metric, limits.get_value(&metric));
                write!(output, "<td>{value}</td>").unwrap()
            }
            output.push_str("</tr>")
        }
        output.push_str("</table>");
    }

    fn render_limit_metric(&self, output: &mut String, metric: LimitMetric) {
        let metric_name = metric.name();
        write!(output, "<h3>{metric_name}</h3>").unwrap();
        self.render_limit_summary_chart(output, &metric);
        output.push_str("<table><thead><tr><th>Scenario</th>");
        for gc_type in &self.benchmark.gc_types {
            write!(output, "<th>{gc_type} GC</th>").unwrap();
        }
        output.push_str("</tr></thead>");
        for scenario_name in &self.benchmark.limits_scenarios {
            write!(output, "<tr><td>{scenario_name}</td>").unwrap();
            for gc_type in &self.benchmark.gc_types {
                match self.benchmark.get_limits(scenario_name, gc_type) {
                    Some(limits) => {
                        let value = Limit::display_with_unit(&metric, limits.get_value(&metric));
                        write!(output, "<td>{value}</td>").unwrap()
                    }
                    None => output.push_str("<td>--</td>"),
                }
            }
            output.push_str("</tr>");
        }
        output.push_str("<tr><tfoot><tr><td>Average</td>");
        for gc_type in &self.benchmark.gc_types {
            let values: Vec<u64> = self
                .benchmark
                .limits_scenarios
                .iter()
                .map(|scenario_name| self.benchmark.get_limits(scenario_name, gc_type))
                .filter(|option| option.is_some())
                .map(|limits| limits.unwrap().get_value(&metric))
                .collect();
            let average = Limit::display_with_unit(&metric, average_u64(values));
            write!(output, "<td>{average}</td>").unwrap();
        }
        output.push_str("</tr></tfoot>");
        output.push_str("</table>");
    }

    fn render_limit_summary_chart(&self, output: &mut String, metric: &LimitMetric) {
        let chart_id = metric.identifier().to_owned() + "Id";
        let chart_variable = metric.identifier().to_owned() + "Chart";
        let chart_data = metric.identifier().to_owned() + "Data";
        let unit_suffix = Limit::unit_suffix(metric);
        write!(
            output,
            "<div class=\"summary-chart\"><canvas id=\"{chart_id}\"></canvas></div>"
        )
        .unwrap();
        write!(
            output,
            "<script>const {chart_variable} = document.getElementById('{chart_id}');"
        )
        .unwrap();
        write!(output, "const {chart_data} = {{labels: [").unwrap();
        for scenario_name in &self.benchmark.limits_scenarios {
            write!(output, "'{scenario_name}', ").unwrap();
        }
        output.push_str("], datasets: [");
        for gc_type in &self.benchmark.gc_types {
            if gc_type != "no" || Limit::show_no_gc(metric) {
                write!(output, "{{ label: '{gc_type} GC', data: [").unwrap();
                for scenario_name in &self.benchmark.limits_scenarios {
                    let value = match self.benchmark.get_limits(scenario_name, gc_type) {
                        Some(performance) => performance.get_value(metric),
                        None => 0,
                    };
                    let display_value = Limit::display_value(metric, value);
                    write!(output, "{display_value}, ").unwrap();
                }
                let bar_color = self.get_bar_color(gc_type);
                write!(
                    output,
                    "], borderColor: 'rgb(0, 0, 0)', backgroundColor: '{bar_color}', }},"
                )
                .unwrap();
            }
        }
        write!(output, "]}};").unwrap();
        write!(
            output,
            "new Chart({chart_variable}, {{ type: 'bar', data: {chart_data}, "
        )
        .unwrap();
        write!(output, "options: {{scales: {{y: {{").unwrap();
        if Limit::logarithmic_scale(metric) {
            write!(output, "type: 'logarithmic',").unwrap();
        }
        write!(output, "beginAtZero: true,ticks: {{maxTicksLimit: 10,").unwrap();
        write!(output, "callback: function (value, index, ticks) {{return value + \"{unit_suffix}\";}} }} }} }},").unwrap();
        write!(
            output,
            "responsive: true, plugins: {{ legend: {{ position: 'bottom', }},"
        )
        .unwrap();
        write!(output, "}} }} }});").unwrap();
        write!(output, "</script>").unwrap();
    }
}
