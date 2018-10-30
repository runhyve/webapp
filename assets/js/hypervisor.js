import {GoogleCharts} from 'google-charts'

GoogleCharts.load(drawCharts);

function drawCharts() {
  var netdata = hypervisor.metrics_endpoint + '/api/v1/data?after=-60&format=datasource&options=nonzero&chart=';

  var charts = [
    {
      chart: 'system.cpu',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'Total CPU utilization ',
        isStacked: 'absolute'
      }
    },
    {
      chart: 'system.io',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'Disk I/O ',
      }
    },
    {
      chart: 'system.load',
      type: 'line',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'System Load Average',
      }
    },
    {
      chart: 'system.ctxt',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'CPU Context Switches',
      }
    },
    {
      chart: 'system.intr',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'System interrupts',
      }
    },
    {
      chart: 'system.soft_intr',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'Software Interrupts',
      }
    },
    {
      chart: 'system.ram',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'System RAM',
        isStacked: 'absolute'
      }
    },
    {
      chart: 'system.swap',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'System Swap',
        isStacked: 'absolute'
      }
    },
    {
      chart: 'system.swapio',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'Total Swap I/O',
      }
    },
    {
      chart: 'mem.pgfaults',
      type: 'area',
      containerClass: ['column', 'is-half'],
      options: {
        title: 'Page fault',
      }
    },
    {
      chart: 'system.ipv4',
      type: 'area',
      containerClass: ['column', 'is-12'],
      options: {
        title: 'Total IPv4 Traffic.',
      }
    },
  ];

  const container = document.getElementById("charts").children[0];
  charts.forEach(function (chart, i) {
    var chartDiv = document.createElement("div");
    chart.containerClass.push('chart_' + chart.chart);
    chart.containerClass.map(item => chartDiv.classList.add(item));

    container.appendChild(chartDiv);

    charts[i].query = new GoogleCharts.api.visualization.Query(netdata + chart.chart, {sendMethod: 'auto'});

    switch(chart.type) {
      case 'area':
        chart.gchart = new GoogleCharts.api.visualization.AreaChart(chartDiv);
        break;

      default:
        chart.gchart = new GoogleCharts.api.visualization.LineChart(chartDiv);
        break;
    }
  });

  function refreshChart(chart) {
    chart.query.send(function(data) {
      chart.gchart.draw(data.getDataTable(), chart.options);
    });
  }

  setInterval(function() {
    charts.forEach(function (chart) {
      refreshChart(chart);
    });
  }, 1000);
}