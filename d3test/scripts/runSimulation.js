/**
 * Functionalised version of the tutorial provided by Mike Bostock, creator of
 * D3 and Observable, for force-directed graphs:
 * https://observablehq.com/@d3/disjoint-force-directed-graph
 *
 * I was initially concerned that the simulation would only run one tick if put
 * in a function, btu it appears to persist well.
 *
 * @param {Object} data Input data for the simulation, containing the `nodes`
 * and `links` data.  This will likely be from `prepareVisData`.
 * @param {String} idSvg ID of th DOM node for the SVG.  This may be defeated
 * by the d3.select("svg") call, which I will likely need to check, but it may
 * not be a concern if there aren't multiple SVGs in the document.
 * @return N/A
 */
function runSimulation(data, idSvg = "svgGraph") {
  // Get some info from the page re: where the SVG will be
  let svgElement = document.getElementById(idSvg);
  const width = svgElement.width.baseVal.value;
  const height = svgElement.height.baseVal.value;
  // Initialise the SVG
  const svg = d3.select("svg")  // NOTE:  SELECT NOT CREATE
    .attr("viewBox", [-width / 2, -height / 2, width, height]);
  // Generate some data
  const nodes = data.nodes.map(d => Object.create(d));
  const links = data.links.map(d => Object.create(d));
  // Initialise the simulation with the nodes data and apply forces
  const simulation = d3.forceSimulation(nodes)
    .force("link", d3.forceLink(links).id(d => d.name))
    .force("charge", d3.forceManyBody())
    .force("x", d3.forceX())
    .force("y", d3.forceY());
  // Define simulation drag actions
  drag = simulation => {
    function dragStart(event, d) {
      if (!event.active) simulation.alphaTarget(0.4).restart();
      d.fx = d.x;
      d.fy = d.y;
    };
    function dragged(event,d) {
      d.fx = event.x;
      d.fy = event.y;
    };
    function dragEnd(event,d) {
      if (!event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
    };
    return d3.drag()
      .on("start", dragStart)
      .on("drag", dragged)
      .on("end", dragEnd);
  };
  /* Colour not yet defined/implemented! */
  // Create the links
  const link = svg.append("g")
    .attr("stroke", "#999")
    .attr("stroke-opacity", 0.6)
    .selectAll("line")
    .data(links)
    .join("line")
    .attr("stroke-width", 1);
  // Create the nodes
  const node = svg.append("g")
    .attr("stroke", "#fff")
    .attr("stroke-width", 1.5)
    .selectAll("circle")
    .data(nodes)
    .join("circle")
    .attr("r", 5)
    .attr("fill", d => d.colour)
    .call(drag(simulation));
  // Edit node titles
  node.append("title").text(d => d.name);
  // On each tick, run actions
  simulation.on("tick", () => {
    link
      .attr("x1", d => d.source.x)
      .attr("y1", d => d.source.y)
      .attr("x2", d => d.target.x)
      .attr("y2", d => d.target.y);
    node
      .attr("cx", d => d.x)
      .attr("cy", d => d.y);
  });
}
