use crate::common;

#[derive(Clone)]
pub struct TestCase {
    pub file_name: String,
    pub scenario_name: String,
    pub gc_type: String,
}

const PREFIXES: [&str; 3] = ["limit-", "performance-", "dirty-pages-"];

impl TestCase {
    pub fn new(file_name: &str) -> TestCase {
        TestCase {
            file_name: String::from(file_name),
            scenario_name: String::from(Self::extract_scenario_name(file_name)),
            gc_type: String::from(Self::extract_gc_type(file_name)),
        }
    }

    fn extract_gc_type(path: &str) -> &str {
        let name = common::remove_file_extension(common::get_file_name(path));
        match common::find_last(name, '-') {
            Some(index) => &name[(index + 1)..name.len()],
            None => "",
        }
    }

    fn extract_scenario_name(path: &str) -> &str {
        let mut name = common::remove_file_extension(common::get_file_name(path));
        for prefix in PREFIXES {
            name = common::remove_prefix(name, prefix);
        }
        match common::find_last(name, '-') {
            Some(index) => &name[0..index],
            None => name,
        }
    }
}
