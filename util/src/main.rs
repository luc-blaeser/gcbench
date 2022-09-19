use crate::chart_page::ChartPage;
use crate::limit::Limit;
use crate::measurement::Measurement;
use crate::summary_page::SummaryPage;
use std::env;
use std::fs;
use std::path::Path;
use std::process;

pub mod chart;
pub mod chart_page;
pub mod limit;
pub mod measurement;
pub mod summary_page;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: report <mode> <args>\n\tmode = (chart|summary)");
        process::exit(1);
    }
    let mode = &args[1];
    if mode == "chart" {
        if args.len() < 4 {
            println!("Usage: report chart <csv_input_file> <html_output_file>");
            process::exit(1);
        }
        let input_file = &args[2];
        let output_file = &args[3];
        generate_chart(input_file, output_file);
    } else if mode == "summary" {
        if args.len() < 3 {
            println!("Usage: report summary <directory>");
            process::exit(1);
        }
        let directory = &args[2];
        generate_summary(directory);
    } else {
        println!("Available modes: \"chart\" or \"summary\"");
        process::exit(1);
    }
}

fn generate_chart(input_file: &str, output_file: &str) {
    let measurement = read_measurement(input_file);
    let page = ChartPage::new(&measurement);
    let output = page.render();
    fs::write(output_file, output).expect("cannot write output file");
}

fn generate_summary(directory: &str) {
    let measurement_files = collect_csv_files(directory, "measurement-");
    let measurements: Vec<Measurement> = measurement_files
        .iter()
        .map(|f| read_measurement(f))
        .collect();
    let limit_files = collect_csv_files(directory, "limit-");
    let limits: Vec<Limit> = limit_files.iter().map(|f| read_limit(f)).collect();
    let page = SummaryPage::new(measurements, limits);
    let output = page.render();
    let summary_file = Path::new(directory).join("summary.html");
    fs::write(summary_file, output).expect("cannot write summary file");
}

fn collect_csv_files(directory: &str, prefix: &str) -> Vec<String> {
    let suffix = ".csv";
    let mut csv_files: Vec<String> = fs::read_dir(directory)
        .expect("invalid directory")
        .map(|f| f.unwrap().path().display().to_string())
        .filter(|n| get_file_name(n).starts_with(&prefix) && n.ends_with(&suffix))
        .collect();
    csv_files.sort();
    csv_files
}

fn get_file_name(path: &str) -> &str {
    Path::new(path).file_name().unwrap().to_str().unwrap()
}

fn read_measurement(input_file: &str) -> Measurement {
    let content = fs::read_to_string(input_file).expect("invalid input file");
    let name = get_file_name(input_file);
    Measurement::parse(name, &content)
}

fn read_limit(input_file: &str) -> Limit {
    let content = fs::read_to_string(input_file).expect("invalid input file");
    let name = get_file_name(input_file);
    Limit::parse(name, &content)
}
