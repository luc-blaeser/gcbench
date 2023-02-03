import { recorder } from "../../src/declarations/recorder";

const labels = ['0'];
const memoryData = { 
  labels: labels, 
  datasets: [
    { 
      label: 'Heap', 
      backgroundColor: 'rgb(54, 162, 235)', 
      borderColor: 'rgb(54, 162, 235)', 
      data: ['0'] 
    }
  ] 
}; 
const memoryConfig = { 
  type: 'line', 
  data: memoryData, 
  options: {} 
}; 
const memoryChart = new Chart(document.getElementById('memoryChart'), memoryConfig);

function addData(chart, label, data) {
  chart.data.labels.push(label);
  chart.data.datasets.forEach((dataset) => {
      dataset.data.push(data);
  });
  chart.update();
}

var index = 0;
var pending = false;

async function tick() {
  if (!pending) {
    pending = true;
    const result = await recorder.get(index);
    if (result.length > 0) {
      const statistics = result[0];
      let heapSize = Number(statistics.heapSize);
      addData(memoryChart, index, heapSize);
      index++;
    }
    pending = false;
  }
}

document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  setInterval(tick, 1000);
  return false;
});


