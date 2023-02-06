use crate::chart::Chart;
use crate::chart::Series;
use crate::performance::Performance;
use crate::test_case::TestCase;
use std::fmt::Write;

pub struct ChartPage {
    test_case: TestCase,
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

        fn get_identifier(name: &str) -> String {
            name.to_lowercase() // TODO: check that identifier is valid
        }

        fn append_chart(output: &mut String, name: &str, data_set: &[Series]) {
            let identifier = &get_identifier(name);
            output.push_str("<div style=\"float: left; width: 1500px;\"><h1>");
            output.push_str(name);
            output.push_str("</h1><canvas id=\"");
            output.push_str(identifier);
            output.push_str("Chart\"></canvas></div><script>const ");
            output.push_str(identifier);
            output.push_str("Data = {labels: [], datasets: [");
            for series in data_set {
                append_series(output, &series.name, &series.color);
            }
            output.push_str("] }; const ");
            output.push_str(identifier);
            output.push_str("Config = {type: 'line', data: ");
            output.push_str(identifier);
            output.push_str("Data, options: { scales: { yAxis: { suggestedMin: 0, suggestedMax: ");
            write!(output, "{}", suggested_max(data_set)).unwrap();
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
            append_values(output, data_set);
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
        output += "<body><script src=\"https://cdn.jsdelivr.net/npm/chart.js\"></script>";
        write!(output, "<h1>{name} ({gc_type} GC)</h1>").unwrap();
        output += "<form action=\"#\"><button type=\"submit\">Animate</button></form>";
        output += "<script>";
        output += "var position = 0; const FrameSize = 50; var timer = null;";
        output += "function addLabel(series, label) { series.splice(position, series.length - position); series.push(label); while (series.length < FrameSize) { series.push('-'); }}";
        output += "function shiftSeries(series) { if (series.length > FrameSize) { series.splice(0, series.length - FrameSize); } }";
        output += "function shiftChart(chart) { shiftSeries(chart.data.labels); for (let index = 0; index < chart.data.datasets.length; index++) { shiftSeries(chart.data.datasets[index].data); } }";
        output += "function addData(chart, label, values) { shiftChart(chart); addLabel(chart.data.labels, label); for (let index = 0; index < values.length; index++) { let value = Number(values[index]); chart.data.datasets[index].data.push(value); } chart.update('none'); }";
        output += "function updateChart() {";
        for chart in &self.charts {
            let identifier = &get_identifier(&chart.name);
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
            append_chart(&mut output, &chart.name, &chart.data_set);
        }
        output += "<script>";
        output += "function clearSeries(series) { series.splice(0, series.length); }";
        output += "function clearChart(chart) { clearSeries(chart.data.labels); for (let index = 0; index < chart.data.datasets.length; index++) { clearSeries(chart.data.datasets[index].data); } }";
        output += "function clearAll() { ";
        output += "if (timer != null) { clearInterval(timer); timer = null; position = 0; } ";
        for chart in &self.charts {
            let identifier = &get_identifier(&chart.name);
            write!(output, "clearChart({}Chart);", identifier).unwrap();
        }
        output += "}";
        output += "function showFullChart(chart, values) { for (let step = 0; step < values.length; step++) { chart.data.labels.push(step); for (let index = 0; index < chart.data.datasets.length; index++) { chart.data.datasets[index].data.push(values[step][index]); } } chart.update('none'); chart.update(); }";
        output += "function staticDisplay() { clearAll(); ";
        for chart in &self.charts {
            let identifier = &get_identifier(&chart.name);
            write!(
                output,
                "showFullChart({}Chart, {}Values);",
                identifier, identifier
            )
            .unwrap();
        }
        output += "}";
        output +=
            "function dynamicDisplay() { clearAll(); timer = setInterval(updateChart, 250); }";
        output += "staticDisplay(); ";
        output += "document.querySelector(\"form\").addEventListener(\"submit\", async (e) => { const button = e.target.querySelector(\"button\"); if (timer == null) { button.innerText = \"Overview\"; dynamicDisplay(); } else { button.innerText = \"Animtate\"; staticDisplay(); } return false; });";
        output += "</script>";
        output += "</body></html>";
        output
    }
}
