use crate::measurement::Measurement;

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

impl Chart {
    pub fn memory_chart(measurement: &Measurement) -> Chart {
        let series = vec![
            Series {
                name: String::from("Memory"),
                color: String::from("255, 99, 132"),
                values: measurement.memory.clone(),
            },
            Series {
                name: String::from("Heap"),
                color: String::from("54, 162, 235"),
                values: measurement.heap.clone(),
            },
            Series {
                name: String::from("Live"),
                color: String::from("255, 159, 64"),
                values: measurement.live.clone(),
            },
        ];
        Chart {
            name: String::from("Memory"),
            data_set: series,
        }
    }

    pub fn allocation_chart(measurement: &Measurement) -> Chart {
        let series = vec![
            Series {
                name: String::from("Allocated"),
                color: String::from("255, 206, 86"),
                values: measurement.allocated.clone(),
            },
            Series {
                name: String::from("Reclaimed"),
                color: String::from("153, 102, 255"),
                values: measurement.reclaimed.clone(),
            },
        ];
        Chart {
            name: String::from("Allocations"),
            data_set: series,
        }
    }

    pub fn runtime_chart(measurement: &Measurement) -> Chart {
        let series = vec![
            Series {
                name: String::from("Mutator"),
                color: String::from("75, 192, 192"),
                values: measurement.mutator.clone(),
            },
            Series {
                name: String::from("Collector"),
                color: String::from("255, 99, 132"),
                values: measurement.collector.clone(),
            },
        ];
        Chart {
            name: String::from("Runtime"),
            data_set: series,
        }
    }
}
