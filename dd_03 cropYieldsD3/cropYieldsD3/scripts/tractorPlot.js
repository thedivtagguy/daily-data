import * as d3 from "d3";
const margin = {
  top: 20,
  right: 20,
  bottom: 30,
  left: 150,
};
const width = 960 - margin.left - margin.right;
const height = 2500 - margin.top - margin.bottom;

let chart = d3
  .select("#chart2")
  .append("div")
  .classed("chart", true)
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Make sure to create a separate SVG for the XAxis
let axis = d3
  .select("#chart2")
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", 40)
  .append("g")
  .attr("transform", "translate(" + margin.left + ", 0)");

// Load the data
d3.csv("data/land_use.csv").then(function (data) {
  // console.log(data);
  const years = Array.from(new Set(data.map((d) => d.year)));
  const countries = Array.from(new Set(data.map((d) => d.entity)));
  countries.reverse();
  const x = d3.scaleBand().range([0, width]).domain(years).padding(0.01);

  const y = d3
    .scaleBand()
    .range([height, 0])
    .domain(countries)
    .padding(0.01);

  // Only 10 years
  axis
    .call(d3.axisBottom(x).tickValues(years.filter((d, i) => !(i % 10))))
    .selectAll("text")
    .style("color", "black")
    .style("position", "fixed")
    .attr("transform", "translate(-10,10)rotate(-45)")
    .style("text-anchor", "end");

  chart
    .append("g")
    .call(d3.axisLeft(y))
    .selectAll("text")
    .style("color", "black")
    .attr("transform", "translate(-10,0)")
    .style("text-anchor", "end");

  const colorScale = d3
    .scaleSequential()
    .domain([0, d3.max(data, (d) => d.change)])
    .interpolator(d3.interpolateInferno);

  // add the squares
  chart
    .selectAll()
    .data(data, function (d) {
      return d.year + ":" + d.entity;
    })
    .join("rect")
    .attr("x", function (d) {
      return x(d.year);
    })
    .attr("y", function (d) {
      return y(d.entity);
    })
    .attr("width", x.bandwidth())
    .attr("height", y.bandwidth())
    .style("fill", function (d) {
      return colorScale(d.change);
      console.log(d.change);
    })
    .style("stroke-width", 4)
    .style("stroke", "none")
    .style("opacity", 0.8);
});
