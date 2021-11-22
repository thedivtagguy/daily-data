import * as d3 from "d3";

const margin = { top: 20, right: 20, bottom: 20, left: 20 };    
const width = 960 - margin.left - margin.right;
const height = 1000 - margin.top - margin.bottom;

const map = d3.select("#map")
    .append("div")
    .attr("class", "map flex flex-wrap")
    .style("width", width + "px")
    .style("height", height + "px");

const size = 4;



d3.csv("data/pi.csv").then(function(data) {

  // Create divs for each digit and set the background color to the color and the text to the digit
    const digits = map.selectAll(".digit")
        .data(data)
        .enter()
        .append("div")
        .attr("class", "digit")
        .style("background-color", function(d) { return d.color; })
        .text(function(d) { return d.digit; })
        .style("width", size + "px")
        .style("color", "transparent")
        .style("height", size + "px")
        .style("font-size", "2px");



    digits.style("left", function(d) { return x(d.x) + "px"; })
        .style("top", function(d) { return y(d.y) + "px"; });

    
});