use crate::chart::Chart;
use crate::chart::Series;
use crate::performance::Performance;
use crate::test_case::TestCase;
use std::fmt::Write;

pub struct ChartPage {
    test_case: TestCase,
    labels: Vec<u64>,
    charts: Vec<Chart>,
}

impl ChartPage {
    pub fn new(performance: &Performance) -> ChartPage {
        let charts = vec![
            Chart::memory_chart(performance),
            Chart::allocation_chart(performance),
            Chart::runtime_chart(performance),
        ];
        ChartPage {
            test_case: performance.test_case.clone(),
            labels: performance.labels.clone(),
            charts,
        }
    }

    pub fn render(&self) -> String {
        fn append_numbers(output: &mut String, numbers: &Vec<u64>) {
            for value in numbers {
                write!(output, "'{value}', ").unwrap();
            }
        }

        fn append_chart(output: &mut String, name: &str, data_set: &[Series]) {
            let identifier = &name.to_lowercase(); // TODO: check that identifier is valid
            output.push_str("<div style=\"float: left; width: 1500px;\"><h1>");
            output.push_str(name);
            output.push_str("</h1><canvas id=\"");
            output.push_str(identifier);
            output.push_str("Chart\"></canvas></div><script>const ");
            output.push_str(identifier);
            output.push_str("Data = {labels: labels, datasets: [");
            for series in data_set {
                append_series(output, &series.name, &series.color, &series.values);
            }
            output.push_str("] }; const ");
            output.push_str(identifier);
            output.push_str("Config = {type: 'line', data: ");
            output.push_str(identifier);
            output.push_str("Data, options: {} }; const ");
            output.push_str(identifier);
            output.push_str("Chart = new Chart(document.getElementById('");
            output.push_str(identifier);
            output.push_str("Chart'), ");
            output.push_str(identifier);
            output.push_str("Config);</script>");
        }

        fn append_series(output: &mut String, name: &str, color: &str, series: &Vec<u64>) {
            output.push_str("{ label: '");
            output.push_str(name);
            output.push_str("', backgroundColor: 'rgb(");
            output.push_str(color);
            output.push_str(")', borderColor: 'rgb(");
            output.push_str(color);
            output.push_str(")', data: [");
            append_numbers(output, series);
            output.push_str("], }, ");
        }

        let name = &self.test_case.scenario_name;
        let gc_type = &self.test_case.gc_type;
        let mut output = String::new();
        write!(
            output,
            "<!DOCTYPE html><html><head><title>GC Performance {name} ({gc_type} GC)</title><link rel=\"stylesheet\" href=\"style.css\"/></head>"
        )
        .unwrap();
        output += "<body><script src=\"https://cdn.jsdelivr.net/npm/chart.js\"></script>";
        write!(output, "<h1>{name} ({gc_type} GC)</h1>").unwrap();
        output += "<script>const labels = [";
        append_numbers(&mut output, &self.labels);
        output += "]</script>";
        for chart in &self.charts {
            append_chart(&mut output, &chart.name, &chart.data_set);
        }
        output += "</body></html>";
        output
    }
}
