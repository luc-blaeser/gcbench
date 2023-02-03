import { recorder } from "../../src/declarations/recorder";

const labels = [];
const memoryData = {
  labels: labels,
  datasets: [
    {
      label: 'Memory',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(255, 99, 132, 0.1)',
      borderColor: 'rgb(255, 99, 132)',
      data: []
    },
    {
      label: 'Heap',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(54, 162, 255, 0.1)',
      borderColor: 'rgb(54, 162, 235)',
      fill: true,
      data: []
    },
    {
      label: 'Live',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(255, 159, 64, 0.1)',
      borderColor: 'rgb(255, 159, 64)',
      data: []
    },
  ]
};
const memoryConfig = {
  type: 'line',
  data: memoryData,
  options: {
    scales: {
      yAxis: {
        suggestedMin: 0,
        suggestedMax: 200 * 1024 * 1024
      },
    }
  }
};
const memoryChart = new Chart(document.getElementById('memoryChart'), memoryConfig);

const allocationData = {
  labels: labels,
  datasets: [
    {
      label: 'Allocated',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(255, 206, 86, 0.1)',
      borderColor: 'rgb(255, 206, 86)',
      data: []
    },
    {
      label: 'Reclaimed',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(153, 102, 255, 0.1)',
      borderColor: 'rgb(153, 102, 255)',
      fill: true,
      data: []
    },
  ]
};
const allocationConfig = {
  type: 'line',
  data: allocationData,
  options: {
    scales: {
      yAxis: {
        suggestedMin: 0,
        suggestedMax: 200 * 1024 * 1024
      },
    }
  }
};
const allocationChart = new Chart(document.getElementById('allocationChart'), allocationConfig);

const runtimeData = {
  labels: labels,
  datasets: [
    {
      label: 'Mutator',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(75, 192, 192, 0.1)',
      borderColor: 'rgb(75, 192, 192)',
      data: []
    },
    {
      label: 'Collector',
      yAxisID: 'yAxis',
      backgroundColor: 'rgba(255, 99, 132, 0.1)',
      borderColor: 'rgb(255, 99, 132)',
      data: []
    }
  ]
};
const runtimeConfig = {
  type: 'line',
  data: runtimeData,
  options: {
    scales: {
      yAxis: {
        suggestedMin: 0,
        suggestedMax: 1000_000_000
      },
    }
  }
};
const runtimeChart = new Chart(document.getElementById('runtimeChart'), runtimeConfig);

const FrameSize = 50;

var buffer = [];
var position = 0;
var pending = false;

function addLabel(series, label) {
  series.splice(position, series.length - position);
  series.push(label);
  while (series.length < FrameSize) {
    series.push('-');
  }
}

function shiftSeries(series) {
  if (series.length > FrameSize) {
    series.splice(0, series.length - FrameSize);
  }
}

function shiftChart(chart) {
  shiftSeries(chart.data.labels);
  for (let index = 0; index < chart.data.datasets.length; index++) {
    shiftSeries(chart.data.datasets[index].data);
  }
}

function addData(chart, label, values) {
  shiftChart(chart);
  addLabel(chart.data.labels, label);
  for (let index = 0; index < values.length; index++) {
    let value = Number(values[index]);
    chart.data.datasets[index].data.push(value);
  }
  chart.update('none');
}

async function downloadData() {
  if (!pending) {
    pending = true;
    recorder.state().then(value => {
      buffer = value;
      console.log("Downloaded " + buffer.length);
    });
    pending = false;
  }
}

function updateChart() {
  downloadData();
  if (position < buffer.length) {
    const statistics = buffer[position];
    addData(memoryChart, position, [statistics.memorySize, statistics.heapSize, statistics.maxLiveSize]);
    addData(allocationChart, position, [statistics.allocated, statistics.reclaimed]);
    addData(runtimeChart, position, [statistics.mutatorInstructions, statistics.collectorInstructions]);
    position++;
  }
}

setInterval(updateChart, 250);
setInterval(downloadData, 2500);


