import * as d3 from "d3";

const yearLabel = d3.select("#year_label").append("label").text("Year: ");
const currentCountry = d3.select("#currentCountry").append("label");
const currentYear = d3.select("#currentYear").append("label");
const currentYield = d3.select("#currentYield").append("label");
let svgContainer = d3.select("#chart");
const years = d3.range(1961, 2019);

// Create a data array
const data = [];

// Use d3.interpolateInferno to create a color scale
const colorScale = d3
  .scaleThreshold()
  .domain([0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60])
  .range(d3.schemeOrRd[9]);

// Create a legend based on the color scale
const legend = d3
    .select("#legendOne")
    .append("ul")
    .attr("class", "flex flex-wrap");

// Out of the colorScale domain, create a legend using the color scale with only 5 colors
const legendColors = colorScale.domain().map(function(d) {
  return {
    color: colorScale(d),
    label: d
  };
});

// Create for every 6th color a new list item
legend
  .selectAll("li")
  .data(legendColors.slice(0, 8))
  .enter()
  .append("li")
  .style("background-color", function(d) {
    return d.color;
  })
  .attr("class", "list-inline-item px-2")
  .text(function(d) {
    return d.label + " t/ha";
  });



const dropDownCrop = d3
  .select("#dropDownCrop")
  .append("select")
  .attr(
    "class",
    "block w-12 w-full text-md px-4 py-3 pr-8 leading-tight text-gray-700 bg-gray-200 border border-gray-200 rounded appearance-none focus:outline-none focus:bg-white focus:border-gray-500"
  );

const dropDownYear = d3
  .select("#dropDownYear")
  .append("input")
  .attr("type", "range")
  .attr("class", "range range-primary bg-gray-200 w-24 rounded-xl")
  .attr("min", 1961)
  .attr("max", 2018)
  .attr("value", 2018)
  .attr("id", "sliderYear");

dropDownYear
  .selectAll("option")
  .data(years)
  .enter()
  .append("option")
  .attr("value", (d) => d)
  .text((d) => d);

const formats = {
    percent: d3.format('%')
};

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



  // Create an array of all crops
  const cropNames = Array.from(new Set(data.map((d) => d.crop)));
  dropDownCrop
    .selectAll("option")
    .data(cropNames)
    .enter()
    .append("option")
    .attr("value", (d) => d)
    .text((d) => d);

  // Create map
  const map = d3
    .geoPath()
    .projection(d3.geoMercator().scale(100).translate([300, 300]));
  
  const features = loadData[0].features;


  // Initialize the map
  let svg = svgContainer
    .append("svg")
    .attr("width", 700)
    .attr("height", 450)
    .selectAll("path")
    .data(features)
    .enter()
    .append("path")
    .attr("d", map)
    .attr("id", (d) => d.properties.name)
    .attr("fill", (d) => {
      const year = dropDownYear.property("value");
      const crop = dropDownCrop.property("value");
      const filteredData = data.filter(
        (row) => row.year === year && row.crop === crop
      );
      const value = filteredData.find(
        (row) => row.entity === d.properties.name
      );

      if (value > 0) {
        return colorScale(value);
      } else {
        return "#ccc";
      }
    })
    .attr("stroke", "#eee")
    .attr("stroke-width", 0.5);

  function updateMap(year, crop) {
    yearLabel.text(year);
    currentYear.html(
      "<p> Yield for <span class='badge inline badge-primary'> " +
        year +
        "</span> is </p>"
    );

  svg
      .attr("fill", (d) => {
        const row = data.find(
          (r) =>
            r.year === year && r.entity === d.properties.name && r.crop === crop
        );
        if (row) {
          let value = row.crop_production;
          if (value > 0) {
            return colorScale(value);
          }
        }
        return "#ccc";
      })
      .on("mouseover", function (d) {
        currentCountry.html("<p>" + d.target.__data__.properties.name + "</p>");
        const row = data.find(
          (r) =>
            r.year === year &&
            r.entity === d.target.__data__.properties.name &&
            r.crop === crop
        );
        d3.select(this).attr("stroke", "#000");
        d3.selectAll("path").attr("opacity", 0.6);
        d3.select(this).attr("opacity", 1);
        console.log(row);
        let value = row.crop_production;
        value = Math.round(value * 100) / 100;
        currentYield.html(
          "<p> " +
            value +
            "<span class='text-sm text-gray-400'> tonnes/hectare</span> </p>"
        );
      })
      .on("mouseleave", function (d) {
        d3.select(this).attr("stroke", "#eee");
        d3.selectAll("path").attr("opacity", 1);
      });
  }
  
function watchDropDowns() {
    const year = dropDownYear.property("value");
    const crop = dropDownCrop.property("value");
    updateMap(year, crop);
}

  dropDownYear.on("change", watchDropDowns);
  dropDownCrop.on("change", watchDropDowns);

  updateMap(2018, "Wheat");
});
