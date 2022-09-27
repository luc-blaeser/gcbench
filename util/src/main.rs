use benchmark::Benchmark;

use crate::chart_page::ChartPage;
use crate::limit::Limit;
use crate::performance::Performance;
use crate::summary_page::SummaryPage;
use std::env;
use std::fs;
use std::path::Path;
use std::process;

pub mod benchmark;
pub mod chart;
pub mod chart_page;
pub mod common;
pub mod limit;
pub mod performance;
pub mod summary_page;
pub mod test_case;

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
    let performance = read_performance(input_file);
    let page = ChartPage::new(&performance);
    let output = page.render();
    fs::write(output_file, output).expect("cannot write output file");
}

fn generate_summary(directory: &str) {
    let performance_files = common::collect_csv_files(directory, "measurement-");
    let performance: Vec<Performance> = performance_files
        .iter()
        .map(|f| read_performance(f))
        .collect();
    let limit_files = common::collect_csv_files(directory, "limit-");
    let limits: Vec<Limit> = limit_files.iter().map(|f| read_limit(f)).collect();
    let benchmark = Benchmark::new(performance, limits);
    let page = SummaryPage::new(benchmark);
    let output = page.render();
    let summary_file = Path::new(directory).join("summary.html");
    fs::write(summary_file, output).expect("cannot write summary file");
}

fn read_performance(input_file: &str) -> Performance {
    let content = fs::read_to_string(input_file).expect("invalid input file");
    let name = common::get_file_name(input_file);
    Performance::parse(name, &content)
}

fn read_limit(input_file: &str) -> Limit {
    let content = fs::read_to_string(input_file).expect("invalid input file");
    let name = common::get_file_name(input_file);
    Limit::parse(name, &content)
}
