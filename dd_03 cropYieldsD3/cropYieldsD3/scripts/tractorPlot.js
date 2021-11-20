import * as d3 from "d3";
import legendColor from '../../cropYieldsD3/node_modules/d3-svg-legend'

const margin = {
  top: 20,
  right: 50,
  bottom: 30,
  left: 160,
};
const width = 960 - margin.left - margin.right;
const height = 2500 - margin.top - margin.bottom;

let chart = d3
  .select("#chart2")
  .append("div")
  // Set id to chartArea
  .attr("id", "chartArea")
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

  // Read in data and various groups
  const years = Array.from(new Set(data.map((d) => d.year)));
  const countries = Array.from(new Set(data.map((d) => d.entity)));
  countries.reverse();
  const x = d3.scaleBand().range([0, width]).domain(years).padding(0.01);

  // Create a tooltip
  let tooltip = d3
    .select("#chart2")
    .append("div")
    .style("opacity", 0)
    .attr("class", "tooltip")
    .style("background-color", "white")
    .style("border", "solid")
    .style("color", "black")
    .attr("class", "text-left")
    .style("border-width", "2px")
    .style("border-radius", "5px")
    .style("padding", "5px");

 // Functions for tooltips
  const mouseover = function (event, d) {
    tooltip.style("opacity", 1);
    d3.select(this)
      .style("stroke", "black")
      .style("stroke-width", "0.3px")
      .style("opacity", 1);
  };
  const mousemove = function (event, d) {
    let html =
      `<div class='row'>
    
    <div class='col-md-12'>
        <b>Country: </b>` +
      d.entity +
      `
   </div>
    <div class='col-md-12'>
        <b>Year: </b>` +
      d.year +
      `
    </div>
    <div class='col-md-12'>
        <b>Change in land use since previous year: </b>` +
      d.cumChange +
      `
    </div>`;
    console.log(event.x, event.y);
    console.log("Modified:",  0.8*event.x, 0.8*event.y);
    tooltip
      .html(html)
      .style("left", 0.8*event.x  + "px")
      .style("top", 0.8*(event.y) + "px")
      .style("position", "absolute");
  };


  const mouseleave = function (event, d) {
    tooltip.style("opacity", 0);
    d3.select(this).style("stroke", "none").style("opacity", 0.8);
  };


  // Y scale
  const y = d3.scaleBand().range([height, 0]).domain(countries).padding(0.01);


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
    .style("opacity", 0.8)
    .on("mouseover", mouseover)
    .on("mousemove", mousemove)
    .on("mouseleave", mouseleave);




    
});
