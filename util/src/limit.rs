#[derive(Clone)]
pub struct Limit {
    pub name: String,
    pub allocations: u64,
    pub heap: u64,
}

impl Limit {
    pub fn parse(name: &str, content: &str) -> Limit {
        fn pick(row: &[u64], index: usize) -> u64 {
            *row.get(index).unwrap()
        }
        let line = content
            .split('\n')
            .skip(1)
            .filter(|x| !x.is_empty())
            .last()
            .unwrap_or("0, 0");
        let row: Vec<u64> = line
            .split(',')
            .map(|x| x.trim().parse::<u64>().expect("invalid number"))
            .collect();
        let allocations = pick(&row, 0);
        let heap = pick(&row, 1);
        Limit {
            name: String::from(name),
            allocations,
            heap,
        }
    }
}
