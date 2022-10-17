use std::fs;
use std::path::Path;

pub fn collect_csv_files(directory: &str, prefix: &str) -> Vec<String> {
    let suffix = ".csv";
    let mut csv_files: Vec<String> = fs::read_dir(directory)
        .expect("invalid directory")
        .map(|f| f.unwrap().path().display().to_string())
        .filter(|n| get_file_name(n).starts_with(&prefix) && n.ends_with(&suffix))
        .collect();
    csv_files.sort();
    csv_files
}

pub fn remove_prefix<'a>(name: &'a str, prefix: &str) -> &'a str {
    if name.starts_with(prefix) {
        &name[prefix.len()..name.len()]
    } else {
        name
    }
}

pub fn find_last(text: &str, pattern: char) -> Option<usize> {
    let mut result = None;
    let mut text = text;
    loop {
        match text.find(pattern) {
            Some(index) => {
                result = match result {
                    Some(last) => Some(last + index + 1),
                    None => Some(index),
                };
                text = &text[(index + 1)..text.len()];
            }
            None => {
                return result;
            }
        }
    }
}

pub fn remove_file_extension(file_name: &str) -> &str {
    if let Some(index) = file_name.find('.') {
        &file_name[0..index]
    } else {
        file_name
    }
}

pub fn get_file_name(path: &str) -> &str {
    Path::new(path).file_name().unwrap().to_str().unwrap()
}

pub fn to_mb(value: u64) -> u64 {
    const MB: u64 = 1024 * 1024;
    (value + MB - 1) / MB
}

pub fn average_f64(iterator: Vec<f64>) -> f64 {
    let mut sum = 0.;
    let mut count = 0;
    for value in iterator {
        sum += value;
        count += 1
    }
    sum / count as f64
}

pub fn average_u64(iterator: Vec<u64>) -> u64 {
    let mut sum = 0;
    let mut count = 0;
    for value in iterator {
        sum += value;
        count += 1
    }
    sum / count as u64
}
