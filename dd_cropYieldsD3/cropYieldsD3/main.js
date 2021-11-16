import './style.css'
import "tailwindcss/tailwind.css"
import * as d3 from 'd3';

// Execute the following code when the DOM is ready
// Get svg

const dataColumns = ['year', 'production', 'code', 'entity'];
const cropNames = ['Wheat', 'Barley', 'Rice', 'Maize', 'Potatoes'];
// Array of years from 1961 to 2018
const years = d3.range(1961, 2019);


const dropDownYear = d3.select("#chart_area")
                        .append("select");

const dropDownCrop = d3.select("#chart_area")
                        .append("select");

dropDownYear
  .selectAll("option")
  .data(years)
  .enter()
  .append("option")
  .attr("value", d => d)
  .text(d => d);

dropDownCrop
  .selectAll("option")
  .data(cropNames)
  .enter()
  .append("option")
  .attr("value", d => d)
  .text(d => d);

// Data and scales
// Create a data array
const data = [];
const colorScale = d3.scaleThreshold()
              .domain([0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0])
              .range(d3.schemeBlues[9]);

// Load crop data and create a map
Promise.all([
  d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"),
  d3.csv("/data/crop_data.csv", function(d) {
    // Add all rows and columns to the data array
    data.push(d);
  })
]).then(function(loadData) {
  // Create map
  const map = d3.geoPath().projection(d3.geoMercator().scale(100).translate([300, 300]));
  const features = loadData[0].features;

// Initialize the map
let svg = d3.select('svg')
    .selectAll('path')
    .data(features)
    .enter()
    .append('path')
    .attr('d', map)
    .attr('fill', '#ccc')
    .attr('stroke', '#333')
    .attr('stroke-width', 0.5)
    // On hover show the crop name
    .on('mouseover', function(d) {
      d3.select(this)
        .attr('fill', '#f00');
    })
    .on('mouseout', function(d) {
      d3.select(this)
        .attr('fill', '#ccc');
    });

  // On click show the crop productio
  function updateMap(year, crop) {
    // Update the map
    svg.attr('fill', d => {
      // Find the corresponding data row
      const row = data.find(r => r.year === year && r.entity === d.properties.name && r.crop === crop);
      if (row) {
        let value = row['crop_production'];
        console.log(row);
        if (value) {
          // Return the color
          return colorScale(value);
        }
      }
      return '#ccc';
    })
    // Smooth transition
    .transition()
    .duration(1000)
    .ease(d3.easeCubicInOut);
  }

  // Update the map when the year changes
  dropDownYear.on('change', function() {
    const year = this.value;
    updateMap(year, 'Wheat');
  }
  );

  // Update the map when the crop changes
  dropDownCrop.on('change', function() {
    const crop = this.value;
    updateMap(1961, crop);
  }
  );
  
  // On load, show the crop production for 1961
  updateMap(1961, 'Wheat');

});
