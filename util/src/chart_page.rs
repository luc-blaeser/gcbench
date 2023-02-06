use crate::chart::Chart;
use crate::chart::Series;
use crate::performance::Performance;
use crate::test_case::TestCase;
use std::fmt::Write;

pub struct ChartPage {
    test_case: TestCase,
    charts: Vec<Chart>,
}

impl Chart {
    fn get_identifier(&self) -> String {
        self.name.to_lowercase() // TODO: check that identifier is valid
    }
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
            charts,
        }
    }

    pub fn render(&self) -> String {
        fn suggested_max(data_set: &[Series]) -> u64 {
            data_set
                .iter()
                .map(|series| series.suggested_max())
                .max()
                .unwrap()
        }

        fn append_chart(output: &mut String, chart: &Chart) {
            let identifier = &chart.get_identifier();
            output.push_str("<div style=\"float: left; width: 1500px;\"><h1>");
            output.push_str(&chart.name);
            output.push_str("</h1><canvas id=\"");
            output.push_str(identifier);
            output.push_str("Chart\"></canvas></div><script>const ");
            output.push_str(identifier);
            output.push_str("Data = {labels: [], datasets: [");
            for series in &chart.data_set {
                append_series(output, &series.name, &series.color);
            }
            output.push_str("] }; const ");
            output.push_str(identifier);
            output.push_str("Config = {type: 'line', data: ");
            output.push_str(identifier);
            output.push_str("Data, options: { scales: { yAxis: { suggestedMin: 0, suggestedMax: ");
            write!(output, "{}", suggested_max(&chart.data_set)).unwrap();
            output.push_str(" }  }  } }; const ");
            output.push_str(identifier);
            output.push_str("Chart = new Chart(document.getElementById('");
            output.push_str(identifier);
            output.push_str("Chart'), ");
            output.push_str(identifier);
            output.push_str("Config);");
            output.push_str("const ");
            output.push_str(identifier);
            output.push_str("Values = [");
            append_values(output, &chart.data_set);
            output.push_str("];");
            output.push_str("</script>");
        }

        fn append_values(output: &mut String, data_set: &[Series]) {
            let length = data_set.iter().map(|series| series.length()).max().unwrap();
            for index in 0..length {
                output.push('[');
                for series in data_set.iter() {
                    let value = if index < series.length() {
                        series.values[index]
                    } else {
                        0
                    };
                    write!(output, "{value}, ").unwrap();
                }
                output.push_str("], ");
            }
        }

        fn append_series(output: &mut String, name: &str, color: &str) {
            output.push_str("{ label: '");
            output.push_str(name);
            output.push_str("', yAxisID: 'yAxis', backgroundColor: 'rgb(");
            output.push_str(color);
            output.push_str(")', borderColor: 'rgb(");
            output.push_str(color);
            output.push_str(")', data: [], }, ");
        }

        let name = &self.test_case.scenario_name;
        let gc_type = &self.test_case.gc_type;
        let mut output = String::new();
        write!(
            output,
            "<!DOCTYPE html><html><head><title>GC Performance {name} ({gc_type} GC)</title><link rel=\"stylesheet\" href=\"style.css\"/></head>"
        )
        .unwrap();
        output += "<body><script src=\"https://cdn.jsdelivr.net/npm/chart.js\"></script><script src=\"display.js\"></script>";
        write!(output, "<h1>{name} ({gc_type} GC)</h1>").unwrap();
        output += "<div id=\"menu\">";
        output +=
            "<form id=\"animation\" action=\"#\"><button type=\"submit\">Animate</button></form>";
        output +=
            "<form id=\"overview\" action=\"#\"><button type=\"submit\">Overview</button></form>";
        output += "</div>";
        output += "<script>";
        output += "function updateChart() {";
        for chart in &self.charts {
            let identifier = &chart.get_identifier();
            let length = chart
                .data_set
                .iter()
                .map(|series| series.length())
                .max()
                .unwrap();
            write!(output, "if (position < {length})").unwrap();
            output += "{";
            write!(
                output,
                "addData({}Chart, position, {}Values[position]);",
                identifier, identifier
            )
            .unwrap();
            output += "}";
        }
        output += "position++; }";

        output += "</script>";
        for chart in &self.charts {
            append_chart(&mut output, chart);
        }
        output += "<script>";
        output += "function clearAll() { ";
        output += "clearTimer();";
        for chart in &self.charts {
            let identifier = &chart.get_identifier();
            write!(output, "clearChart({}Chart);", identifier).unwrap();
        }
        output += "}";
        output += "function showOverview() { clearAll(); ";
        for chart in &self.charts {
            let identifier = &chart.get_identifier();
            write!(
                output,
                "showFullChart({}Chart, {}Values);",
                identifier, identifier
            )
            .unwrap();
        }
        output += "}";
        output += "showOverview(); ";
        output += "document.getElementById(\"animation\").addEventListener(\"submit\", async (e) => { showAnimation(); return false; });";
        output += "document.getElementById(\"overview\").addEventListener(\"submit\", async (e) => { showOverview(); return false; });";
        output += "</script>";
        output += "</body></html>";
        output
    }
}
