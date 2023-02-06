use crate::performance::Performance;

#[derive(Clone)]
pub struct Chart {
    pub name: String,
    pub data_set: Vec<Series>,
}

#[derive(Clone)]
pub struct Series {
    pub name: String,
    pub color: String,
    pub values: Vec<u64>,
}

impl Series {
    pub fn length(&self) -> usize {
        self.values.len()
    }

    pub fn suggested_max(&self) -> u64 {
        *(self.values.iter().max().unwrap_or(&0u64))
    }
}

impl Chart {
    pub fn memory_chart(performance: &Performance) -> Chart {
        let series = vec![
            Series {
                name: String::from("Memory"),
                color: String::from("255, 99, 132"),
                values: performance.memory.clone(),
            },
            Series {
                name: String::from("Heap"),
                color: String::from("54, 162, 235"),
                values: performance.heap.clone(),
            },
            Series {
                name: String::from("Live"),
                color: String::from("255, 159, 64"),
                values: performance.live.clone(),
            },
        ];
        Chart {
            name: String::from("Memory"),
            data_set: series,
        }
    }

    pub fn allocation_chart(performance: &Performance) -> Chart {
        let series = vec![
            Series {
                name: String::from("Allocated"),
                color: String::from("255, 206, 86"),
                values: performance.allocated.clone(),
            },
            Series {
                name: String::from("Reclaimed"),
                color: String::from("153, 102, 255"),
                values: performance.reclaimed.clone(),
            },
        ];
        Chart {
            name: String::from("Allocations"),
            data_set: series,
        }
    }

    pub fn runtime_chart(performance: &Performance) -> Chart {
        let series = vec![
            Series {
                name: String::from("Mutator"),
                color: String::from("75, 192, 192"),
                values: performance.mutator.clone(),
            },
            Series {
                name: String::from("Collector"),
                color: String::from("255, 99, 132"),
                values: performance.collector.clone(),
            },
        ];
        Chart {
            name: String::from("Runtime"),
            data_set: series,
        }
    }
}
