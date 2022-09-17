use crate::chart::Chart;
use crate::chart::Series;
use crate::measurement::Measurement;
use std::fmt::Write;

pub struct ChartPage {
    name: String,
    labels: Vec<u64>,
    charts: Vec<Chart>,
}

impl ChartPage {
    pub fn new(measurement: &Measurement) -> ChartPage {
        let charts = vec![
            Chart::memory_chart(measurement),
            Chart::allocation_chart(measurement),
            Chart::runtime_chart(measurement),
        ];
        ChartPage {
            name: measurement.name.clone(),
            labels: measurement.labels.clone(),
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
            output.push_str("<h1>");
            output.push_str(name);
            output.push_str("</h1><div><canvas id=\"");
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

        let name = &self.name;
        let mut output = String::new();
        output += "<html><head><title>GC Measurement {name}</title></head><body><script src=\"https://cdn.jsdelivr.net/npm/chart.js\"></script>";
        write!(output, "<h1>{name}</h1>").unwrap();
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
