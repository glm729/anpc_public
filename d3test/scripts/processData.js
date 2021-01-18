/**
 * Function for processing the data in the test page.  This function may be
 * modified frequently, as development and testing continues, at least until D3
 * is working in ChemInfo.
 *
 * No parameters, (technically) no output.  All hardcoded.  Just a way of
 * cheating when using FileReader, because I cannot comprehend it for some
 * reason.
 *
 * If anyone knows how to pass the FileReader.onload result when using
 * FileReader.readAsText, or assign it to a variable, or just some way of
 * getting file contents as raw text, please let me know.  The current
 * implementation uses callbacks and this function.  I've tried broad-scope
 * variables, and I'm trying to avoid just tacking it to the window, but
 * considering I've already done that, maybe I should use it again....
 */
function processData() {
  if (!checkDataPresent([`_klc`, `_kre`, `_rli`])) return;
  let klc = window._klc;
  let kre = window._kre;
  let rli = window._rli;
  console.log(`Scanning for names in KEGG List Compound.`);
  console.time(`nameInKegg`);
  nameInKegg(rli, klc);
  console.timeEnd(`nameInKegg`);
  console.log(`Scan complete.  Check rli for results.`);
  let withId = window._rli.map(d => {
    if (d.idAnchor !== null) return d;
  }).filter(x => x !== undefined);
  let oppose = getOppose(withId, kre);
  window._opp = oppose;
  console.log(`Stored oppose as "_opp".`);
  let opposeReduced = reduceOppose(withId, oppose);
  window._opr = opposeReduced;
  console.log(`Stored opposeReduced as "_opr".`)
  console.log(`Preparing vis data.`);
  let visData = prepareVisData(withId, opposeReduced);
  console.log(`Vis data prepared, sending to SVG.`);
  runSimulation(visData);
}
