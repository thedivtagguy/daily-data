import * as d3 from "d3";
import * as d3Collection from 'd3-collection';

// set the dimensions and margins of the graph
const margin = { top: 10, right: 28, bottom: 60, left: 100 },
  width = 445 - margin.left - margin.right,
  height = 600 - margin.top - margin.bottom;

// append the svg object to the body of the page
const svg = d3
  .select("#chartThree")
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", `translate(${margin.left}, ${margin.top})`);



// Read data
d3.csv("data/land-use-per-kg-cleaned.csv").then(function (data) {

  // Sort data by land descending
  data.sort(function (a, b) {
    return b.land - a.land;
  });


  const gradient = svg
    .append("defs")
    .append("linearGradient")
    .attr("id", "gradient")
    .attr("x1", "0%")
    .attr("y1", "0%")
    .attr("x2", "100%")
    .attr("y2", "100%")
    .attr("spreadMethod", "pad");

  gradient
    .append("stop")
    .attr("offset", "0%")
    .attr("stop-color", "#807DBA")
    .attr("stop-opacity", 1);
    
  gradient
    .append("stop")
    .attr("offset", "100%")
    .attr("stop-color", "#3F007D")
    .attr("stop-opacity", 1);



  // Add X axis
  const x = d3.scaleLinear()
    .domain([0, 400])
    .range([ 0, width]);


  // Y axis
  const y = d3.scaleBand()
    .range([ 0, height ])
    .domain(data.map(d => d.entity))
    .padding(.1);
  svg.append("g")
    .call(d3.axisLeft(y))
    .selectAll("text")
    .attr("class", "text-gray-600 font-bold");
    
  svg.append("g")
    .attr("transform", `translate(0, ${height})`)
    .call(d3.axisBottom(x))
    .selectAll("text")
    .attr("class", "text-gray-600")
      .attr("transform", "translate(-7,10)rotate(-45)")
      .style("text-anchor", "end");
  //Bars
  svg.selectAll("myRect")
    .data(data)
    .join("rect")
    .attr("x", x(0) )
    .attr("y", d => y(d.entity))
    .attr("width", d => x(d.land))
    .attr("height", y.bandwidth())
    // Fill color gradient from white green
    .attr("fill", "url(#gradient)")

  // Add a label of land at the end of the bar
  svg.selectAll("myText")
    .data(data)
    .join("text")
    .attr("x", d => x(d.land) + 5)
    .attr("y", d => y(d.entity) + y.bandwidth() )
    .text(d => d.land + " m2")
    .attr("class", "text-gray-600")
    .attr("text-anchor", "start")
    .style("font-size", "10px");


        
});
