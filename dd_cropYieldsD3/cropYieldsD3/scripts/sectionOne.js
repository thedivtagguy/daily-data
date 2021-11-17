import * as d3 from "d3";

// Execute the following code when the DOM is ready
// Get svg

const cropNames = ["Wheat", "Barley", "Rice", "Maize", "Potatoes"];
// Array of years from 1961 to 2018
const years = d3.range(1961, 2019);

const dropDownCrop = d3
  .select("#dropDownCrop")
  .append("select")
  .attr("class", "block w-12 w-full text-md px-4 py-3 pr-8 leading-tight text-gray-700 bg-gray-200 border border-gray-200 rounded appearance-none focus:outline-none focus:bg-white focus:border-gray-500")
  // Defaults to first crop
  .property("value", cropNames[0]);


const dropDownYear = d3
  .select("#dropDownYear")
  .append("input")
  .attr("type", "range")
  .attr("class", "range range-primary bg-gray-200 w-24 rounded-xl")
  .attr("min", 1961)
  .attr("max", 2018)
  .attr("value", 2007)
  .attr("id", "sliderYear");

const yearLabel = d3.select("#year_label").append("label").text("Year: ");
const currentCountry = d3.select("#currentCountry").append("label");
const currentYear = d3.select("#currentYear").append("label");
const currentYield = d3.select("#currentYield").append("label");

// create a tooltip

let svgContainer = d3.select("#chart");


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

  // Initialize the map
  let svg = svgContainer
    .append("svg")
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
      const value = filteredData.find(
        (row) => row.Country === d.properties.name
      );

      return colorScale(value);
    })
    .attr("stroke", "#eee")
    .attr("stroke-width", 0.5);


  // On click show the crop productio
  function updateMap(year, crop) {
    // Update the map
    yearLabel.text(year);
    currentYear.html("<p> Yield for <span class='badge inline badge-primary'> " + year + "</span> is </p>");


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
      .on("mouseover", function (d) {

        // Update current country
        currentCountry.html("<p>" + d.target.__data__.properties.name + "</p>");
        const row = data.find(
          (r) =>
            r.year === year &&
            r.entity === d.target.__data__.properties.name &&
            r.crop === crop
        );
        /// Stroke the country
        d3.select(this).attr("stroke", "#000");
        d3.selectAll("path").attr("opacity", 0.6);
        d3.select(this).attr("opacity", 1);
        // Get crop_production for this country
        let  value = row["crop_production"];
        // round to 2 decimal places
        value = Math.round(value * 100) / 100;
        currentYield.
        html("<p> " + value + "<span class='text-sm text-gray-400'> tonnes/hectare</span> </p>");
      })      
      .on(
        "mouseleave",
        function (d) {
          d3.select(this).attr("stroke", "#eee");
          d3.selectAll("path").attr("opacity", 1);
        }
        
      );     }

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

  // Map initalization
  updateMap(2007, "Wheat");
});
