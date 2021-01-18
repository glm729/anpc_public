/**
 * Function for preparing a set of data for the D3 force-directed graph (fdg).
 * Assumes `oppose` is from the `reduceOppose` function.  Checks which nodes
 * have already been seen, to avoid defining multiple of the same node.
 * Replaces IDs with the names of the compounds.
 *
 * TODO:  Check why some compounds still feature IDs, and do not appear to
 *        feature a name (=> if statements in withId.map not working).
 *
 * @param {Array} withId Data from the literature with ID(s) in KEGG Compound.
 * @param {Array} oppose Array of objects of opposing compounds, based on the
 * KEGG Reaction equations.
 * @return {Object} Required data for D3 fdg, containing the arrays `nodes` and
 * `links`, defining the graph visualisation.
 */
function prepareVisData(withId, oppose) {
  // Initialise results object
  let result = {"nodes": [], "links": []};
  // Initialise array of nodes seen
  let nodeSeen = [];
  // Loop over the opposing compounds
  oppose.map(o => {
    // Loop over the data with ID
    withId.map(w => {
      // Replace the ID with the name
      if (o.lhs === w.idAnchor.replace(/^cpd:/, '')) o.lhs = w.name;
      if (o.rhs === w.idAnchor.replace(/^cpd:/, '')) o.rhs = w.name;
    })
    // If nodes not already seen, add their data to the nodes object
    if (nodeSeen.indexOf(o.lhs) === -1) result.nodes.push({"name": o.lhs});
    if (nodeSeen.indexOf(o.rhs) === -1) result.nodes.push({"name": o.rhs});
    // Push the opposing compounds to the links
    result.links.push({"source": o.lhs, "target": o.rhs});
  });
  return result;
}
