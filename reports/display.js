const FrameSize = 50;

var position = 0;
var timer = null;

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

function clearSeries(series) {
    series.splice(0, series.length);
}

function clearChart(chart) {
    clearSeries(chart.data.labels);
    for (let index = 0; index < chart.data.datasets.length; index++) {
        clearSeries(chart.data.datasets[index].data);
    }
}

function clearTimer() {
    if (timer != null) { 
        clearInterval(timer); 
        timer = null; 
        position = 0; 
    }
}

function showFullChart(chart, values) { 
    for (let step = 0; step < values.length; step++) { 
        chart.data.labels.push(step); 
        for (let index = 0; index < chart.data.datasets.length; index++) { 
            chart.data.datasets[index].data.push(values[step][index]);
        } 
    } 
    chart.update('none'); 
    chart.update();
}

function showAnimation() { 
    clearAll(); 
    timer = setInterval(updateChart, 250); 
}
