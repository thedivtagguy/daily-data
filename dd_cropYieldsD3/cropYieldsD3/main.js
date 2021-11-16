import './style.css'
import "tailwindcss/tailwind.css"
import * as d3 from 'd3';

// Execute the following code when the DOM is ready
  // Get svg
  const svg = d3.select('svg');

  // Map and projection
  const projection = d3.geoMercator()
    .scale(100)
    .translate([300, 300]);
  
  // Draw circle in svg
  svg.append('circle')
    .attr('cx', 300)
    .attr('cy', 300)
    .attr('r', 100)
    .attr('fill', 'blue');

  const path = d3.geoPath()
    .projection(projection);
  
  // Load data
  d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson")
  .then(function(data){    
    // Draw map
    svg.selectAll('path')
      .data(data.features)
      .enter()
      .append('path')
      .attr('d', path)
      .attr('fill', '#ccc')
      .attr('stroke', '#333')
      .attr('stroke-width', 0.5);
  });
