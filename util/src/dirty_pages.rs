use crate::test_case::TestCase;
use std::fmt::Write;

#[derive(Clone)]
pub struct DirtyPages {
    pub test_case: TestCase,
    pub costs: Vec<u64>,
}

impl DirtyPages {
    fn new(file_name: &str) -> DirtyPages {
        DirtyPages {
            test_case: TestCase::new(file_name),
            costs: Vec::new(),
        }
    }

    pub fn parse(file_name: &str, content: &str) -> DirtyPages {
        let mut dirty_pages = DirtyPages::new(file_name);
        for line in content.split('\n').filter(|x| !x.is_empty()) {
            let parsed_value = line.trim().parse::<u64>();
            if let Ok(number) = parsed_value {
                dirty_pages.costs.push(number);
            }
        }
        dirty_pages
    }

    pub fn total_costs(&self) -> u64 {
        self.costs.iter().sum()
    }

    pub fn display_with_unit(value: u64) -> String {
        let mut result = String::new();
        write!(&mut result, "{value:.2e}").unwrap();
        result
    }
}
