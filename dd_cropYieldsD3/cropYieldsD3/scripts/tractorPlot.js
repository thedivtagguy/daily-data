import * as d3 from "d3";

// Initialize the plot


const margin = { top: 20, right: 20, bottom: 30, left: 150 };
const width = 960 - margin.left - margin.right;
const height = 500 - margin.top - margin.bottom;


let chart = d3.select("#chart2")
    .append("svg")
    .attr("width", 960)
    .attr("height", 2500)
    .append("g")
    .style("overflow-y", "scroll")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    let xaxis = d3.select("#chart2")
    .append("div")
    .attr("width", 960)
    .attr("height", 50)
    .append("g");


// Load the data
d3.csv("https://raw.githubusercontent.com/thedivtagguy/daily-data/master/dd_cropYieldsD3/cropYieldsD3/data/land_use.csv").then(function(data) {
    // console.log(data);
    const years = Array.from(new Set(data.map(d => d.year)));
    const countries = Array.from(new Set(data.map(d => d.entity)));

    // Sort countries based on change in land use in descending order
    const sortedCountries = countries.sort((a, b) => {
        const aChange = data.filter(d => d.entity === a).map(d => d.change).reduce((a, b) => a + b);
        const bChange = data.filter(d => d.entity === b).map(d => d.change).reduce((a, b) => a + b);
        return aChange - bChange;
    });



    const x = d3.scaleBand()
        .range([0, width])
        .domain(years);
    
    const y = d3.scaleBand()
        .range([height*6, 0])
        .domain(sortedCountries);

    
    xaxis
    .append("svg")
    .append("g")
        .attr("transform", "translate(0," + height + ")")
        // Only 10 years
        .call(d3.axisBottom(x).tickValues(years.filter((d, i) => !(i % 10))))
        .selectAll("text")
        .style("color", "black")
        .style("position", "fixed")
        .attr("transform", "translate(-10,10)rotate(-45)")
        .style("text-anchor", "end");

        chart.append("g")
        .call(d3.axisLeft(y))
        .selectAll("text")
        .style("color", "black")
        .attr("transform", "translate(-10,0)")
        .style("text-anchor", "end");    

    const colorScale = d3.scaleSequential()
        .domain([0, d3.max(data, d => d.change)])
        .interpolator(d3.interpolateInferno);


  // add the squares
  chart.selectAll()
    .data(data, function(d) {return d.year +':'+ d.entity;})
    .join("rect")
      .attr("x", function(d) { return x(d.year) })
      .attr("y", function(d) { return y(d.entity) })
      .attr("width", x.bandwidth() )
      .attr("height", y.bandwidth() )
      .style("fill", function(d) { return colorScale(d.change)
                    console.log(d.change);
    } )
      .style("opacity", 0.8)

}); 

