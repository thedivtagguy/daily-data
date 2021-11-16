import "./style.css";
import "tailwindcss/tailwind.css";
import * as d3 from "d3";

// Execute the following code when the DOM is ready
// Get svg

const cropNames = ["Wheat", "Barley", "Rice", "Maize", "Potatoes"];
// Array of years from 1961 to 2018
const years = d3.range(1961, 2019);

// const dropDownYear = d3.select("#chart_area")
//                         .append("select");

const dropDownCrop = d3
  .select("#info")
  .append("select")
  .attr("id", "crop_select")
  // Defaults to first crop
  .property("value", cropNames[0]);

const dropDownYear = d3
  .select("#info")
  .append("input")
  .attr("type", "range")
  .attr("min", 1961)
  .attr("max", 2018)
  .attr("value", 2007)
  .attr("id", "sliderYear");

const yearLabel = d3.select("#year_label").append("label").text("Year: ");

dropDownYear
  .selectAll("option")
  .data(years)
  .enter()
  .append("option")
  .attr("value", (d) => d)
  .text((d) => d);

dropDownCrop
  .selectAll("option")
  .data(cropNames)
  .enter()
  .append("option")
  .attr("value", (d) => d)
  .text((d) => d);

// Data and scales
// Create a data array
const data = [];
const colorScale = d3
  .scaleThreshold()
  .domain([1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
  .range(d3.schemeBlues[9]);

// Load crop data and create a map
Promise.all([
  d3.json(
    "https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"
  ),
  d3.csv("/data/crop_data.csv", function (d) {
    // Add all rows and columns to the data array
    data.push(d);
  }),
]).then(function (loadData) {
  // Create map
  const map = d3
    .geoPath()
    .projection(d3.geoMercator().scale(100).translate([300, 300]));
  const features = loadData[0].features;

  
  // create a tooltip
  var Tooltip = d3.select("#chart_area")
    .append("div")
    .style("opacity", 0)
    .attr("class", "tooltip")
    .style("background-color", "white")
    .style("border", "solid")
    .style("border-width", "2px")
    .style("border-radius", "5px")
    .style("padding", "5px")




  // Initialize the map
  let svg = d3
    .select("svg")
    .selectAll("path")
    .data(features)
    .enter()
    .append("path")
    .attr("d", map)
    // Get the initialized year for fill
    .attr("fill", (d) => {
      const year = dropDownYear.property("value");
      const crop = dropDownCrop.property("value");
      const filteredData = data.filter(
        (row) => row.Year === year && row.Crop === crop
      );
      // Get value for this country
      const value = filteredData.find((row) => row.Country === d.properties.name);
      
      return colorScale(value);
    })
    .attr("stroke", "#eee")
    .attr("stroke-width", 0.5);




  // On click show the crop productio
  function updateMap(year, crop) {
    // Update the map
    yearLabel.text("Year: " + year);
    svg
      .attr("fill", (d) => {
        // Find the corresponding data row
        const row = data.find(
          (r) =>
            r.year === year && r.entity === d.properties.name && r.crop === crop
        );
        if (row) {
          let value = row["crop_production"];
          if (value) {
            // Return the color
            return colorScale(value);
          }
        }
        return "#ccc";
      })
      // Smooth transition between years
      .on("mouseover", 
      // Show what country is hovered over
      function (d) {
        console.log(d.target.__data__.geometry.id);
        const row = data.find(
          (r) =>
            r.year === year && r.entity === d.target.__data__.properties.name && r.crop === crop
        );
        Tooltip
          .style("opacity", 1)
         
          .html("<p> Country: "+ row['entity'] + "<br>" + 
          "Crop: " + row['crop'] + "<br>" +
          "Production: " + row['crop_production'] + "</p>");
      }
      )
     ;
  
  }

  // Function to watch for changes in the dropdown menus
  function watchDropDowns() {
    // Get the selected year and crop
    const year = dropDownYear.property("value");

    const crop = dropDownCrop.property("value");
    // Update the map
    updateMap(year, crop);
  }

  // Watch for changes in the dropdown menus
  dropDownYear.on("change", watchDropDowns);
  dropDownCrop.on("change", watchDropDowns);




});
